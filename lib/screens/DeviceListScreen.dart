
import '../widgets/QRCodeMain.dart';
import '../MQTTClientWrapper.dart';
import '../models/Device.dart';
import '../screens/EditDevice.dart';
import '../widgets/showConfirmationDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:test/expect.dart';

import '../models/Device.dart';
class DeviceListScreen extends StatefulWidget {
  final MQTTClientWrapper newclient = MQTTClientWrapper();
  late final List<Device> devices;
  DeviceListScreen({ required this.devices});

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<String> rooms = ['Living', 'Bathroom', 'BedRoom', 'KitchenRoom'];
  String selectedRoom = 'Living'; // Phòng mặc định khi ban đầu mở ứng dụng
  bool showIcons = false;
  int selectedCardIndex = -1;
  List<Device> filteredDevices = []; // Danh sách thiết bị lọc theo phòng
  Device? selectedDevice;
  late bool isDeviceOn;
  late  String deviceStatus;
  bool mqttConnected = false;
  Future<void> connectAllDevicesToMQTT(List<Device> devices) async {
    for (final Device device in devices) { // khi còn device thì connect
      if (!device.connect) {
        await widget.newclient.prepareMqttClient(device.topic);
        print('Connect to $device.topic');
        device.connect = true; // Đã kết nối MQTT
      }
    }
  }
  @override
  void initState() {
    super.initState();
    isDeviceOn = false;
    // Call the function to connect all devices to MQTT
    connectAllDevicesToMQTT(widget.devices).then((_) {
      // All devices are connected at this point
      // Set up the message callback once for all devices
      widget.newclient.setMessageCallback((messageData) {
        final topic = messageData.topic;
        final message = messageData.message;
        _updateDeviceStatus(topic, message);
      });
    });
  }
  @override
  void dispose() {
    widget.newclient.client.disconnect();
    super.dispose();
  }

  // void _updateDeviceStatus(String topic, String message) {
  //   setState(() {
  //     deviceStatus = message;
  //     isDeviceOn = (message == 'ON');
  //     print('Received message from topic: $topic'); // Print the topic
  //     print('The message $message');
  //     print('The isLightOn $isDeviceOn');
  //
  //     // Find the corresponding device in filteredDevices by topic
  //     final updatedDeviceIndex = filteredDevices.indexWhere((device) => device.topic == topic);
  //
  //     if (updatedDeviceIndex != null) {
  //       // Nếu thiết bị được tìm thấy, cập nhật trạng thái của nó
  //       filteredDevices[updatedDeviceIndex].status = isDeviceOn;
  //     }
  //   });
  // }

  void _updateDeviceStatus(String topic, String message) {
    setState(() {
      deviceStatus = message;
      isDeviceOn = (message == 'ON');
      print('Nhận thông điệp từ chủ đề: $topic'); // In ra chủ đề
      print('Thông điệp: $message');
      print('Trạng thái: $isDeviceOn');

      // Tìm thiết bị tương ứng trong danh sách filteredDevices bằng chủ đề
      final updatedDeviceIndex = filteredDevices.indexWhere((device) => device.topic == topic);

      if (updatedDeviceIndex != -1) {
        // Nếu tìm thấy thiết bị, cập nhật trạng thái của nó
        filteredDevices[updatedDeviceIndex].status = isDeviceOn;
      }
    });
  }
  void showCardActions(int index) {
    setState(() {
      showIcons = true;
      selectedCardIndex = index;
    });
  }

