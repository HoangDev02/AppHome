// import '../models/ChartData.dart';
// import 'package:flutter/material.dart';
// // import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:intl/intl.dart';
// class RainfallChart extends StatefulWidget {
//   final List<double> rainfallData; // Dữ liệu lượng mưa trong tháng
//   RainfallChart(this.rainfallData);
//   @override
//   _RainfallChartState createState() => _RainfallChartState();
// }
//
// class _RainfallChartState extends State<RainfallChart> {
//   bool isOn = false; // Ban đầu ở trạng thái "Off"
//
//   void toggleSwitch() {
//     setState(() {
//       isOn = !isOn; // Chuyển đổi trạng thái
//     });
//   }
//
//   String getDayName(DateTime date) {
//     return DateFormat('EEEE', 'en_US').format(date);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double RainValue = widget.rainfallData.last;
//     String dayName = getDayName(DateTime.now());
//     List<charts.Series<ChartData, int>> seriesList = [
//       charts.Series<ChartData, int>(
//         id: 'rainfall',
//         data: List.generate(widget.rainfallData.length, (index) {
//           return ChartData(index, widget.rainfallData[index]);
//         }),
//         domainFn: (ChartData data, _) => data.day,
//         measureFn: (ChartData data, _) => data.rainfall,
//       ),
//     ];
//
//     return Column(
//       children: <Widget>[
//         Expanded(
//           flex: 2, // Chia màn hình thành 2/3 cho biểu đồ
//           child: charts.LineChart(
//             seriesList,
//             animate: true,
//             behaviors: [
//               charts.ChartTitle('Lượng mưa (mm)',
//                   behaviorPosition: charts.BehaviorPosition.start,
//                   titleStyleSpec: charts.TextStyleSpec(fontSize: 14)),
//             ],
//           ),
//         ),
//         Expanded(
//           flex: 1, // Chia màn hình thành 1/3 cho thông tin và dự báo
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Expanded(
//                 child: Card(
//                   elevation: 4, // Độ nổi của thẻ
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(dayName, style: TextStyle(color: Colors.black45 , fontSize: 20),),
//                         SizedBox(height: 30,),
//                         Icon(Icons.wb_sunny, size: 40, color: Colors.black54,),
//                         Text('Độ ẩm: 80%'),
//                         SizedBox(height: 20),
//                         Icon(Icons.umbrella_rounded, size: 40 , color: Colors.black54,),
//                         Text('Mưa: 30%'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Column(
//                 children: [
//                   Expanded(
//                     child: Card(
//                       elevation: 4, // Độ nổi của thẻ
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             // Nửa đầu của Card: Icon cảm biến mưa
//                             Column(
//                               children: [
//                                 Icon(Icons.sensors_outlined, size: 40),
//                                 SizedBox(height: 10),
//                                 Text('  Cảm biến mưa'),
//                               ],
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 20, right: 20),
//                               child: Container(
//                                 width: 2,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey, // Màu sắc của thanh line
//                                 ),
//                               ),
//                             ),
//                             // Nửa sau của Card: Giá trị đọc từ cảm biến mưa
//                             Column(
//                               children: [
//                                 Text(
//                                   'Rain Value',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 SizedBox(height: 10),
//                                 Text(
//                                   '$RainValue',
//                                   style: TextStyle(fontSize: 30),
//                                 )
//                                 // Thêm thông tin về giá trị đọc từ cảm biến mưa ở đây
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Card(
//                       elevation: 4, // Độ nổi của thẻ
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             // Nửa đầu của Card: Icon cảm biến mưa
//                             Column(
//                               children: [
//                                 Icon(Icons.dry_cleaning_sharp, size: 40),
//                                 SizedBox(height: 10),
//                                 Text('    Giá Phơi Đồ   '),
//                               ],
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 20, right: 20),
//                               child: Container(
//                                 width: 2,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey, // Màu sắc của thanh line
//                                 ),
//                               ),
//                             ),
//                             // Nửa sau của Card: Giá trị đọc từ cảm biến mưa
//                             Column(
//                               children: [
//                                 Text(
//                                   'Rain Value',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 SizedBox(height: 10),
//                               Container(
//                                 width: 70,
//                                 height: 50,
//                                 child:     ElevatedButton(
//                                   onPressed: toggleSwitch,
//                                   style: ElevatedButton.styleFrom(
//                                     primary: isOn ? Colors.green : Colors.red, // Màu nền
//                                   ),
//                                   child: Text(
//                                     isOn ? 'On' : 'Off', // Hiển thị nút là "On" hoặc "Off"
//                                     style: TextStyle(fontSize: 20),
//                                   ),
//                                 ),
//                               )
//
//                           ],
//                            ),
//                             ]
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               ],
//           ),
//         ),
//       ],
//     );
//   }
// }
