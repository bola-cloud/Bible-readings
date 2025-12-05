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
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Cross animation
    _crossAnimation = Tween<double>(begin: 0.5, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () async {
      // ensure DB is ready (some platforms need initialization)
      try {
        await _databaseService.database;
      } catch (_) {}

      if (!mounted) return;

      // Use pushReplacementNamed to replace the landing page with home
      Navigator.pushReplacementNamed(context, '/home');
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/background.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// --- Pale Overlay ---
          Container(
            color: Colors.white.withOpacity(0.50), // soft pale overlay
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
                    const SizedBox(height: 100),
                    // Animated Cross Icon
                    ScaleTransition(
                      scale: _crossAnimation,
                      child: const Icon(
                        Icons.church,
                        size: 90,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Spinner
                    const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),

                    const SizedBox(height: 50),

                    // Credits Section
                    const Text(
                      "Developed by:",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // YOU
                    const Text(
                      "• Samer Walaa\n  Email: samer.walaa18@gmail.com",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),

                    const SizedBox(height: 15),

                    // Developer X
                    const Text(
                      "• Bola Eshak\n  Email: <X_EMAIL_HERE>",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),

                    const SizedBox(height: 40),

                    // Footer
                    const Text(
                      "Made with ❤️ for God’s glory",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),

                    const SizedBox(height: 10),
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
