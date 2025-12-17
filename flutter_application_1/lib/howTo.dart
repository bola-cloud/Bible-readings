import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/modules/data.dart';
import 'package:google_fonts/google_fonts.dart';

class HowTo extends StatefulWidget {
  const HowTo({super.key});

  @override
  State<HowTo> createState() => _HowToState();
}

class _HowToState extends State<HowTo> {
  Map<String, dynamic> data = {};
  Set<String> openedDays = {};
  Map<int, List<bool>> toggles = {};
  List<Data>? dataItems;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
    Widget? leading,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: title,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: color ?? Colors.orange.withOpacity(0.9),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(minHeight: 120),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                if (leading != null) ...[leading, const SizedBox(width: 12)],
                Expanded(
                  child: Column(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        textDirection: TextDirection.rtl,
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.brown[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Opacity(
          opacity: 1 - opacity,
          child: Text(
            'خطواتى',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.brown[900],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/background.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.90),
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
    
          // Pale overlay for readability
          Container(color: Colors.white.withOpacity(0.30)),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header image / title
                    const SizedBox(height: 80),
                    // Cards grid / list (7 cards total)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        SizedBox(
                          width: isWide
                              ? (constraints.maxWidth / 2 - 26)
                              : constraints.maxWidth,
                          child: _buildCard(
                            title: 'خطوات عمل تأمل',
                            subtitle:
                                'خطوات عملية للتأمل اليومي تساعدك تدخل الى كلمة الله وتسمع صوته',
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.menu_book,
                                color: Colors.orange,
                              ),
                            ),
                            color: Colors.orange.shade50.withOpacity(0.95),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/daily_meditation',
                              );
                            },
                          ),
                        ),
    
                        SizedBox(
                          width: isWide
                              ? (constraints.maxWidth / 2 - 26)
                              : constraints.maxWidth,
                          child: _buildCard(
                            title: 'خطوات عمل مذبح عائلى',
                            subtitle:
                                'خطوات عمل المذبح العائلي في البيت (الاجتماع الروحي العائلي اليومي أو الأسبوعي)',
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.family_restroom,
                                color: Colors.orange,
                              ),
                            ),
                            color: Colors.orange.shade100.withOpacity(0.95),
                            onTap: () {
                              Navigator.pushNamed(context, '/masba7_3a2ly');
                            },
                          ),
                        ),
    
                        SizedBox(
                          width: isWide
                              ? (constraints.maxWidth / 2 - 26)
                              : constraints.maxWidth,
                          child: _buildCard(
                            title: 'خطوات فحص الضمير',
                            subtitle:
                                'خطوات فحص الضمير تساعدك تراجع نفسك بصدق وتستعد للمواجهة مع الله',
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.self_improvement,
                                color: Colors.orange,
                              ),
                            ),
                            color: Colors.yellow.shade50.withOpacity(0.95),
                            onTap: () {
                              // Pass current month to the f7s_al_damer page
                              Navigator.pushNamed(
                                context,
                                '/f7s_al_damer',
                                arguments: {'month': DateTime.now().month},
                              );
                            },
                          ),
                        ),
    
                        SizedBox(
                          width: isWide
                              ? (constraints.maxWidth / 2 - 26)
                              : constraints.maxWidth,
                          child: _buildCard(
                            title: 'خطوات ساعة السجود',
                            subtitle:
                                'خطوات ساعة السجود امام القربان علشان تعيش لحظة لقاء عميق مع المسيح الحى فى السر الافخارستى',
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time,
                                color: Colors.orange,
                              ),
                            ),
                            color: Colors.orange.shade200.withOpacity(0.95),
                            onTap: () {
                              Navigator.pushNamed(context, "/sujood_hour");
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
