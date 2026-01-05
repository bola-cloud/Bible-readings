import 'package:flutter/material.dart';

class DailyMeditation extends StatefulWidget {
  const DailyMeditation({super.key});

  @override
  State<DailyMeditation> createState() => _DailyMeditationState();
}

class _DailyMeditationState extends State<DailyMeditation> {
  final List<Map<String, String>> _items = const [
    {
      'title': '١- حضِّر وقتك ومكانك',
      'body':
          'اختار وقت ثابت كل يوم (الصبح بدري أو قبل النوم).\nاختار مكان هادئ بعيد عن الضوضاء، يفضل يكون ليك فيه ركن صلاة.',
    },
    {
      'title': '٢- اطلب حضور الله',
      'body':
          'اجلس دقيقة صامت: هدي نفسك وابعد عن الضوضاء الخارجية والداخلية.\nاستدعاء الروح القدس: قل: "يا رب، افتح ذهني علشان أفهم كلامك وأعيشه." أو صلي صلاة من قلبك',
    },
    {
      'title': '٣- اقرأ النص الكتابي',
      'body':
          'افتح الكتاب المقدس على النص المحدد من كراسة المتابعة.\nاقرأه ببطء وتأمل في الكلمات.',
    },
    {
      'title': '٤- توقّف عند كلمة أو فكرة',
      'body': 'اسأل نفسك:\nإيه الكلمة اللي لمست قلبي؟\nليه الكلمة دي شدتني؟',
    },
    {
      'title': '٥- صلِّ بالكلمة',
      'body':
          'كلّم ربنا بالكلمة اللي سمعتها.\nخلي النص يتحول لصلاة شخصية: شكر، طلب، توبة أو رجاء.',
    },
    {
      'title': '٦- خُد قرار عملي',
      'body':
          'اختار خطوة صغيرة من النص تعيشها النهاردة.\nمثال: "هسامح اللي ضايقني" – "هساعد شخص محتاج" – "هصلي قبل ما أنام".',
    },
    {
      'title': '٧- اكتُب تأملك',
      'body':
          'في آخر الوقت، اكتب جملة أو اتنين عن:\nالكلمة اللي لمستك.\nالقرار اللي أخدته.\n\nالكتابة تساعدك تفتكر وتتابع نموك الروحي.',
    },
    {
      'title': '٨- اختم بالشكر',
      'body': 'قل: "أشكرك يا رب على كلمتك. ساعدني أعيشها."',
    },
  ];

  final List<IconData> meditationIcons = [
    Icons.schedule, // 1. حضِّر وقتك ومكانك (Prepare time & place)
    Icons.person_search, // 2. اطلب حضور الله (Ask for God's presence)
    Icons.menu_book, // 3. اقرأ النص الكتابي (Read scripture)
    Icons.lightbulb, // 4. توقّف عند كلمة أو فكرة (Pause at a word or idea)
    Icons.self_improvement, // 5. صلِّ بالكلمة (Pray with the word)
    Icons.directions_run, // 6. خُد قرار عملي (Take practical decision)
    Icons.edit_note, // 7. اكتُب تأملك (Write your meditation)
    Icons.emoji_emotions, // 8. اختم بالشكر (Close with thanksgiving)
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
    Color titleColor = Colors.brown[700]!;
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(meditationIcons[index], color: Colors.brown),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['title'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    item['body'] ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: bodyColor,
                      height: 1.6,
                    ),
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
          title: Text(
            'خطوات التأمل اليومي',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.brown[900],
            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'التأمل ليس مجرد قراءة، لكنه موعد حب بينك وبين يسوع. اختر وقتًا ثابتًا وكل يوم اقرأ وتأمل واكتب.',
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

                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: SizedBox(
                        height: isWide ? 360 : 420,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _items.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 12 : 10,
                              ),
                              child: _buildCard(context, _items[index], index),
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
                        children: List.generate(_items.length, (i) {
                          final Color active = Colors.brown[700]!;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: ((_page.round() == i) ? 16 : 8).toDouble(),
                            height: 8,
                            decoration: BoxDecoration(
                              color: (_page.round() == i)
                                  ? active
                                  : Colors.grey,
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
                          'التأمل مش مجرد قراءة، لكنه موعد حبّ بينك وبين يسوع. الوقت والمكان الثابت يخلوه عادة يومية، والكتابة بتخلي الكلمة متجذرة في حياتك.',
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
