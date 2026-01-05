import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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

      // Decide initial route depending on local DB registration
      bool registered = false;
      try {
        // ensure DB is initialized and check if a profile exists
        registered = await DatabaseService.instance.isUserRegistered();
      } catch (_) {
        registered = false;
      }
      if (!registered) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/register', (route) => false);
        return;
      } else {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 14),

        // Short description
        Text(
          "ابدأ رحلتك اليومية مع كلمة الرب — تأمل، صلِ، وسجل ما يحرك قلبك.",
          style: TextStyle(
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              "Samer Walaa\nsamer.walaa18@gmail.com",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              "Bola Eshak\nbola.ishak41@gmail.com",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Footer note
        Text("Made with ❤️ for God’s glory", style: TextStyle(fontSize: 13)),
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
                  child: Image.asset(
                    'assets/icons/al_mktb.jpg', // Your image path
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "ابدأ رحلتك اليومية مع كلمة الرب — تأمل، صلِ، وسجل ما يحرك قلبك.",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Developed by:",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Samer Walaa\nsamer.walaa18@gmail.com",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Bola Eshak\nbola.ishak41@gmail.com",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Made with ❤️ for God’s glory",
                    style: TextStyle(fontSize: 13),
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // // Top bar with an optional debug action to clear registration
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     IconButton(
                            //       tooltip: 'حذف بيانات التسجيل',
                            //       icon: Icon(Icons.delete_forever, color: Colors.brown[700]),
                            //       onPressed: () async {
                            //         final confirm = await showDialog<bool>(
                            //           context: context,
                            //           builder: (ctx) => AlertDialog(
                            //             title: Text('تأكيد', style: TextStyle()),
                            //             content: Text('هل تريد حذف بيانات التسجيل حتى تتمكن من الاختبار مرة أخرى؟', style: TextStyle()),
                            //             actions: [
                            //               TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('إلغاء', style: TextStyle())),
                            //               TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('حذف', style: TextStyle(color: Colors.red))),
                            //             ],
                            //           ),
                            //         );

                            //         if (confirm == true) {
                            //           try {
                            //             final db = await DatabaseService.instance.database;
                            //             await db.delete('user_profile', where: 'id = ?', whereArgs: [1]);
                            //             await AuthStorage.deleteToken();
                            //           } catch (e) {
                            //             // ignore or show error
                            //           }

                            //           // Navigate to register page to allow re-testing
                            //           if (mounted) {
                            //             Navigator.of(context).pushReplacementNamed('/register');
                            //           }
                            //         }
                            //       },
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(height: 8),
                            // Then the original page content
                            (isLandscape
                                ? _buildLandscapeContent(cardHeight!)
                                : _buildPortraitContent()),
                          ],
                        ),
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
