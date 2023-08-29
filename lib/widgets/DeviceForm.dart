import '../widgets/QRCodeMain.dart';
import '../models/Device.dart';
import '../config/Icon.dart';
import '../screens/DeviceListScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputDeviceScreen extends StatefulWidget {
  late final String topic;
  late final List<Device> devices; // Thêm danh sách thiết bị
  InputDeviceScreen({required this.topic, required this.devices}); // Truyền danh sách thiết bị vào constructor
  @override
  _InputDeviceScreenState createState() => _InputDeviceScreenState();
}

class _InputDeviceScreenState extends State<InputDeviceScreen> {
  String selectedIcon = defaultIcons.isNotEmpty ? defaultIcons[0] : '';
  final TextEditingController deviceNameController = TextEditingController();
  final TextEditingController roomNameController = TextEditingController();
  List<String> rooms = ['Living', 'Bathroom', 'BedRoom', 'KitchenRoom'];
  String selectedRoom = 'Living';
  // String extractRoomNameFromTopic(String topic, List<String> rooms) {
  //   // Tách chuỗi thành mảng các phần tử
  //   List<String> topicParts = topic.split('/');
  //   // Kiểm tra xem phần tử cuối cùng của mảng có trong danh sách rooms hay không
  //   if (topicParts.isNotEmpty) {
  //     String lastPart = topicParts.last; // Lấy phần tử cuối cùng của mảng
  //     if (rooms.contains(lastPart)) {
  //       // Nếu lastPart nằm trong danh sách rooms, trả về tên phòng
  //       return lastPart;
  //     }
  //   }
  //   // Trả về chuỗi rỗng nếu không tìm thấy tên phòng
  //   return 'Living';
  // }
  @override
  void initState() {
    super.initState();
    deviceNameController.text = widget.topic;
  }
  @override
  Widget build(BuildContext context) {
    // String selectedRoom = extractRoomNameFromTopic(widget.topic, rooms);
    // print(selectedRoom);
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Thiết Bị'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: deviceNameController,
                  decoration: InputDecoration(labelText: 'Tên thiết bị'),
                  onSubmitted: (value) {
                    // Kiểm tra xem đã chọn icon và phòng chưa
                    if (selectedIcon.isNotEmpty && selectedRoom.isNotEmpty) {
                      setState(() {
                        // Thêm mới thiết bị
                        widget.devices.add(Device(
                          name: deviceNameController.text,
                          status: false,
                          icon: selectedIcon,
                          room: selectedRoom,
                          topic: widget.topic,
                          connect: false,
                        ));
                        deviceNameController.text = '';
                      });
                    } else {
                      // Hiển thị thông báo nếu chưa chọn icon hoặc phòng
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Vui lòng chọn icon và phòng trước khi thêm thiết bị.'),
                      ));
                    }
                  },
                ),
                SizedBox(height: 16),
                DropdownButton<String>(
                  hint: Text('Chọn phòng'), // Hiển thị khi chưa chọn phòng nào
                  value: selectedRoom,
                  items: rooms.map((String room) {
                    return DropdownMenuItem<String>(
                      value: room,
                      child: Text(room),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRoom = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          if (defaultIcons.isNotEmpty)
            Row(
              children: [
                Text("Chọn Icon cho Device"),
              ],
            ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Số cột trong lưới
              ),
              itemCount: defaultIcons.length,
              itemBuilder: (ctx, index) {
                final icon = defaultIcons[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIcon = icon;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedIcon == icon ? Colors.blue : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Image.network(icon),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Chuyển đến màn hình danh sách thiết bị
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceListScreen(devices: widget.devices),
                ),
              );
            },
            child: Text('Xem Thiết Bị'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chẳng hạn, bạn có thể chuyển đến màn hình thêm thiết bị
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRCodeMain(devices: widget.devices,) ,// Thay InputDeviceScreen() bằng màn hình thêm thiết bị của bạn
            ),
          );
        },
        child: Icon(Icons.qr_code_scanner_sharp),
      ),
    );
  }
}


