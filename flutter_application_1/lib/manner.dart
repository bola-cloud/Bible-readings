import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:flutter_application_1/loading.dart';
import 'package:google_fonts/google_fonts.dart';

class Manner extends StatefulWidget {
  const Manner({super.key});

  @override
  State<Manner> createState() => _MannerState();
}

class _MannerState extends State<Manner> {
  final DatabaseService _database_service = DatabaseService.instance;
  TextEditingController? _mannerController;

  int? month;
  bool _isLoaded = false; // prevent multiple loads
  bool _isLoading = true;

  // Page view state
  late PageController _pageController;
  late VoidCallback _pageListener; // store listener so it can be removed correctly
  int _currentPage = 0;
  double _page = 0.0; // track page position for hovering effect

  // Example stages content (you can replace texts with exact content)
  final List<Map<String, String>> _stages = [
    {
      'title': '١ - اطلب حضور الله',
      'body': 'اجلس دقيقة صامت: قل: "يارب، افتح عينى أشوف يومى بنورك."',
    },
    {
      'title': '٢ - قل شكراً',
      'body': 'اكتب أو فكر فى النعم اللى ربنا اعطاهالك النهاردة. مثال: كلمة طيبة، مساعدة من صديق.',
    },
    {
      'title': '٣ - راجع يومك',
      'body': 'راجع على مواقف يومك: أين كنت قريب من ربنا؟ أين جرحت محبة؟',
    },
    {
      'title': '٤ - اطلب المغفرة',
      'body': 'صلِ وقل: "سامحنى يا رب" وادرب قلب جديد.',
    },
    {
      'title': '٥ - خذ قرار صغير للغد',
      'body': 'اختر خطوة بسيطة: مساعد صديق، كلمة تشجيع، التزام بالصلاة.',
    },
  ];

  // per-step notes loaded from DB
  Map<int, String> _stepNotes = {};

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load only once
    if (!_isLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      month = args?['month'] as int?;

      if (month != null) {
        _loadData(month!);
      }

      _isLoaded = true;
    }
  }

  Future<void> _loadData(int month) async {
    // load per-step notes map (uses new DB helper that returns JSON-decoded map)
    final map = await _database_service.getMonthMannerMap(month);

    if (!mounted) return;
    setState(() {
      _stepNotes = map;
      // set controller to the current page's note (index 0 by default)
      _mannerController?.text = _stepNotes[_currentPage] ?? '';
      _isLoading = false;
    });
  }

  String intToArabic(dynamic n) {
    const english = "0123456789";
    const arabic = "٠١٢٣٤٥٦٧٨٩";

    String s = n.toString();

    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(english[i], arabic[i]);
    }

    return s;
  }

  String getArabicMonthName(int month) {
    const arabicMonths = [
      "شهر يناير",
      "شهر فبراير",
      "شهر مارس",
      "شهر أبريل",
      "شهر مايو",
      "شهر يونيو",
      "شهر يوليو",
      "شهر أغسطس",
      "شهر سبتمبر",
      "شهر أكتوبر",
      "شهر نوفمبر",
      "شهر ديسمبر",
    ];

    if (month < 1 || month > 12) return "فضيله شهر غير معروف"; // fallback
    return "فضيله ${arabicMonths[month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    // Design colors matched to SujoodHour: soft peach card, maroon titles/body
    const Color cardBackground = Color(0xFFF8EDE0); // soft peach
    const Color titleColor = Color(0xFF6B2626); // maroon for titles
    const Color bodyColor = Color(0xFF6B2626);

    final titleTextStyle = GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: titleColor);
    final bodyTextStyle = GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: bodyColor, height: 1.6);
    final noteTitleStyle = GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: bodyColor);

    return _isLoading
        ? Loading()
        : Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(getArabicMonthName(month ?? 0), style: GoogleFonts.cairo()),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    // Return to Home directly
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  },
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
              body: Stack(
                children: [
                  // Background
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img/background.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Pale overlay
                  Container(color: Colors.white.withOpacity(0.30)),

                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // PageView with stage cards (hovering center card)
                          const SizedBox(height: 40),
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _stages.length,
                              onPageChanged: (idx) async {
                                setState(() {
                                  _currentPage = idx;
                                });
                                // update controller to show the note for the newly visible step
                                final note = _stepNotes[_currentPage] ?? '';
                                if (_mannerController?.text != note) {
                                  _mannerController?.text = note;
                                }
                              },
                              itemBuilder: (context, index) {
                                final stage = _stages[index];
                                // compute scale based on distance from current page
                                final double distance = (_page - index).abs();
                                final double scale = (1 - (distance * 0.12)).clamp(0.88, 1.0);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                                  child: Transform.scale(
                                    scale: scale,
                                    alignment: Alignment.center,
                                    child: Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      color: cardBackground,
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Align(
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                width: 56,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0,2))],
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    index == 0 ? Icons.church : (index == 1 ? Icons.self_improvement : Icons.auto_awesome),
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

                          const SizedBox(height: 12),

                          // Dots only (no buttons), use _page to pick active
                          Row(
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

                          const SizedBox(height: 12),

                          // Notes card (styled to match SujoodHour aesthetic)
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: Colors.white.withOpacity(0.95),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text('ملاحظات', style: noteTitleStyle, textAlign: TextAlign.center),
                                  const SizedBox(height: 8),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(minHeight: 120, maxHeight: 200),
                                    child: TextField(
                                      controller: _mannerController,
                                      maxLines: null,
                                      expands: false,
                                      style: GoogleFonts.cairo(fontSize: 15, color: bodyColor),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'كيف طبقت هذه الخطوة؟',
                                        hintStyle: GoogleFonts.cairo(color: Colors.black45),
                                      ),
                                      onChanged: (value) async {
                                        if (month != null) {
                                          // save per-step note
                                          await _database_service.updateMonthMannerStep(month!, _currentPage, value);
                                          // update local cache
                                          _stepNotes[_currentPage] = value;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
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
