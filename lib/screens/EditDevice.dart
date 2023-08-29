
import '../models/Device.dart';
import '../config/Icon.dart';
import '../screens/EditDevice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/Device.dart';
class EditDeviceScreen extends StatefulWidget {
  final Device device;
  final int index; // Receive the index
  EditDeviceScreen({required this.device, required this.index});
  @override
  _EditDeviceScreenState createState() => _EditDeviceScreenState();
}

class _EditDeviceScreenState extends State<EditDeviceScreen> {
  // List<Device> devices = [];
  String selectedIcon = '';
  final TextEditingController deviceNameController = TextEditingController();
  final TextEditingController roomNameController = TextEditingController();
  List<String> rooms = ['Living', 'Bathroom', 'BedRoom', 'KitchenRoom'];
  String selectedRoom = 'Living'; // Phòng mặc định khi ban đầu mở ứng dụng
  List<Device> tempDevices = []; // Danh sách tạm thời

  @override
  void initState() {
    super.initState();
    selectedIcon = widget.device.icon;
    deviceNameController.text = widget.device.name;
    selectedRoom = widget.device.room;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh Sửa Thiết Bị'),
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
                        // Chỉnh sửa thiết bị
                        final updatedDevice = Device(
                          name: deviceNameController.text,
                          status: widget.device.status, // Giữ nguyên trạng thái
                          icon: selectedIcon,
                          room: selectedRoom,
                          topic: widget.device.topic,// Giữ nguyên topic
                          connect: widget.device.connect,// Giữ nguyên topic
                        );

                        // Trả về thông tin thiết bị đã chỉnh sửa cho màn hình danh sách
                        Navigator.pop(context, {'device': updatedDevice, 'index': widget.index}); // Pass the updated device and index
                      } else {
                        // Hiển thị thông báo nếu chưa chọn icon hoặc phòng
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Vui lòng chọn icon và phòng trước khi cập nhật thiết bị.'),
                        ));
                      }
                    }
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
        ],
      ),
    );
  }
}
