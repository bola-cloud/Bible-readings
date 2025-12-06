import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyMeditation extends StatefulWidget {
  const DailyMeditation({super.key});

  @override
  State<DailyMeditation> createState() => _DailyMeditationState();
}

class _DailyMeditationState extends State<DailyMeditation> {
  final List<Map<String, String>> _items = const [
    {'title': '١ - حضّر وقتك ومكانك', 'body': 'اختر وقت ثابت ومكان هادئ'},
    {'title': '٢ - اطلب حضور الله', 'body': 'اجلس دقيقة صامت واطلب حضور الروح القدس'},
    {'title': '٣ - اقرأ النص الكتابي', 'body': 'اقرأ ببطء وتأمل في كل كلمة من النص المختار'},
    {'title': '٤ - توقف عند كلمة أو آية', 'body': 'اسأل نفسك: ماذا تعني هذه الكلمة لي اليوم؟'},
    {'title': '٥ - صلّ بالكلمة', 'body': 'حوّل الكلمات إلى صلاة شخصية'},
    {'title': '٦ - اختر خطوة عمليّة', 'body': 'قرار عملي بسيط تطبقه اليوم لتعيش التأمل'},
    {'title': '٧ - اكتب خلاصة', 'body': 'سجل ما شعرت به والقرار الذي اتخذته'},
    {'title': '٨ - اختم بالشكر', 'body': 'اشكر الرب على كلمته وحضوره'},
    {'title': '٩ - طبق وانمُ', 'body': 'طبق القرار وراقب نمو حياتك الروحية'},
  ];

  late PageController _pageController;
  late VoidCallback _pageListener;
  double _page = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78);
    _pageListener = () {
      setState(() {
        _page = _pageController.page ?? _pageController.initialPage.toDouble();
      });
    };
    _pageController.addListener(_pageListener);
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCard(BuildContext context, Map<String, String> item, int index) {
    const Color cardColor = Color(0xFFF8EDE0); // soft peach
    const Color titleColor = Color(0xFF6B2626);
    const Color bodyColor = Color(0xFF6B2626);

    final double distance = (_page - index).abs();
    final double scale = (1 - (distance * 0.12)).clamp(0.88, 1.0);

    return Transform.scale(
      scale: scale,
      alignment: Alignment.center,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0,2))],
                ),
                child: Center(child: Icon(Icons.menu_book, color: Colors.brown)),
              ),
              const SizedBox(height: 8),
              Text(
                item['title'] ?? '',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: titleColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    item['body'] ?? '',
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: bodyColor, height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 700;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('خطوات التأمل اليومي', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF6B2626))),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(color: Colors.white.withOpacity(0.30)),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'التأمل ليس مجرد قراءة، لكنه موعد حب بينك وبين يسوع. اختر وقتًا ثابتًا وكل يوم اقرأ وتأمل واكتب.',
                          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF6B2626)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                    SizedBox(
                      height: isWide ? 360 : 420,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _items.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: isWide ? 12 : 10),
                            child: _buildCard(context, _items[index], index),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_items.length, (i) {
                        final Color active = const Color(0xFF6B2626);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: ((_page.round() == i) ? 16 : 8).toDouble(),
                          height: 8,
                          decoration: BoxDecoration(
                            color: (_page.round() == i) ? active : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 12),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
