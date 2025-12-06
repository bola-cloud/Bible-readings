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

class _MonthlyDataState extends State<MonthlyData> {
  final DatabaseService _databaseService = DatabaseService.instance;
  TextEditingController? _notesController;

  DateTime displayedMonth = DateTime.utc(2026, 1, 1);
  DateTime endMonth = DateTime.utc(2026, 5, 6);

  List<bool>? toggles;
  bool _isLoading = true;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _loadData(displayedMonth.month);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isFirstLoad) {
      // Read month from arguments if available
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
    await _databaseService.feedMonthData();
    List<bool>? toggles = await _databaseService.getMonthAttendance(month);
    final noteContent = await _databaseService.getMonthNote(month);
    setState(() {
      this.toggles = toggles;
      _notesController?.text = noteContent ?? "";
      _isLoading = false;
    });
  }

  // Get the first day of each week in the month
  List<DateTime> getWeeksInMonth(
    DateTime month, {
    int weekStart = DateTime.sunday,
  }) {
    List<DateTime> weeks = [];

    DateTime firstOfMonth = DateTime(month.year, month.month, 1);
    DateTime lastOfMonth = DateTime(month.year, month.month + 1, 0);

    // Start from the weekStart before or equal to the first day of the month
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
    if (displayedMonth.month > 1) {
      setState(() {
        displayedMonth = DateTime(
          displayedMonth.year,
          displayedMonth.month - 1,
          1,
        );
        _isLoading = true;
      });
      await _loadData(displayedMonth.month);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void nextMonth() async {
    if (displayedMonth.month < 12 && displayedMonth.month < endMonth.month) {
      setState(() {
        displayedMonth = DateTime(
          displayedMonth.year,
          displayedMonth.month + 1,
          1,
        );
        _isLoading = true;
      });
      await _loadData(displayedMonth.month);
      setState(() {
        _isLoading = false;
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

    int startIndex = rowIndex * columns; // row start in toggles
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

    if (month < 1 || month > 12) return "شهر غير معروف"; // fallback
    return arabicMonths[month - 1];
  }

  String getWeekName(int index) {
    const arabicMonths = [
      "الاسبوع الاول",
      "الاسبوع الثانى",
      "الاسبوع الثالث",
      "الاسبوع الرابع",
      "الاسبوع الخامس",
      "الاسبوع السادس",
    ];

    return arabicMonths[index];
  }

  @override
  Widget build(BuildContext context) {
    final weeks = getWeeksInMonth(displayedMonth);
    int totalCells = (weeks.length + 1) * 4; // 4 rows total

    int columns = weeks.length + 1;

    return _isLoading
        ? Loading()
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(
                "${getArabicMonthName(displayedMonth.month)} ",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
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
                IconButton(
                  onPressed: previousMonth,
                  icon: const Icon(Icons.arrow_back),
                ),
                IconButton(
                  onPressed: nextMonth,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            body: Stack(
              children: [
                // Background image
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

                // Main content
                SingleChildScrollView(
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

                        // Grid inside a card to match Home style
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white.withOpacity(0.85),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: SizedBox(
                              height: 270,
                              child: GridView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
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
                                            getWeekName(index),
                                            style: GoogleFonts.cairo(
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  if (index == columns * 2 - 1) {
                                    return Center(
                                      child: Text(
                                        "حضور القداس",
                                        textDirection: TextDirection.rtl,
                                        style: GoogleFonts.cairo(),
                                      ),
                                    );
                                  }

                                  if (index == columns * 3 - 1) {
                                    return Center(
                                      child: Text(
                                        "حضور الاجتماع",
                                        textDirection: TextDirection.rtl,
                                        style: GoogleFonts.cairo(),
                                      ),
                                    );
                                  }

                                  if (index == columns * 4 - 1) {
                                    return Center(
                                      child: Text(
                                        "المذبح العائلى",
                                        textDirection: TextDirection.rtl,
                                        style: GoogleFonts.cairo(),
                                      ),
                                    );
                                  }

                                  int toggleIndex = index - columns;
                                  bool isOn = toggles?[toggleIndex] ?? false;

                                  return Center(
                                    child: IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          toggles?[toggleIndex] =
                                              !(toggles?[toggleIndex] ?? true);
                                        });
                                        await _databaseService.updateMonthIndex(
                                          displayedMonth.month,
                                          toggleIndex,
                                          toggles?[toggleIndex] ?? false,
                                        );
                                      },
                                      icon: Icon(
                                        isOn
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                      ),
                                      color: isOn ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Battery bars inside card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white.withOpacity(0.85),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 12.0,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "نسبة حضور القداس فى الشهر",
                                  style: GoogleFonts.cairo(),
                                ),
                                const SizedBox(height: 8),
                                BatteryWidget(
                                  percentage: _calculateRowPercentage(0),
                                  width: 200,
                                  height: 20,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "نسبة حضور الاجتماع فى الشهر",
                                  style: GoogleFonts.cairo(),
                                ),
                                const SizedBox(height: 8),
                                BatteryWidget(
                                  percentage: _calculateRowPercentage(1),
                                  width: 200,
                                  height: 20,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "نسبة المذبح العائلى فى الشهر",
                                  style: GoogleFonts.cairo(),
                                ),
                                const SizedBox(height: 8),
                                BatteryWidget(
                                  percentage: _calculateRowPercentage(2),
                                  width: 200,
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Notes section in a card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white.withOpacity(0.85),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text(
                                    "سر المصالحة",
                                    style: GoogleFonts.cairo(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
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
                                    onChanged: (value) async {
                                      await _databaseService.updateMonthNote(
                                        displayedMonth.month,
                                        value,
                                      );
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
                          color: Colors.white.withOpacity(0.85),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/saint',
                                      arguments: {
                                        "month": displayedMonth.month,
                                      },
                                    );
                                  },
                                  child: Text(
                                    "قديس",
                                    style: GoogleFonts.cairo(),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/manner',
                                      arguments: {
                                        "month": displayedMonth.month,
                                      },
                                    );
                                  },
                                  child: Text(
                                    "فضيله",
                                    style: GoogleFonts.cairo(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
