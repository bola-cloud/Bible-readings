import 'package:flutter/material.dart';

class StyledBodyText extends StatelessWidget {
  final String text;
  final double fontSize; // Add this parameter
  
  const StyledBodyText(this.text, {super.key, this.fontSize = 16.0}); // Default 16
  

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Text(
        textDirection: TextDirection.rtl,
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          height: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
