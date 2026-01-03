import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:flutter_application_1/loading.dart';

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
  bool _noteEdited = false;
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
    final img = await _database_service.getMonthFadilaImage(month);
    final title = await _database_service.getMonthFadilaName(month);
    final stages = await _database_service.getMonthFadilaStages(month);

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
    const Color bodyColor = Colors.black;

    final bodyTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.brown[700],
      height: 1.6,
    );

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
                            child: Expanded(
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
                                                      index == 0
                                                          ? Icons.church
                                                          : (index == 1
                                                                ? Icons
                                                                      .self_improvement
                                                                : Icons
                                                                      .auto_awesome),
                                                      color: titleColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              const SizedBox(height: 12),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Text(
                                                    stage['body'] ?? '',
                                                    style: bodyTextStyle,
                                                    textAlign: TextAlign.center,
                                                    textDirection: TextDirection.rtl,
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

                          // Notes card (styled to match SujoodHour aesthetic)
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white.withOpacity(0.95),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      // Invisible placeholder to balance the layout
                                      Opacity(
                                        opacity: 0,
                                        child: _noteEdited
                                            ? ElevatedButton.icon(
                                                onPressed: () {},
                                                icon: Icon(Icons.save),
                                                label: Text("حفظ"),
                                              )
                                            : SizedBox(width: 0, height: 0),
                                      ),

                                      // Centered title
                                      Expanded(
                                        child: Text(
                                          "ممارسة عملية",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      // Actual save button (visible)
                                      _noteEdited
                                          ? ElevatedButton.icon(
                                              onPressed: () async {
                                                if (month != null) {
                                                  // save per-step note
                                                  await _database_service
                                                      .updateMonthManner(
                                                        month!,
                                                        _mannerController!.text,
                                                      );
                                                  // update local cache
                                                  note =
                                                      _mannerController!.text;
                                                }
                                                setState(() {
                                                  _noteEdited = false;
                                                });
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "تم الحفظ",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          TextStyle(),
                                                    ),
                                                    duration: Duration(
                                                      seconds: 1,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(Icons.save, size: 18),
                                              label: Text(
                                                "حفظ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 8,
                                                    ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                  // Text(
                                  //   'ممارسة عمليه',
                                  //   style: noteTitleStyle,
                                  //   textAlign: TextAlign.center,
                                  // ),
                                  const SizedBox(height: 8),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: 120,
                                      maxHeight: 200,
                                    ),
                                    child: TextField(
                                      controller: _mannerController,
                                      maxLines: null,
                                      expands: false,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: bodyColor,
                                      ),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText:
                                            'ازاى طبقت الفضيله دى فى حياتك الشهر دة',
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _noteEdited = true;
                                        });
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
