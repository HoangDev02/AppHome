import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_home/screens/DeviceListScreen.dart';
import 'package:smart_home/screens/TemperatureTile.dart';
import 'package:smart_home/widgets/QRCodeMain.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_database/firebase_database.dart';

import 'models/Device.dart';
void main() async {
  List<Device> devices = [];
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(devices: devices));

}

typedef MessageCallback = void Function(String message);

class MyApp extends StatelessWidget {
  late final List<Device> devices;
  MyApp({required this.devices});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Home Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: HomePage(devices: devices),
    );
  }
}

class HomePage extends StatefulWidget {
  late final List<Device> devices;

  HomePage({super.key, required this.devices});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isAirConditionerOn = false;
  bool isLightOn = false;
  double? temperature ;
  int? humidity ;
  late MQTTClientWrapper newclient;
  var lightStatus = '';
  int selectedTab = 0; // 0 for "Room", 1 for "Devices"
  int _selectedIndex = 0;
  stt.SpeechToText _speech = stt.SpeechToText();
  String _recognizedText = '';
  bool _isListening = false;
  bool _isSpeaking = false;
  final FlutterTts flutterTts = FlutterTts();
  void processMessage(String topicName, String message) {
    if (topicName == 'control') {
      _updateTemperatureAndHumidity(message);
    } else if (topicName == 'buttonState') {
      // Process button state message here if needed
    }
  }
  void _updateTemperatureAndHumidity(String message) {
    var parts = message.split(',');
    var tempPart = parts[0].split(':')[1].replaceAll('Â', '').trim(); // Loại bỏ kí tự Â
    var humidityPart = parts[1].split(':')[1];
    var temperatureValue = double.tryParse(tempPart.replaceAll('°C', '').trim());
    var humidityValue = int.tryParse(humidityPart.replaceAll('%', '').trim());

    if (temperatureValue != null && humidityValue != null) {
      setState(() {
        temperature = temperatureValue;
        humidity = humidityValue;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    newclient = MQTTClientWrapper(
      this, // Pass the _HomePageState instance
      updateTemperatureAndHumidity: _updateTemperatureAndHumidity,
    );
    newclient.setMessageCallback((message) {
      _updateLightStatus(message);
    });
    newclient.prepareMqttClient('buttonState');
    _loadFirebaseData();
  }

  void _updateLightStatus(String message) {
    setState(() {
      lightStatus = message;
      isLightOn = (message == 'ON');
      print('The message $message');
      print('The isLightOn $isLightOn');
    });
  }
  void _processCommand(String command) {
    if (command.toLowerCase() == 'bật đèn') {
      setState(() {
        isLightOn = true;
      });
    } else if (command.toLowerCase() == 'tắt đèn') {
      setState(() {
        isLightOn = false;
      });
    }
    else if (command.toLowerCase() == 'bật điều hòa') {
      setState(() {
        isAirConditionerOn = true;
      });
    }
    else if (command.toLowerCase() == 'tắt điều hòa') {
      setState(() {
        isAirConditionerOn = false;
      });
    }
  }
  void _playTextToSpeech(String text) async {
    if (!_isSpeaking) {
      _isSpeaking = true;
      await flutterTts.setVolume(1.0);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setPitch(1.0);

      flutterTts.setCompletionHandler(() {
        _isSpeaking = false; // Reset the flag when speech completes
      });

      await flutterTts.speak(text);
    }
  }
  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
    } else {
      if (await _speech.initialize()) {
        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
              _processCommand(_recognizedText);
              if (_recognizedText.toLowerCase().contains('bật đèn')) {
                _playTextToSpeech('Bạn đã bật đèn'); // Phát âm thanh từ văn bản
              } else if (_recognizedText.toLowerCase().contains('tắt đèn')) {
                _playTextToSpeech('Bạn đã tắt đèn'); // Phát âm thanh từ văn bản
              }
              else if (_recognizedText.toLowerCase().contains('bật điều hòa')) {
                _playTextToSpeech('Bạn đã bật điều hòa'); // Phát âm thanh từ văn bản
              }
              else if (_recognizedText.toLowerCase().contains('tắt điều hòa')) {
              _playTextToSpeech('Bạn đã tắt điều hòa'); // Phát âm thanh từ văn bản
              }
            });
          },
        );
      }
    }
    setState(() {
      _isListening = !_isListening;
    });
  }
  void _loadFirebaseData() async {
    DatabaseReference databaseRef = FirebaseDatabase.instance.reference();
    DataSnapshot snapshot = (await databaseRef.child("buttonState").once()).snapshot;

    if (snapshot.value != null) {
      bool firebaseValue = snapshot.value == '1';
      setState(() {
        isLightOn = firebaseValue;
      });
    }
  }
  void _updateFirebaseData(bool newValue) async {
    DatabaseReference databaseRef = FirebaseDatabase.instance.reference();
    await databaseRef.child("buttonState").set(newValue ? '1' : '0');

    if (newclient.client.connectionStatus!.state == mqtt.MqttConnectionState.connected) {
      final String mqttTopic = "buttonState";
      final String mqttPayload = newValue ? '1' : '0';
      final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();
      builder.addString(mqttPayload);
      newclient.client.publishMessage(mqttTopic, mqtt.MqttQos.atLeastOnce, builder.payload!);
    } else {
      print('MQTT connection is not established.');
    }
    setState(() {
      isLightOn = newValue;
    });
  }
  @override
  void dispose() {
    newclient.client.disconnect();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Home',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        // centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // _startListening();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10,),
            TemperatureTile(title: 'Temperature', value: temperature != null ? '${temperature!.toStringAsFixed(1)}' : 'N/A', humb: 'Humidity',humbValue: humidity != null ? '${humidity}': 'N/A'),
            SizedBox(height: 10,),
            // HumidityWidget(title: 'Humidity', humidity:  humidity != null ? '${humidity}%': 'N/A'),
            SizedBox(height: 20),
            Container(
            width: 280,
            // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = 0;
                      });
                    },
                    child: Text(
                      "Room",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = 1;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeviceListScreen(devices: widget.devices),
                          ),
                        );
                      });
                    },
                    child: Text(
                      "Devices",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
            selectedTab == 0 ?
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // _humidity('Humidity', humidity != null ? '${humidity}%': 'N/A'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: _buildFunctionAir('Air Conditioner', isAirConditionerOn,(value) {
                          setState(() {
                            isAirConditionerOn = value;
                          });
                        },'assets/images/air.png',),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildFunctionLamp('Light', isLightOn,_updateFirebaseData, 'assets/images/lamp.png',),
                      ),

                    ],
                  ),
                ],
              ),
            ) :
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // _humidity('Humidity', humidity != null ? '${humidity}%': 'N/A'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: _buildFunctionAir('fan', isAirConditionerOn,(value) {
                          setState(() {
                            isAirConditionerOn = value;
                          });
                        },'assets/images/air.png',),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildFunctionLamp('TV', isLightOn, (value) {
                          setState(() {
                            isLightOn = value;
                          });
                        }, 'assets/images/lamp.png',),
                      ),

                    ],
                  ),
                ],
              ),
            )

          ],
        )
      ),
      bottomNavigationBar: _CustomCurvedBottomNavBarState(_selectedIndex = _selectedIndex, _recognizedText = _recognizedText),
    );
  }
  Widget _buildFunctionLamp(String title, bool value, Function(bool) onChanged, String imageAsset) {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            imageAsset,
            width: 80,
            height: 80,
            color: value ? Colors.yellow : Colors.grey, // Change color when the device is on
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                value ? 'On' : 'Off',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
              // SizedBox(width: 30),
              Switch(
                value: value,
                onChanged: (newValue) {
                  onChanged(newValue);
                  // _updateFirebaseData(newValue);
                },
                activeColor: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildFunctionAir(String title, bool value, Function(bool) onChanged, String imageAsset) {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            imageAsset,
            width: 80,
            height: 80,
            color: value ? Colors.white : Colors.grey, // Change color when the device is on
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                value ? 'On' : 'Off',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
              SizedBox(width: 10),
              Switch(
                value: value,
                onChanged: (newValue) async {
                  onChanged(newValue);
                  if (newclient.client.connectionStatus!.state == mqtt.MqttConnectionState.connected) {
                    final String mqttTopic = "buttonState";
                    final String mqttPayload = newValue ? '1' : '0';
                    final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();
                    builder.addString(mqttPayload);
                    newclient.client.publishMessage(mqttTopic, mqtt.MqttQos.atLeastOnce, builder.payload!);
                  } else {
                    print('MQTT connection is not established.');
                  }
                },
                activeColor: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _CustomCurvedBottomNavBarState(int _selectedIndex, String _recognizedText ) {
    return CurvedNavigationBar(
      color: Colors.blueAccent,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOut,
      height: 55,
      buttonBackgroundColor: Colors.blue,
      animationDuration: Duration(milliseconds: 600),
      index: _selectedIndex,
      items: [
        Icon(Icons.home, size: 30, color: Colors.white), // Home icon
        Icon(Icons.mic, size: 30, color: Colors.white), // Add icon
        Icon(Icons.qr_code_outlined, size: 30, color: Colors.white), // Person icon
      ],
      onTap: (index) {
        setState(() {
          if (index == 1) { // Nếu nhấn vào biểu tượng mic
            _toggleListening();  // Bật chức năng nhận diện giọng nói
          }else if (index == 2) { // Nếu nhấn vào biểu tượng mic
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QRCodeMain(devices: widget.devices),
              ),
            );  // Bật chức năng nhận diện giọng nói
          }
          else {
            setState(() {
              _selectedIndex = index;
            });
          }
        });
      },
    );
  }
}

class MQTTClientWrapper {
  final _HomePageState homePage;
  late MqttServerClient client;
  final void Function(String) updateTemperatureAndHumidity;
  MQTTClientWrapper(this.homePage, {
    required this.updateTemperatureAndHumidity,
  }) {
    _setupMqttClient();
  }

  void setMessageCallback(MessageCallback callback) {
    // ... Your setMessageCallback implementation ...
  }

  void _emitMessage(String message) {
    // ... Your _emitMessage implementation ...
  }

  void _setupMqttClient() {
    client = MqttServerClient.withPort(
      'f63a3874d1364c15ba9d13699c92dc63.s1.eu.hivemq.cloud',
      'client_id',
      8883,
    );

    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }
  void _onConnected() {
    print('OnConnected client callback - Client connection was successful');
    _subscribeToTopic('control'); // Subscribe to the 'control' topic here
  }
  Future<void> _connectClient(String topic) async {
    try {
      print('Client connecting...');
      await client.connect('esp8266Den', 'esp8266Den');
    } on Exception catch (e) {
      print('Client exception - $e');
      client.disconnect();
    }
    if (client.connectionStatus!.state == mqtt.MqttConnectionState.connected) {
      print('Client connected');
      // Don't subscribe here; subscribe in the _onConnected callback
    } else {
      print('ERROR: Client connection failed');
      client.disconnect();
    }
  }

  void _subscribeToTopic(String topicName) {
    print('Subscribing to the $topicName topic');
    client.subscribe(topicName, mqtt.MqttQos.atMostOnce);
    client.updates?.listen((List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> c) {
      final mqtt.MqttMessage recMess = c[0].payload;
      if (recMess is mqtt.MqttPublishMessage) {
        var message = mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        print('YOU GOT A NEW MESSAGE:');
        print(message);
        // Pass the message to the HomePage instance for processing
        homePage.processMessage(topicName, message);
      }
    });

  }

  void _publishMessage(String topic) {
    final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();
    // builder.addString(message);

    print('topic "$topic');
    client.publishMessage(
      topic,
      mqtt.MqttQos.exactlyOnce,
      builder.payload!,
    );
  }

  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void _onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
  }

  void prepareMqttClient(String topic) async {
    _setupMqttClient();
    await _connectClient(topic);
    _publishMessage(topic);
  }
}
