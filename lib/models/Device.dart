class Device {
  String name;
  bool status;
  String icon;
  String room; // Thêm trường để lưu thông tin phòng
  String topic ;
  bool connect ;

  Device({
    required this.name,
    required this.status,
    required this.icon,
    required this.room,
    required this.topic,
    required this.connect,
  });
}