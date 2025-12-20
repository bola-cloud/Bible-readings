import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SujoodHour extends StatefulWidget {
  const SujoodHour({super.key});

  @override
  State<SujoodHour> createState() => _SujoodHourState();
}

class _SujoodHourState extends State<SujoodHour> {
  final List<Map<String, String>> _steps = const [
    {
      'title': '١ - حضر وقتك ومكانك',
      'body':
          'ادخل الكنيسة إلى بيت القربان في صمت.\n خلِ بالك إنك داخل لحضور يسوع الحقيقي في سر الإفخارستيا.',
    },
    {
      'title': '٢ - الدخول بسجود الجسد',
      'body':
          'عند دخولك، أعمل انحناءة عميقة أو ركوع على الركبتين علامه اكرام للمسيح الحاضر.',
    },
    {
      'title': '٣ - اطلب حضور الروح القدس',
      'body':
          'اجلس بهدوء على ركبتيك.\nاطلب من الروح القدس ينقي قلبك ويملأك بالسلام.',
    },
    {
      'title': '٤ - زمن الصمت',
      'body':
          'اقعد في صمت أمام يسوع، زي صديق يقعد مع صديقه.\nمش ضروري تتكلم كثير، الأهم هو الحضور.',
    },
    {
      'title': '٥ - قراءة أو تأمل قصير',
      'body':
          'ممكن تقرأ آية من الكتاب المقدس.\n ركز عليها وخليها تربطك بيسوع الحاضر قدامك.',
    },
    {
      'title': '٦ - صلِ من قلبك',
      'body':
          'كلم يسوع بحرية؛\n اشكره على حضوره،\n احكي له همومك وطلباتك\nقدم له حياتك وأحبابك.',
    },
    {
      'title': '٧ - زمن التأمل الصامت',
      'body':
          'بعد الصلاة اقعد ساكت وخلي قلبك مفتوح.\nالسجود مش بس كلام، هو تذوق لحضور الله في الهدوء.',
    },
    {
      'title': '٨ - التقدمة والقرار',
      'body':
          'قدم نفسك ليسوع: "خذني يا رب املك على قلبى."\n اختار قرار عملي صغير تعيشه بعد ما تخرج: محبة, امانه, خدمة ....',
    },
    {
      'title': '٩ - كتابة الخبرة',
      'body':
          'بعد ما تخلص. اكتب:\nإيه اللي حسيت بيه أو الكلمة اللي لمستك،\nالقرار اللي أخدته مع يسوع.',
    },
  ];

  final List<IconData> adorationIcons = [
    Icons.place, // 1. حضِّر وقتك ومكانك (Prepare time & place)
    Icons.downhill_skiing, // 2. الدخول بسجود الجسد (Physical prostration)
    Icons.person_pin, // 3. اطلب الحضور (Ask for presence)
    Icons.volume_off, // 4. زمن الصمت (Silent time)
    Icons.menu_book, // 5. قراءة أو تأمل قصير (Reading/short meditation)
    Icons.chat, // 6. صلِّ من قلبك (Pray from your heart)
    Icons.self_improvement, // 7. زمن التأمل الصامت (Silent meditation time)
    Icons.volunteer_activism, // 8. التقدمة والقرار (Offering & decision)
    Icons.edit_note, // 9. كتابة الخبرة (Writing experience)
  ];

  late final PageController _pageController;
  double _page = 0.0;

  @override
  void initState() {
    super.initState();
    // viewportFraction < 1 creates space for the neighboring cards; adjust for hover look
    _pageController = PageController(viewportFraction: 0.78);
    _pageController.addListener(() {
      setState(() {
        _page = _pageController.page ?? _pageController.initialPage.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(() {});
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCard(BuildContext context, Map<String, String> step, int index) {
    const Color cardColor = Color(0xFFF8EDE0); // soft peach
    const Color titleColor = Color(0xFF6B2626); // maroon for titles
    const Color bodyColor = Color(0xFF6B2626);

    // compute scale based on distance from current page
    final double distance = (_page - index).abs();
    final double scale = (1 - (distance * 0.12)).clamp(0.88, 1.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.center,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 18.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // small circular icon placeholder
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(child: Icon(adorationIcons[index], color: Colors.brown)),
                ),
                const SizedBox(height: 8),
                Text(
                  step['title'] ?? '',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  step['body'] ?? '',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: bodyColor,
                    height: 1.6,
                  ),
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
            'خطوات ساعة السجود',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6B2626),
            ),
          ),
        ),
        body: Stack(
          children: [
            // background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // pale overlay
            Container(color: Colors.white.withOpacity(0.30)),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Swiper area: horizontal PageView with hovering center card
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'السجود أمام القربان هو مدرسة حب وصدق... كن حاضرًا بكل قلبك',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B2626),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: SizedBox(
                        height: isWide ? 360 : 420,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _steps.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 12 : 10,
                              ),
                              child: _buildCard(context, _steps[index], index),
                            );
                          },
                        ),
                      ),
                    ),

                    // indicators (dots)
                    const SizedBox(height: 12),

                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_steps.length, (i) {
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
                    ),

                    // footer note area (like design)
                    const SizedBox(height: 12),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'السجود أمام القربان هو مدرسة حب وصداقة. مش شرط يكون فيه كلام كتير، يكفي إنك تكون حاضر بكل قلبك قدام يسوع الحاضر حقًا.',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B2626),
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
