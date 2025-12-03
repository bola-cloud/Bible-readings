import 'package:flutter/material.dart';

class BatteryWidget extends StatelessWidget {
  final double percentage;
  final double width;
  final double height;

  const BatteryWidget({
    super.key,
    required this.percentage,
    this.width = 200,
    this.height = 20, // Default smaller height for horizontal bars
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    if (percentage >= 0.7) {
      color = Colors.green;
    } else if (percentage >= 0.4) {
      color = Colors.yellow;
    } else {
      color = Colors.red;
    }

    return Stack(
      children: [
        // Background container
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(height / 4),
          ),
        ),
        // Filled bar
        Container(
          width: width * percentage,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 4),
          ),
        ),
        // Percentage text, centered vertically
        Positioned.fill(
          child: Center(
            child: Text(
              "${(percentage * 100).toStringAsFixed(1)}%",
              style: TextStyle(
                fontSize: height * 0.6, // scale text relative to height
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
