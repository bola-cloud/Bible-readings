import 'package:flutter/material.dart';

class Masba73a2ly extends StatefulWidget {
  const Masba73a2ly({super.key});

  @override
  State<Masba73a2ly> createState() => _Masba73a2lyState();
}

class _Masba73a2lyState extends State<Masba73a2ly> {
  final List<Map<String, String>> _steps = const [
    {
      'title': '١ - اختيار مكان ثابت في البيت',
      'body': 'اختَر مكانًا هادئًا ونظيفًا — ركن صغير فيه صليب، أيقونة، صورة للرب، شمعة وكتاب مقدس.'
    },
    {
      'title': '٢ - تحديد وقت ثابت',
      'body': 'مثل بعد العشاء أو قبل النوم عشان يبقى عادة منتظمة لكل الأسرة.'
    },
    {
      'title': '٣ - تجهيز الأدوات',
      'body': 'الكتاب المقدس، ترانيم، دفتر صغير لتدوين الطلبات أو التأملات.'
    },
    {
      'title': '٤ - بداية بالصلاة الافتتاحية',
      'body': '"باسم الآب والابن والروح القدس، إله واحد آمين."\nصلاة قصيرة يشارك فيها أحد أفراد الأسرة (مثلاً: “يا رب بارك اجتماعنا وافتح أذهاننا لكلمتك”).'
    },
    {
      'title': '٥ - قراءة نص كتابي قصير',
      'body': 'ممكن يكون من إنجيل اليوم أو حسب خطة القراءة المنتظمة.'
    },
    {
      'title': '٦ - فكرة وتأمل بسيط',
      'body': 'تعليق قصير من الأب أو الأم أو أحد الأولاد عن معنى النص.\nسؤال للتأمل: “إيه اللي ربنا عاوز يقوله لي النهارده؟”'
    },
    {
      'title': '٧ - ترنيمة أو مزمور',
      'body': 'ممكن ترنيمة يعرفها الجميع أو مزمور'
    },
    {
      'title': '٨ - وقت صلاة حرة',
      'body': 'كل فرد يقول طلبة أو شكر بسيط'
    },
    {
      'title': '٩ - الصلاة الختامية',
      'body': 'ممكن تكون “أبانا الذي...” أو أي صلاة محفوظة للأسرة.'
    },
  ];

  late final PageController _pageController;
  double _page = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78);
    _pageController.addListener(() {
      setState(() {
        _page = _pageController.page ?? _pageController.initialPage.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCard(BuildContext context, Map<String, String> step, int index) {
    const Color cardColor = Color(0xFFF8EDE0);
    Color titleColor = Colors.brown[700]!;
    const Color bodyColor = Color(0xFF7A2B2B);

    final double distance = (_page - index).abs();
    final double scale = (1 - (distance * 0.12)).clamp(0.88, 1.0);

    IconData icon;
    switch (index) {
      case 0:
        icon = Icons.home;
        break;
      case 1:
        icon = Icons.schedule;
        break;
      case 2:
        icon = Icons.chrome_reader_mode;
        break;
      case 3:
        icon = Icons.self_improvement;
        break;
      case 4:
        icon = Icons.menu_book;
        break;
      case 5:
        icon = Icons.music_note;
        break;
      case 6:
        icon = Icons.lightbulb;
        break;
      case 7:
        icon = Icons.volunteer_activism;
        break;
      case 8:
      default:
        icon = Icons.check_circle;
        break;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.center,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: Offset(0,2))],
                  ),
                  child: Center(child: Icon(icon, color: Colors.brown)),
                ),
                const SizedBox(height: 10),
                Text(
                  step['title'] ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: titleColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  step['body'] ?? '',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: bodyColor, height: 1.6),
                  textAlign: TextAlign.center,
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'خطوات صلاة المذبح العائلي',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.brown[900]),
          ),
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
                    const SizedBox(height: 8),
                    Text(
                      'صلّوا معًا كأسرة بطريقة بسيطة ومنظمة — اجعلوها عادة محبة.',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.brown[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: SizedBox(
                        height: isWide ? 360 : 420,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _steps.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: isWide ? 12 : 10),
                              child: _buildCard(context, _steps[index], index),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_steps.length, (i) {
                          final Color active = Colors.brown[700]!;
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