import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:flutter_application_1/loading.dart';

class Saint extends StatefulWidget {
  const Saint({super.key});

  @override
  State<Saint> createState() => _SaintState();
}

class _SaintState extends State<Saint> {
  final DatabaseService _database_service = DatabaseService.instance;
  TextEditingController? _mannerController;

  int? month;
  bool _isLoaded = false; // prevent multiple loads
  bool _isLoading = true;
  String img = "";
  String title = "";

  // Page view state
  late PageController _pageController;
  late VoidCallback
  _pageListener; // store listener so it can be removed correctly
  double _page = 0.0; // track page position for hovering effect

  // Example stages content (you can replace texts with exact content)
  List<dynamic> _stages = [];

  // per-step notes loaded from DB
  String note = "";

  // Icons for the 4 common stage titles across all saints
  final List<IconData> stageIcons = [
    Icons.badge, // بطاقته/بطاقتها (Badge/Card)
    Icons.history_edu, // قصته/قصتها (Story/History)
    Icons.star, // فضيلته/فضيلتها (Virtue/Star quality)
    Icons.message, // رسالة لينا (Message to us)
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
    final note = await _database_service.getMonthManner(month);
    final img = await _database_service.getMonthSaintImage(month);
    final title = await _database_service.getMonthSaintName(month);
    final stages = await _database_service.getMonthSaintStages(month);

    if (!mounted) return;
    setState(() {
      this.img = img ?? "";
      this.title = title ?? "";
      this.note = note ?? "";
      _stages = stages;
      // set controller to the current page's note (index 0 by default)
      _mannerController?.text = this.note;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Design colors matched to SujoodHour: soft peach card, maroon titles/body
    const Color cardBackground = Color(0xFFF8EDE0); // soft peach
    Color titleColor = Colors.brown[700]!;

    final titleTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: titleColor,
    );
    final bodyTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: titleColor,
      height: 1.6,
    );

    final width = MediaQuery.of(context).size.width;
    final isWide = width > 700;

    return _isLoading
        ? Loading()
        : Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.brown[900],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    // Return to Home directly
                    Navigator.pop(context);
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
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(img),
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

                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: SizedBox(
                              height: isWide ? 360 : 420,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: _stages.length,
                                onPageChanged: (idx) async {
                                  // update controller to show the note for the newly visible step
                                  if (_mannerController?.text != note) {
                                    _mannerController?.text = note;
                                  }
                                },
                                itemBuilder: (context, index) {
                                  final stage = _stages[index];
                                  // compute scale based on distance from current page
                                  final double distance = (_page - index).abs();
                                  final double scale = (1 - (distance * 0.12))
                                      .clamp(0.88, 1.0);
                            
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
                                                      stageIcons[index],
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
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
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
