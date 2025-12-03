import 'package:flutter/material.dart';
import 'package:flutter_application_1/battery_widget.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:flutter_application_1/loading.dart';

class MonthlyData extends StatefulWidget {
  const MonthlyData({super.key});

  @override
  State<MonthlyData> createState() => _MonthlyDataState();
}

class _MonthlyDataState extends State<MonthlyData> {

  final DatabaseService _databaseService = DatabaseService.instance;
  TextEditingController? _notesController;

  DateTime displayedMonth = DateTime.utc(2026, 1, 1);
  DateTime endMonth = DateTime.utc(2026,5,6);

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
    List<bool>? toggles = await _databaseService.getMonthAttendance(month);
    if(toggles == null){
      final weeks = getWeeksInMonth(displayedMonth);
      int totalCells = (weeks.length + 1) * 4; // 4 rows total
      List<bool> togglesList = List.generate(totalCells - (weeks.length + 1), (_) => false);
      await _databaseService.addAttendance(displayedMonth.month, togglesList);
      toggles = await _databaseService.getMonthAttendance(month);
    }
    final noteContent = await _databaseService.getMonthNote(month);
    setState(() {
      this.toggles = toggles;
      _notesController?.text = noteContent ?? "";
      _isLoading = false;
    });
  }

  // Get the first day of each week in the month
  List<DateTime> getWeeksInMonth(DateTime month, {int weekStart = DateTime.sunday}){
    List<DateTime> weeks = [];

    DateTime firstOfMonth = DateTime(month.year, month.month, 1);
    DateTime lastOfMonth = DateTime(month.year, month.month + 1, 0);

    // Start from the weekStart before or equal to the first day of the month
    DateTime currentWeekStart = firstOfMonth.subtract(Duration(days: (firstOfMonth.weekday - weekStart + 7) % 7));

    while (currentWeekStart.isBefore(lastOfMonth) || currentWeekStart.isAtSameMomentAs(lastOfMonth)) {
      weeks.add(currentWeekStart);
      currentWeekStart = currentWeekStart.add(Duration(days: 7));
    }

    return weeks;
  }


  void previousMonth() async {
    if (displayedMonth.month > 1) {
      setState(() {
        displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1, 1);
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
        displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 1);
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
    const arabic  = "٠١٢٣٤٥٦٧٨٩";

    String s = n.toString();

    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(english[i], arabic[i]);
    }

    return s;
  }

  double _calculateRowPercentage(int rowIndex) {
    if (toggles == null || toggles!.isEmpty) return 0.0;

    final weeks = getWeeksInMonth(displayedMonth);
    int columns = weeks.length+1;

    int startIndex = rowIndex * columns; // row start in toggles
    int endIndex = startIndex + columns -1;

    int rowCount = 0;
    int rowTotal = 0;

    for (int i = startIndex; i < endIndex && i < toggles!.length; i++) {
      rowTotal++;
      if (toggles![i]) rowCount++;
    }

    return rowTotal > 0 ? rowCount / rowTotal : 0.0;
  }

  @override
  Widget build(BuildContext context) {

    final weeks = getWeeksInMonth(displayedMonth);
    int totalCells = (weeks.length + 1) * 4; // 4 rows total

    int columns = weeks.length + 1;

    return _isLoading ? Loading() : 
    
    Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(intToArabic("${displayedMonth.year}-${displayedMonth.month.toString().padLeft(2, '0')}")),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pop(context, '/home');
          },
        ),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(onPressed: previousMonth, icon: const Icon(Icons.arrow_back)),
          IconButton(onPressed: nextMonth, icon: const Icon(Icons.arrow_forward)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            SizedBox(
              height: 350, // Fixed safe height for all phones
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  childAspectRatio: 1,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  if (index < columns) {
                    if (index == columns - 1) {
                      return Center(child: Text(""));
                    }

                    return Center(
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_today, size: 28),
                          Text(
                            intToArabic("${weeks[index].month.toString().padLeft(2,'0')}-${weeks[index].day.toString().padLeft(2,'0')}"),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    );
                  }

                  if (index == columns * 3 - 1) {
                    return Center(
                      child: Text(
                        "حضور الاجتماع",
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    );
                  }

                  if (index == columns * 4 - 1) {
                    return Center(
                      child: Text(
                        "المذبح العائلى",
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    );
                  }

                  int toggleIndex = index - columns;
                  bool isOn = toggles?[toggleIndex] ?? false;

                  return Center(
                    child: IconButton(
                      onPressed: () async {
                        setState(() {
                          toggles?[toggleIndex] = !(toggles?[toggleIndex] ?? true);
                        });
                        await _databaseService.updateMonthIndex(
                          displayedMonth.month,
                          toggleIndex,
                          toggles?[toggleIndex] ?? false,
                        );
                      },
                      icon: Icon(
                        isOn ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      ),
                      color: isOn ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ),

            // -----------------------------
            // Battery Widgets for each row
            // -----------------------------
            SizedBox(height: 16),
            Column(
              children: [
                Text("نسبة حضور القداس فى الشهر", style: TextStyle(fontWeight: FontWeight.bold)),
                BatteryWidget(
                  percentage: _calculateRowPercentage(0),
                  width: 200,
                  height: 20,
                ),
                SizedBox(height: 8),
                Text("نسبة حضور الاجتماع فى الشهر", style: TextStyle(fontWeight: FontWeight.bold)),
                BatteryWidget(
                  percentage: _calculateRowPercentage(1),
                  width: 200,
                  height: 20,
                ),
                SizedBox(height: 8),
                Text("نسبة المذبح العائلى فى الشهر", style: TextStyle(fontWeight: FontWeight.bold)),
                BatteryWidget(
                  percentage: _calculateRowPercentage(2),
                  width: 200,
                  height: 20,
                ),
              ],
            ),
            SizedBox(height: 16),

            // -----------------------------
            // Title
            // -----------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "سر المصالحة",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 8),

            // -----------------------------
            // Notes TextField
            // -----------------------------
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 120,
                maxHeight: 200,
              ),
              child: TextField(
                maxLines: null,
                expands: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'لو عايز تعمل فحص ضمير او تكتب لنفسك حاجات عايز تفتكرها',
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

            SizedBox(height: 12),

            // -----------------------------
            // Buttons Row
            // -----------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text("قديس"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/manner',
                      arguments: {"month": displayedMonth.month},
                    );
                  },
                  child: Text("فضيله"),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
