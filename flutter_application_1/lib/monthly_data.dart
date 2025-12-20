import 'package:flutter/material.dart';
import 'package:flutter_application_1/battery_widget.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:flutter_application_1/loading.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthlyData extends StatefulWidget {
  const MonthlyData({super.key});

  @override
  State<MonthlyData> createState() => _MonthlyDataState();
}

class _MonthlyDataState extends State<MonthlyData>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService.instance;
  TextEditingController? _notesController;

  DateTime displayedMonth = DateTime(2026, 1, 1);
  DateTime endMonth = DateTime(2026, DateTime.now().month, DateTime.now().day);

  List<bool>? toggles;
  bool _isLoading = true;
  bool _isFirstLoad = true;
  bool _noteEdited = false;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  bool _isAnimating = false;
  AnimationController? _animationController;
  Animation<double>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );

    _loadData(displayedMonth.month);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isFirstLoad) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      int month = args?['month'] as int? ?? 1;
      setState(() {
        displayedMonth = DateTime(2026, month, 1);
      });
      _loadData(month);
      setState(() {
        _isFirstLoad = false;
      });
    }
  }

  Future<void> _loadData(int month) async {
    if (_isFirstLoad) {
      setState(() {
        _isLoading = true;
      });
    }
    await _databaseService.feedMonthData();
    List<bool>? toggles = await _databaseService.getMonthAttendance(month);
    final noteContent = await _databaseService.getMonthNote(month);
    setState(() {
      this.toggles = toggles;
      _notesController?.text = noteContent ?? "";
      _isLoading = false;
      _isAnimating = false;
    });
  }

  List<DateTime> getWeeksInMonth(
    DateTime month, {
    int weekStart = DateTime.sunday,
  }) {
    List<DateTime> weeks = [];

    DateTime firstOfMonth = DateTime(month.year, month.month, 1);
    DateTime lastOfMonth = DateTime(month.year, month.month + 1, 0);

    DateTime currentWeekStart = firstOfMonth.subtract(
      Duration(days: (firstOfMonth.weekday - weekStart + 7) % 7),
    );

    while (currentWeekStart.isBefore(lastOfMonth) ||
        currentWeekStart.isAtSameMomentAs(lastOfMonth)) {
      weeks.add(currentWeekStart);
      currentWeekStart = currentWeekStart.add(Duration(days: 7));
    }

    return weeks;
  }

  void previousMonth() async {
    if (displayedMonth.month > 1 && !_isAnimating) {
      setState(() {
        _isAnimating = true;
      });

      await _animationController!.reverse(from: MediaQuery.of(context).size.width);

      setState(() {
        displayedMonth = DateTime(
          displayedMonth.year,
          displayedMonth.month - 1,
          1,
        );
      });
      await _loadData(displayedMonth.month);
      _animationController!.reset();
      setState(() {
        _isAnimating = false;
        _noteEdited = false;
      });
    }
  }

  void nextMonth() async {
    if (displayedMonth.month < 12 &&
        displayedMonth.month < endMonth.month &&
        !_isAnimating) {
      setState(() {
        _isAnimating = true;
      });

      await _animationController!.forward(from: 0.0);

      setState(() {
        displayedMonth = DateTime(
          displayedMonth.year,
          displayedMonth.month + 1,
          1,
        );
      });
      await _loadData(displayedMonth.month);
      _animationController!.reset();
      setState(() {
        _isAnimating = false;
        _noteEdited = false;
      });
    }
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

  double _calculateRowPercentage(int rowIndex) {
    if (toggles == null || toggles!.isEmpty) return 0.0;

    final weeks = getWeeksInMonth(displayedMonth);
    int columns = weeks.length + 1;

    int startIndex = rowIndex * columns;
    int endIndex = startIndex + columns - 1;

    int rowCount = 0;
    int rowTotal = 0;

    for (int i = startIndex; i < endIndex && i < toggles!.length; i++) {
      rowTotal++;
      if (toggles![i]) rowCount++;
    }

    return rowTotal > 0 ? rowCount / rowTotal : 0.0;
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

    if (month < 1 || month > 12) return "شهر غير معروف";
    return arabicMonths[month - 1];
  }

  String getWeekName(int index) {
    const arabicMonths = [
      "الاسبوع\nالاول",
      "الاسبوع\nالثانى",
      "الاسبوع\nالثالث",
      "الاسبوع\nالرابع",
      "الاسبوع\nالخامس",
      "الاسبوع\nالسادس",
    ];

    return arabicMonths[index];
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
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        textDirection: TextDirection.rtl,
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
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

    final weeks = getWeeksInMonth(displayedMonth);
    int totalCells = (weeks.length + 1) * 5;
    int columns = weeks.length + 1;

    return _isLoading
        ? Loading()
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Opacity(
                opacity: 1 - opacity,
                child: Text(
                  "${getArabicMonthName(displayedMonth.month)} ",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.brown[900]),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              actions: [
                Opacity(
                  opacity: _isAnimating ? 0 : 1,
                  child: IconButton(
                    onPressed: _isAnimating ? null : previousMonth,
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                Opacity(
                  opacity: _isAnimating ? 0 : 1,
                  child: IconButton(
                    onPressed: _isAnimating ? null : nextMonth,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
              ],
            ),
            body: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null || _isAnimating) return;

                if (details.primaryVelocity! < 0) {
                  nextMonth();
                } else if (details.primaryVelocity! > 0) {
                  previousMonth();
                }
              },
              child: Stack(
                children: [
                  // Background stays outside animation
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
                  Container(color: Colors.white.withOpacity(0.30)),

                  // AnimatedBuilder wraps only the scrollable content
                  AnimatedBuilder(
                    animation: _slideAnimation!,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_slideAnimation!.value * -50, 0),
                        child: Opacity(
                          opacity: 1 - _slideAnimation!.value.abs(),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 80),
                                  Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: Color(0xFFF8EDE0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  2 -
                                              20,
                                          child: _buildCard(
                                            title: 'قديس الشهر',
                                            subtitle:
                                                'تعرف على قديس الشهر وتتعلم من حياته',
                                            leading: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.orange,
                                              ),
                                            ),
                                            color: Colors.orange.shade50
                                                .withOpacity(0.95),
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/saint',
                                                arguments: {
                                                  "month": displayedMonth.month,
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        SizedBox(
                                          width:
                                              MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  2 -
                                              20,
                                          child: _buildCard(
                                            title: 'فضيلة الشهر',
                                            subtitle:
                                                'تعرف على فضيلة الشهر اللى ممكن تتدرب عليها',
                                            leading: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.star,
                                                color: Colors.orange,
                                              ),
                                            ),
                                            color: Colors.orange.shade100
                                                .withOpacity(0.95),
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/manner',
                                                arguments: {
                                                  "month": displayedMonth.month,
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    color: Color(0xFFF8EDE0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: SizedBox(
                                        height: 280 + (6 - weeks.length) * 40,
                                        child: GridView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: columns,
                                                childAspectRatio: 1,
                                              ),
                                          itemCount: totalCells,
                                          itemBuilder: (context, index) {
                                            if (index < columns) {
                                              if (index == columns - 1) {
                                                return Center(
                                                  child: Text(
                                                    "",
                                                    style: GoogleFonts.cairo(),
                                                  ),
                                                );
                                              }
                                              return Center(
                                                child: Column(
                                                  children: [
                                                    const Icon(
                                                      Icons.calendar_today,
                                                      size: 20,
                                                    ),
                                                    Text(
                                                      getWeekName(
                                                        columns - index - 2,
                                                      ),
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 10,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      textDirection:
                                                          TextDirection.rtl,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            if (index == columns * 2 - 1) {
                                              return Center(
                                                child: Text(
                                                  "حضور\nالقداس",
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: GoogleFonts.cairo(),
                                                ),
                                              );
                                            }
                                            if (index == columns * 3 - 1) {
                                              return Center(
                                                child: Text(
                                                  "حضور\nالاجتماع",
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: GoogleFonts.cairo(),
                                                ),
                                              );
                                            }
                                            if (index == columns * 4 - 1) {
                                              return Center(
                                                child: Text(
                                                  "المذبح\nالعائلى",
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: GoogleFonts.cairo(),
                                                ),
                                              );
                                            }
                                            if (index == columns * 5 - 1) {
                                              return Center(
                                                child: Text(
                                                  "ساعة\nالسجود",
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: GoogleFonts.cairo(),
                                                ),
                                              );
                                            }
                                            int toggleIndex = index - columns;
                                            bool isOn =
                                                toggles?[toggleIndex] ?? false;
                                            return Center(
                                              child: IconButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    toggles?[toggleIndex] =
                                                        !(toggles?[toggleIndex] ??
                                                            true);
                                                  });
                                                  await _databaseService
                                                      .updateMonthIndex(
                                                        displayedMonth.month,
                                                        toggleIndex,
                                                        toggles?[toggleIndex] ??
                                                            false,
                                                      );
                                                },
                                                icon: Icon(
                                                  isOn
                                                      ? Icons
                                                            .radio_button_checked
                                                      : Icons
                                                            .radio_button_unchecked,
                                                ),
                                                color: isOn
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: Color(0xFFF8EDE0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Opacity(
                                                opacity: 0,
                                                child: _noteEdited
                                                    ? ElevatedButton.icon(
                                                        onPressed: () {},
                                                        icon: Icon(Icons.save),
                                                        label: Text("حفظ"),
                                                      )
                                                    : SizedBox(
                                                        width: 0,
                                                        height: 0,
                                                      ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "سر المصالحة",
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              _noteEdited
                                                  ? ElevatedButton.icon(
                                                      onPressed: () async {
                                                        await _databaseService
                                                            .updateMonthNote(
                                                              displayedMonth
                                                                  .month,
                                                              _notesController!
                                                                  .text,
                                                            );
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
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  GoogleFonts.cairo(),
                                                            ),
                                                            duration: Duration(
                                                              seconds: 1,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons.save,
                                                        size: 18,
                                                      ),
                                                      label: Text(
                                                        "حفظ",
                                                        style:
                                                            GoogleFonts.cairo(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
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
                                          const SizedBox(height: 8),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minHeight: 120,
                                              maxHeight: 200,
                                            ),
                                            child: TextField(
                                              maxLines: null,
                                              expands: false,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText:
                                                    'لو عايز تعمل فحص ضمير او تكتب لنفسك حاجات عايز تفتكرها',
                                                hintStyle: GoogleFonts.cairo(),
                                              ),
                                              controller: _notesController,
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
                                  const SizedBox(height: 16),
                                  Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: Color(0xFFF8EDE0),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 12.0,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            "بطارياتك الشهر دة",
                                            style: GoogleFonts.cairo(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "نسبة حضور القداس",
                                            style: GoogleFonts.cairo(),
                                          ),
                                          const SizedBox(height: 8),
                                          BatteryWidget(
                                            percentage: _calculateRowPercentage(
                                              0,
                                            ),
                                            width: 200,
                                            height: 20,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "نسبة حضور الاجتماع",
                                            style: GoogleFonts.cairo(),
                                          ),
                                          const SizedBox(height: 8),
                                          BatteryWidget(
                                            percentage: _calculateRowPercentage(
                                              1,
                                            ),
                                            width: 200,
                                            height: 20,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "نسبة ممارسة المذبح العائلى",
                                            style: GoogleFonts.cairo(),
                                          ),
                                          const SizedBox(height: 8),
                                          BatteryWidget(
                                            percentage: _calculateRowPercentage(
                                              2,
                                            ),
                                            width: 200,
                                            height: 20,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "نسبة ممارسة ساعة السجود",
                                            style: GoogleFonts.cairo(),
                                          ),
                                          const SizedBox(height: 8),
                                          BatteryWidget(
                                            percentage: _calculateRowPercentage(
                                              3,
                                            ),
                                            width: 200,
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
