import 'package:flutter/material.dart';

class StyledBodyText extends StatelessWidget {
  const StyledBodyText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Text(
        textDirection: TextDirection.rtl,
        text,
        style: TextStyle(
          color: Colors.brown[900],
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