  void hideCardActions() {
    setState(() {
      showIcons = false;
      selectedCardIndex = -1;
    });
  }
  void deleteDevice(Device selectedDevice) {
    // delete in firebase and topic
    setState(() {
      widget.devices.remove(selectedDevice);
      print(widget.devices.length);
    });
  }
  @override
  Widget build(BuildContext context) {
    filteredDevices = widget.devices
        .where((device) => device.room == selectedRoom)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Thiết Bị'),
      ),
      body:Column(
        children: [
          // Phần danh sách phòng
          Container(
            height: 50, // Điều chỉnh chiều cao tùy ý
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                bool isSelected = room == selectedRoom;
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRoom = room;
                        // filteredDevices = widget.devices
                        //     .where((device) => device.room == selectedRoom)
                        //     .toList();
                        // for (final Device device in filteredDevices) {
                        //   connectToMQTT(device);
                        //   print('connected $device');
                        // }
                        // widget.newclient.setMessageCallback((messageData) {
                        //   final topic = messageData.topic;
                        //   final message = messageData.message;
                        //   _updateDeviceStatus(topic, message);
                        // });

                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          room,
                          style: TextStyle(
                            fontSize: isSelected ? 18.0 : 16.0, // Kích thước chữ
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.black, // Màu chữ
                          ),
                        ),
                        Container(
                          height: 3,
                          width: 30,
                          color: isSelected ? Colors.blue : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Phần danh sách thiết bị
          Expanded(
            child:( !filteredDevices.isEmpty)? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: filteredDevices.length,
              itemBuilder: (ctx, index) {
                final device = filteredDevices[index];
                // print(device.topic);
                // // Kiểm tra xem đã kết nối MQTT hay chưa
                // if (!mqttConnected) {
                //   widget.newclient.prepareMqttClient(device.topic);
                //   mqttConnected = true; // Đã kết nối MQTT
                // }
                // !device.connect ?
                // widget.newclient.subscribeToTopic(device.topic) : print("Connected");
                int indexOfFilteredDeviceInDevices(Device filteredDevice) {
                  return widget.devices.indexWhere((device) => device == filteredDevice);
                }
                final filteredDeviceIndex = indexOfFilteredDeviceInDevices(device);
                return GestureDetector(
                  onTap: () {
                    // Xử lý khi thẻ được nhấn
                  },
                  onLongPress: () {
                    // Xử lý khi thẻ được giữ trong vòng 2 giây
                    selectedDevice = device;
                    showCardActions(index);
                    Future.delayed(Duration(seconds: 5), () {
                      hideCardActions();
                    });
                  },
                  child: Stack(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        margin: EdgeInsets.all(10),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 60,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(device.icon),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                device.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Switch(
                                value: device.status,
                                onChanged: (value) {
                                  setState(() {
                                    device.status = value;
                                    widget.newclient.publishMessage(value ? 'ON' : 'OFF', device.topic);
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (showIcons && selectedCardIndex == index)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.white),
                                      onPressed: () {
                                        showConfirmationDialog(
                                          context,
                                          title: 'Xác nhận',
                                          message: 'Bạn có chắc chắn muốn sửa thông tin thiết bị này?',
                                          dialogColor: Colors.white, // Tuỳ chỉnh màu nền của hộp thoại (tùy chọn)
                                            onConfirm: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditDeviceScreen(device: filteredDevices[index], index: selectedCardIndex),
                                                ),
                                              ) as Map<String, dynamic>; // Expect a map with 'device' and 'index'

                                              if (result['device'] is Device && result['index'] != null) {
                                                final updatedDevice = result['device'] as Device;
                                                // final index = result['index'] as int;
                                                print(selectedRoom);
                                                print(updatedDevice.name);
                                                print(filteredDeviceIndex);
                                                setState(() {
                                                  widget.devices[filteredDeviceIndex] = updatedDevice; // Update the selected device in the list
                                                });
                                              }

                                            }
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.white),
                                      onPressed: () {
                                        // Thực hiện chức năng xóa ở đây
                                          showConfirmationDialog(
                                            context,
                                            title: 'Xác nhận',
                                            message: 'Bạn có chắc chắn muốn xóa thiết bị này?',
                                            dialogColor: Colors.white, // Tuỳ chỉnh màu nền của hộp thoại (tùy chọn)
                                            onConfirm: () {
                                            if (selectedDevice != null) {
                                              // Xóa thiết bị khỏi danh sách
                                              deleteDevice(selectedDevice!);
                                              hideCardActions();
                                            };
                                            },
                                          );
                                      },
                                    ),
                                    SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Thực hiện chức năng Cancel ở đây
                                        hideCardActions();
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ) : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No devices added to the room',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 25),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Chẳng hạn, bạn có thể chuyển đến màn hình thêm thiết bị
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRCodeMain(devices: widget.devices,) ,// Thay InputDeviceScreen() bằng màn hình thêm thiết bị của bạn
                        ),
                      );
                    },
                    child: Text('Thêm Thiết Bị'),
                  ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}

