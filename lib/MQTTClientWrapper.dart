
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'config/EmitCallback.dart';
typedef MessageCallback = void Function(MessageData messageData);
class MQTTClientWrapper {
  late MqttServerClient client;
  late Stream<String> stream;
  MQTTClientWrapper() {
    _setupMqttClient();
  }
  MessageCallback? messageCallback;
  void setMessageCallback(MessageCallback callback) {
    messageCallback = callback;
  }
  // Add a method to emit messages to the stream
  void _emitMessage(String topic, String message) {
    if (messageCallback != null) {
      final messageData = MessageData(topic, message);
      messageCallback!(messageData);
    }
  }
  void _setupMqttClient() {
    client = MqttServerClient.withPort(
      '44999388b4dc4398947b13c72f75e7b1.s2.eu.hivemq.cloud',
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

  Future<void> _connectClient(String topic) async {
    try {
      print('Client connecting...');
      await client.connect('Esp8266Demo', 'Esp8266Demo');
    } on Exception catch (e) {
      print('Client exception - $e');
      client.disconnect();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Client connected');
      subscribeToTopic(topic); // Move subscription here after successful connection
    } else {
      print('ERROR: Client connection failed');
      client.disconnect();
    }
  }

  void subscribeToTopic(String topicName) {
    print('Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      for (final MqttReceivedMessage<MqttMessage> message in c) {
        final MqttMessage recMess = message.payload;
        if (recMess is MqttPublishMessage) {
          var message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          print('BẠN ĐÃ NHẬN ĐƯỢC THÔNG ĐIỆP MỚI:');
          print(message);
          // Cập nhật dữ liệu khi có thông điệp mới
          _emitMessage(topicName, message);
        }
      }
    });
  }

  void publishMessage(String message , String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    print('Publishing message "$message" to topic "$topic');
    client.publishMessage(
      topic,
      MqttQos.exactlyOnce,
      builder.payload!,
    );
  }

  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void _onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
  }

  void _onConnected() {
    print('OnConnected client callback - Client connection was successful');
  }

  Future<void> prepareMqttClient(String topic) async {
    _setupMqttClient();
    await _connectClient(topic);
    publishMessage('OFF',topic);
  }


  // Add a getter method to access the stream
  Stream<String> get mqttStream => stream;
}
