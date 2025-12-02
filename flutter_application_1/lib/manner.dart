import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:flutter_application_1/loading.dart';

class Manner extends StatefulWidget {
  const Manner({super.key});

  @override
  State<Manner> createState() => _MannerState();
}

class _MannerState extends State<Manner> {

  final DatabaseService _databaseService = DatabaseService.instance;
  TextEditingController? _mannerController;

  int? month;
  bool _isLoaded = false;   // prevent multiple loads
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mannerController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load only once
    if (!_isLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      month = args?["month"];

      if (month != null) {
        _loadData(month!);
      }

      _isLoaded = true;
    }
  }

  Future<void> _loadData(int month) async {
    final mannerContent = await _databaseService.getMonthManner(month);

    setState(() {
      _mannerController?.text = mannerContent ?? "";
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

   @override
  Widget build(BuildContext context) {

    return _isLoading ? Loading() : 

    Scaffold(
      appBar: AppBar(
        title: Text(intToArabic(month??"")),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async{
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.grey,
      ),
      body: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "ممارسة عملية",
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
                  hintText: 'ازاى طبقت الفضيله دى فى حياتك الشهر دة',
                ),
                keyboardType: TextInputType.multiline,
                controller: _mannerController,
                onChanged: (value) async {
                  _databaseService.updateMonthManner(month!, value);  
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}