import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _loadData(displayedMonth.month);
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

  @override
  Widget build(BuildContext context) {

    final weeks = getWeeksInMonth(displayedMonth);
    int totalCells = (weeks.length + 1) * 4; // 4 rows total

    int columns = weeks.length + 1;

    return _isLoading ? Loading() : 
    
    Scaffold(
      appBar: AppBar(
        title: Text(intToArabic("${displayedMonth.year}-${displayedMonth.month.toString().padLeft(2, '0')}")),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pushNamed(context, '/calendar_parent');
          },
        ),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(onPressed: previousMonth, icon: const Icon(Icons.arrow_back)),
          IconButton(onPressed: nextMonth, icon: const Icon(Icons.arrow_forward)),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: 1,
              ),
              itemCount: totalCells,
              itemBuilder: (context, index) {
                // --------------------------
                // 1️⃣ HEADER ROW (week names)
                // --------------------------
                if (index < columns) {
                  // First cell is empty
                  if (index == columns-1) {
                    return Center(child: Text(""));
                  }
            
                  return Center(
                    child: Column(
                      children: [
                        const Icon(Icons.calendar_today, size: 28),
                        // const SizedBox(height: 8),
                        Text(                
                          intToArabic("${weeks[index].month.toString().padLeft(2, '0')}-${weeks[index].day.toString().padLeft(2, '0')}"),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
            
                // --------------------------
                // 2️⃣ TOGGLE BUTTONS BELOW
                // --------------------------
            
                if(index == columns*2 - 1 ){
                  return Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text("حضور القداس",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)
                    )
                  );
                }
            
                if(index == columns*3 - 1 ){
                  return Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text("حضور الاجتماع",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)
                    )
                  );
                }
            
                if(index == columns*4 - 1 ){
                  return Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text("المذبح العائلى",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)
                    )
                  );
                }
            
                int toggleIndex = index - columns;
                bool isOn = toggles?[toggleIndex] ?? false;
            
                return Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () async{
                          setState((){
                            toggles?[toggleIndex] = !(toggles?[toggleIndex] ?? true);
                          });
                          await _databaseService.updateMonthIndex(displayedMonth.month, toggleIndex, toggles?[toggleIndex] ?? false);
                        },
                        icon: Icon(isOn
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked),
                        color: isOn ? Colors.green : Colors.red,
                      ),
                    ),
                );
              },
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "سر المصالحة",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Center the text
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.18, // ⬅️ 18% of the height
              child: TextField(
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'لو عايز تعمل فحص ضمير او تكتب لنفسك حاجات عايز تفتكرها',
                ),
                keyboardType: TextInputType.multiline,
                controller: _notesController,
                onChanged: (value) async {
                  await _databaseService.updateMonthNote(displayedMonth.month, value);  
                },
              ),
            ),
        ],
      ),
    );
  }
}
