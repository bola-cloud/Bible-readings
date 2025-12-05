import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _crossAnimation;
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Cross animation
    _crossAnimation = Tween<double>(begin: 0.5, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);

    // Navigate after 3 seconds
    Timer(Duration(seconds: 3), () async {
      await _databaseService.database;
      Navigator.pushReplacementNamed(context, "/home");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// --- Background Image ---
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/background.jpeg"),
                fit: BoxFit.fill,
              ),
            ),
          ),

          /// --- Pale Overlay ---
          Container(
            color: Colors.white.withOpacity(0.30), // soft pale overlay
          ),

          /// --- Main Content ---
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 100),
                    // Animated Cross Icon
                    ScaleTransition(
                      scale: _crossAnimation,
                      child: Icon(
                        Icons.church,
                        size: 90,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 40),

                    // Spinner
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),

                    SizedBox(height: 50),

                    // Credits Section
                    Text(
                      "Developed by:",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 20),

                    // YOU
                    Text(
                      "• Samer Walaa\n  Email: samer.walaa18@gmail.com",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),

                    SizedBox(height: 15),

                    // Developer X
                    Text(
                      "• Bola Eshak\n  Email: <X_EMAIL_HERE>",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),

                    SizedBox(height: 40),

                    // Footer
                    Text(
                      "Made with ❤️ for God’s glory",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),

                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
