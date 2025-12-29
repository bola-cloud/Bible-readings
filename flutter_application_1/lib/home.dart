import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/modules/data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/services/auth_storage.dart';
import 'package:flutter_application_1/database_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Opacity(
            opacity: 1 - opacity,
            child: Text(
              'خطوة بخطوة',
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
          actions: [
            IconButton(
              icon: Icon(Icons.person, color: Colors.brown[900], size: 30,),
              onPressed: () async {
                // Open profile if token exists, otherwise redirect to register
                try {
                  final token = await AuthStorage.getToken();
                  if (token != null && token.isNotEmpty) {
                    Navigator.pushNamed(context, '/profile');
                    return;
                  }

                  // fallback: if local DB has registered profile, still try to open profile
                  final registered = await DatabaseService.instance.isUserRegistered();
                  if (registered) {
                    Navigator.pushNamed(context, '/profile');
                    return;
                  }

                  // otherwise, send user to register
                  Navigator.pushNamed(context, '/register');
                } catch (e) {
                  Navigator.pushNamed(context, '/register');
                }
              },
            ),
          ],
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
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'كل طريق روحي حقيقي يبدأ بخطوة صغيرة... خطوة صادقة نحو ربنا يسوع.',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.brown[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
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
                              title: 'خطواتى',
                              subtitle:
                                  'كل الخطوات اللى انت محتاجها علشان تعرف تعيش افضل تجربة معانا',
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.web_stories_sharp,
                                  color: Colors.orange,
                                ),
                              ),
                              color: Colors.orange.shade200.withOpacity(0.9),
                              onTap: () async {
                                Navigator.pushNamed(context, '/howTo');
                              },
                            ),
                          ),

                          SizedBox(
                            width: isWide
                                ? (constraints.maxWidth / 2 - 26)
                                : constraints.maxWidth,
                            child: _buildCard(
                              title: 'تأملاتى',
                              subtitle:
                                  'تأملات من الكتاب المقدس تساعدك ان تفهم كلام الرب تعيشها في حياتك اليومية',
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.book,
                                  color: Colors.orange,
                                ),
                              ),
                              color: Colors.yellow.shade100.withOpacity(0.9),
                              onTap: () async {
                                Navigator.pushNamed(context, '/calendar');
                              },
                            ),
                          ),

                          SizedBox(
                            width: isWide
                                ? (constraints.maxWidth / 2 - 26)
                                : constraints.maxWidth,
                            child: _buildCard(
                              title: 'جدول متابعة شهرى',
                              subtitle:
                                  'تقدر من خلاله نتائج ممارساتك الروحية',
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.orange,
                                ),
                              ),
                              color: Colors.orange.shade200.withOpacity(0.9),
                              onTap: () async {
                                Navigator.pushNamed(context, '/monthly_data');
                              },
                            ),
                          ),

                          SizedBox(
                            width: isWide
                                ? (constraints.maxWidth / 2 - 26)
                                : constraints.maxWidth,
                            child: _buildCard(
                              title: 'أنجازاتى',
                              subtitle: 'شوف بطاريتك الروحية وصلت لفين',
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                ),
                              ),
                              color: Colors.yellow.shade100.withOpacity(0.9),
                              onTap: () {
                                Navigator.pushNamed(context, '/statistics');
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Footer / note
                      Text(
                        'الفكرة مش إنك تملأ الحاجات وخلاص... لكن إنك تنمو روحياً وتكتشف جمال الحياة مع ربنا بخطوات بسيطة لكن ثابتة. ابدأ انهردا المشوار...خطوة بخطوة و ربنا هو اللى هيكمل معاك المشوار.',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.brown[700],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // ),
    );
  }
}
