import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:flutter_application_1/loading.dart';
import 'package:flutter_application_1/styled_body_text.dart';

class Reading extends StatefulWidget {
  const Reading({super.key});

  @override
  State<Reading> createState() => _ReadingState();
}

class _ReadingState extends State<Reading> {

  final DatabaseService _databaseService = DatabaseService.instance;
  TextEditingController? _notesController;

  String title = "";
  String reading = "";
  String? date;
  bool opened = false;
  bool _isLoaded = false;   // prevent multiple loads
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load only once
    if (!_isLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      date = args?["date"];

      if (date != null) {
        _loadData(date!);
      }

      _isLoaded = true;
    }
  }

  Future<void> _loadData(String date) async {
    final dataItem = await _databaseService.getDataContentByDate(date);
    final noteContent = await _databaseService.getNoteContentByDate(date);

    setState(() {
      title = dataItem?.title ?? "";
      reading = dataItem?.reading ?? "";
      opened = dataItem?.opened == 1;
      _notesController?.text = noteContent ?? "";
      _isLoading = false;
    });
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

  String convertToDDMMYYYY(String date) {
    final parts = date.split('-'); // [MM, DD, YYYY]

    if (parts.length != 3) return date; // invalid format → return as is

    String mm = parts[0];
    String dd = parts[1];
    String yyyy = parts[2];

    return "$dd-$mm-$yyyy";
  }  

   @override
  Widget build(BuildContext context) {

    return _isLoading ? Loading() : 

    Scaffold(
      appBar: AppBar(
        title: Text(intToArabic(convertToDDMMYYYY(date??""))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async{
            Navigator.pushNamed(context, '/calendar');
          },
        ),
        actions: [
          IconButton(
              onPressed: () async {
                setState(() {
                  opened = !opened;
                });
                _databaseService.updateDataOpened(date!, opened? 1: 0);
              },
              icon: Icon(
              opened
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
              ),
              color: opened
                ? Colors.green
                : Colors.red,
            ),
        ],
        backgroundColor: Colors.grey,
      ),
      body: Scaffold(
        body: Column(
          children: [
            StyledBodyText(
              intToArabic(title),
            ),
            Container(
                // height: MediaQuery.of(context).size.height * 0.6, // ⬅️ 60% of the height
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: StyledBodyText(
                reading
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.black, // You can change the color as needed
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "ملاحظات",
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
                  hintText: 'اية لمستك و قرار اخدته',
                ),
                keyboardType: TextInputType.multiline,
                controller: _notesController,
                onChanged: (value) async {
                  _databaseService.updateNoteContent(date!, value);  
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}