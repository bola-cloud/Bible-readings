import 'package:flutter/material.dart';
import 'package:flutter_application_1/coffee_prefs.dart';
import 'package:flutter_application_1/styled_body_text.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coffee Id', style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),),
        backgroundColor: Colors.brown,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.brown[200],
            padding: const EdgeInsets.all(20),
            child: const StyledBodyText("How I like my coffee...",),
          ),
          Container(
            color: Colors.brown[100],
            padding: const EdgeInsets.all(20),
            child: const CoffeePrefs(),
          ),
          Expanded(
            child: Image.asset("assets/img/coffee_bg.jpg", 
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
                // width: 25,
                // color: Colors.brown[100],
                // colorBlendMode: BlendMode.multiply,
              ),
          ),
        ],
      )
    );
    
    
    
  }
}
