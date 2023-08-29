import 'package:flutter/material.dart';
import 'dart:math';

class HumidityWidget extends StatelessWidget {
  final String title;
  final String humidity;

  const HumidityWidget({required this.title, required this.humidity});

  @override
  Widget build(BuildContext context) {
    final int humidityValue = int.tryParse(humidity) ?? 0;
    final double humidityProgress = humidityValue / 100;
    final double humidityAngle = -pi + (2 * pi * humidityProgress);

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: ProgressPainter(color: _getColorForHumidity(humidityValue), humidity: humidityValue.toDouble()),
            size: Size(100, 100),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 5),
              Text(
                '$humidity%',
                style: TextStyle(fontSize: 22, color: Colors.black87, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForHumidity(int humidityValue) {
    if (humidityValue < 30) {
      return Colors.blue;
    } else if (humidityValue < 60) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}

class ProgressPainter extends CustomPainter {
  final Color color;
  final double humidity;

  ProgressPainter({required this.color, required this.humidity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final startAngle = -pi / 2; // Điểm bắt đầu ở góc phía trên
    final maxAngle = pi * 2 * (humidity / 100); // Chuyển đổi độ ẩm thành góc trong radian
    final sweepAngle = maxAngle;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
