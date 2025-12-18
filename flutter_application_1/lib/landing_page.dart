// ...existing code...
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:google_fonts/google_fonts.dart';

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
      duration: const Duration(seconds: 3),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Cross animation
    _crossAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 5), () async {
      // ensure DB is ready (some platforms need initialization)
      try {
        await _database_service_ready();
      } catch (_) {}

      if (!mounted) return;

      // Use pushReplacementNamed to replace the landing page with home
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  Future<void> _database_service_ready() async {
    try {
      await _databaseService.database;
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPortraitContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        // // Animated Cross Icon
        // ScaleTransition(
        //   scale: _crossAnimation,
        //   child: const Icon(
        //     Icons.church,
        //     size: 90,
        //     color: Colors.black,
        //   ),
        // ),
        ScaleTransition(
          scale: _crossAnimation,
          child: Container(
            decoration: BoxDecoration(
              // Add background blending similar to your styling
              color: Colors.white.withOpacity(0.3), // Adjust opacity as needed
              borderRadius: BorderRadius.circular(
                12,
              ), // Optional: rounded corners
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.transparent, // Changes white parts to this color
                BlendMode.srcATop,
              ),
              child: Image.asset(
                'assets/icons/al_mktb.jpg', // Your image path
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Spinner
        const SizedBox(
          height: 36,
          width: 36,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),

        const SizedBox(height: 18),

        // Title / Credits
        Text(
          "تطبيق تأملاتى",
          style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 14),

        // Short description
        Text(
          "ابدأ رحلتك اليومية مع كلمة الرب — تأمل، صلِ، وسجل ما يحرك قلبك.",
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 18),

        // Credits block
        Column(
          children: [
            Text(
              "Developed by:",
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Samer Walaa\nsamer.walaa18@gmail.com",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              "Bola Eshak\nbola.ishak41@gmail.com",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 13),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Footer note
        Text(
          "Made with ❤️ for God’s glory",
          style: GoogleFonts.cairo(fontSize: 13),
        ),

      ],
    );
  }

  Widget _buildLandscapeContent(double cardHeight) {
    // Left: icon + spinner (centered), Right: texts and credits (scrollable if needed)
    return SizedBox(
      height: cardHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _crossAnimation,
                  child: const Icon(
                    Icons.church,
                    size: 80,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 14),
                const SizedBox(
                  height: 36,
                  width: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "تطبيق تأملاتى",
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "ابدأ رحلتك اليومية مع كلمة الرب — تأمل، صلِ، وسجل ما يحرك قلبك.",
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Developed by:",
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Samer Walaa\nsamer.walaa18@gmail.com",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Bola Eshak\nbola.ishak41@gmail.com",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Made with ❤️ for God’s glory",
                    style: GoogleFonts.cairo(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = 720.0;
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    // For landscape card height (so content is centered and not too tall)
    final cardHeight = isLandscape
        ? (media.size.height * 0.6).clamp(220.0, 420.0)
        : null;

    return Scaffold(
      body: Stack(
        children: [
          /// --- Background Image ---
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/landing_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// --- Pale Overlay ---
          Container(
            color: Colors.white.withOpacity(0.3), // soft pale overlay
          ),

          /// --- Main Content in a Card (matches monthly_data style) ---
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white.withOpacity(0.95),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 28.0,
                        ),
                        child: isLandscape
                            ? _buildLandscapeContent(cardHeight!)
                            : _buildPortraitContent(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ...existing code...