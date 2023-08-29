import '../widgets/DeviceForm.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/Device.dart';

class QRCodeMain extends StatefulWidget {
  late final List<Device> devices;
  QRCodeMain({required this.devices});

  @override
  _QRCodeMainState createState() => _QRCodeMainState();
}

class _QRCodeMainState extends State<QRCodeMain> {
  String mqttDeviceInfo = '';
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool QRStatus = false;

  @override
  void initState() {
    super.initState();
    QRStatus = false;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        mqttDeviceInfo = scanData.code!;
        result = scanData;
        QRStatus = true;
        _navigateToInputDeviceScreen(); // Gọi hàm để chuyển đến InputDeviceScreen
      });
    });
  }

  void _navigateToInputDeviceScreen() {
    if (QRStatus) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InputDeviceScreen(
            topic: mqttDeviceInfo,
            devices: widget.devices,
          ),
        ),
      ).then((value) {
        setState(() {
          QRStatus = false; // Đặt lại trạng thái quét sau khi quay lại từ InputDeviceScreen
        });
      });
      if (controller != null) {
        controller!.toggleFlash();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('QR Code Scanner'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              !QRStatus ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Center(
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.green, // Màu nền của khung quét
                                border: Border.all(
                                  color: Colors.green, // Màu viền
                                  width: 2.0, // Độ rộng của viền
                                ),
                                borderRadius: BorderRadius.circular(10.0), // Góc bo
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5), // Màu bóng
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3), // Vị trí bóng
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0), // Góc bo
                                child: QRView(
                                  key: qrKey,
                                  onQRViewCreated: _onQRViewCreated,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Row(
                      // Lớp dưới cùng: Hình nền
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/QRcodem.jpg'), // Thay thế bằng đường dẫn đến hình nền của bạn
                                  fit: BoxFit.cover, // Để hình nền phủ kín màn hình
                                ),
                              ),
                            ),
                          ),
                        ]
                    ),
                  ),
                ],
              )

                  : ElevatedButton(
                onPressed: () {
                  _navigateToInputDeviceScreen();
                },
                child: Text('Navigate to Input Device Screen'),
              ),

            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     _navigateToInputDeviceScreen(); // Khi nhấn nút floatingActionButton, thực hiện quét QR và chuyển đến InputDeviceScreen
        //   },
        //   child: Icon(Icons.flash_on),
        // ),
      ),
    );
  }
}
