import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperatureChartPage extends StatefulWidget {
  @override
  _TemperatureChartPageState createState() => _TemperatureChartPageState();
}

class _TemperatureChartPageState extends State<TemperatureChartPage> {
  double sliderValue = 7; // Giá trị mặc định của thanh kéo
  final int maxVisibleSpots = 5; // Số lượng dấu chấm hiển thị trên biểu đồ

  List<FlSpot> temperatureData = [
    FlSpot(0, 25),
    FlSpot(1, 26),
    FlSpot(2, 27),
    FlSpot(3, 28),
    FlSpot(4, 25),
    FlSpot(5, 30),
    FlSpot(6, 32),
    FlSpot(7, 31),
    FlSpot(8, 25),
    FlSpot(9, 32),
    FlSpot(10, 32),
    FlSpot(12, 33),
    FlSpot(13, 25),
    FlSpot(14, 32),
    FlSpot(15, 21),
    FlSpot(16, 25),
    FlSpot(17, 25),
  ];

  @override
  Widget build(BuildContext context) {
    int startIndex = sliderValue.toInt();
    int endIndex = startIndex + maxVisibleSpots;

    return Container(

      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temperature',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: startIndex.toDouble(),
                maxX: endIndex.toDouble(),
                minY: 0,
                maxY: 35,
                lineBarsData: [
                  LineChartBarData(
                    spots: temperatureData.sublist(startIndex, endIndex),
                    isCurved: true,
                    color: Colors.blue,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        return spot.y != null && spot.y > 0;
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 7,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.blue,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Slider(
            value: sliderValue,
            min: 0,
            max: temperatureData.length - maxVisibleSpots.toDouble(),
            onChanged: (value) {
              setState(() {
                sliderValue = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
