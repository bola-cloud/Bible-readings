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

    return "فضيله ${arabicMonths[month - 1]}";
  }

   @override
  Widget build(BuildContext context) {

    return _isLoading ? Loading() : 

    Scaffold(
      appBar: AppBar(
        title: Text(getArabicMonthName(month?? 0)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async{
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ---------------------------------------
            // TMP IMAGE (you can replace the asset)
            // ---------------------------------------
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              child: Image.asset(
                "assets/img/background.jpeg",   // <-- PLACEHOLDER IMAGE
                // height: 180,
                // width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // ---------------------------------------
            // TITLE
            // ---------------------------------------
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white.withOpacity(0.85),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "ممارسة عملية",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  // ---------------------------------------
                  // TEXT FIELD (safe height, no overflow)
                  // ---------------------------------------
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 120,
                      maxHeight: 120,
                    ),
                    child: TextField(
                      maxLines: null,
                      expands: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'ازاى طبقت الفضيله دى فى حياتك الشهر دة',
                      ),
                      keyboardType: TextInputType.multiline,
                      controller: _mannerController,
                      onChanged: (value) async {
                        await _databaseService.updateMonthManner(month!, value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}