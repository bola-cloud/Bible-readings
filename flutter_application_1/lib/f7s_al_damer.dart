import 'package:flutter/material.dart';

class F7sAlDamer extends StatefulWidget {
  const F7sAlDamer({super.key});

  @override
  State<F7sAlDamer> createState() => _F7sAlDamerState();
}

class _F7sAlDamerState extends State<F7sAlDamer> {
  TextEditingController? _mannerController;

  // Page view state
  late PageController _pageController;
  late VoidCallback
  _pageListener; // store listener so it can be removed correctly
  double _page = 0.0; // track page position for hovering effect

  // Example stages content (you can replace texts with exact content)
  final List<Map<String, String>> _stages = const [
    {
      'title': '١- اطلب حضور الله',
      'body': 'اجلس دقيقة صامت.\nقل: "يا رب، افتح عيني أشوف يومي بنورك."',
    },
    {
      'title': '٢- قُل شكرًا',
      'body':
          'اكتب أو فكّر في ٣ نعم ربنا أعطاهالك النهاردة.\nمثال: كلمة طيبة، مساعدة من صديق، لحظة فرح.',
    },
    {
      'title': '٣- راجِع يومك',
      'body':
          'مرّ على مواقف يومك من أوله لآخره.\nاسأل نفسك:\nفين كنت قريب من ربنا؟\nفين جرحت محبة ربنا أو الآخر؟',
    },
    {
      'title': '٤- اطلب الغفران',
      'body':
          'قرر فى اقرب وقت انك تروح لابونا و تمارس سر المصالحة\nصلى وقل: "سامحني يا رب، واديني قلب جديد."',
    },
    {
      'title': '٥- خُد قرار صغير للغد',
      'body':
          'اختار خطوة بسيطة:\nهساعد صديق.\nهقول كلمة تشجيع.\nهلتزم بالصلاة.',
    },
  ];

  final List<IconData> examinationIcons = [
    Icons.person_search, // ١- اطلب حضور الله (Ask for God's presence)
    Icons.emoji_emotions, // ٢- قُل شكرًا (Say thanks)
    Icons.timeline, // ٣- راجِع يومك (Review your day)
    Icons.handshake, // ٤- اطلب الغفران (Ask for forgiveness)
    Icons.directions_run, // ٥- خُد قرار صغير للغد (Take a small decision)
  ];

  @override
  void initState() {
    super.initState();
    _mannerController = TextEditingController();
    // create a PageController with viewportFraction to show neighboring cards
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
    _mannerController?.dispose();
    // remove the exact listener we added in initState
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Design colors matched to SujoodHour: soft peach card, maroon titles/body
    const Color cardBackground = Color(0xFFF8EDE0); // soft peach
    Color titleColor = Colors.brown[700]!; // maroon for titles
    const Color bodyColor = Color(0xFF6B2626);

    final titleTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: titleColor,
    );
    final bodyTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: bodyColor,
      height: 1.6,
    );
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
          title: Text(
            'خطوات فحص الضمير',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.brown[900],
            ),
          ),
        ),
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Pale overlay
            Container(color: Colors.white.withOpacity(0.30)),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // PageView with stage cards (hovering center card)
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: SizedBox(
                        height: isWide ? 360 : 420,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _stages.length,
                          itemBuilder: (context, index) {
                            final stage = _stages[index];
                            // compute scale based on distance from current page
                            final double distance = (_page - index).abs();
                            final double scale = (1 - (distance * 0.12)).clamp(
                              0.88,
                              1.0,
                            );

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 10.0,
                              ),
                              child: Transform.scale(
                                scale: scale,
                                alignment: Alignment.center,
                                child: Card(
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  color: cardBackground,
                                  child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                examinationIcons[index],
                                                color: titleColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          stage['title'] ?? '',
                                          style: titleTextStyle,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Text(
                                              stage['body'] ?? '',
                                              style: bodyTextStyle,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Dots only (no buttons), use _page to pick active
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_stages.length, (i) {
                          final Color active = titleColor;
                          final bool isActive = (_page.round() == i);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: (isActive ? 16.0 : 8.0),
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive ? active : Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'فحص الضمير مش لحساب قاسي، لكن هو وقت حبّ أتعلم فيه أكون صادق قدام ربنا، شاكر لنِعمه، وطالب قوة جديدة.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.brown[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
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
