import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/styled_body_text.dart';
import 'package:path_provider/path_provider.dart';

class Reading extends StatefulWidget {
  const Reading({super.key});

  @override
  State<Reading> createState() => _ReadingState();
}

class _ReadingState extends State<Reading> {

  Map<String, dynamic>? items;
  Map<String, String>? notes;
  Set<String>? openedDaysItems;
  String? date;

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: notes?[date] ?? "");
  }

  @override
  void didUpdateWidget(covariant Reading oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update the text only if the date changes
    if (_controller.text != (notes?[date] ?? "")) {
      _controller.text = notes?[date] ?? "";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Future<File> _getNotesFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/notes.json'); // writable location
  }

  saveNotes(Map<String, dynamic> notes) async {
    final file = await _getNotesFile();
    await file.writeAsString(jsonEncode(notes));
  }

   @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)?.settings.arguments as Map;

    Map<String, dynamic>? items;
    if (args["items"] != null && args["items"] is Map<String, dynamic>) {
      items = args["items"];
    } else {
      items = {}; // or default values
    }

    Set<String> openedDaysItems;
    if (args["openedDays"] != null && args["openedDays"] is Set<String>) {
      openedDaysItems = args["openedDays"];
    } else {
      openedDaysItems = {}; // or default values
    }

    String title;
    if (args["title"] != null && args["title"] is String) {
      title = args["title"];
    } else {
      title = ""; // or default values
    }

    String reading;
    if (args["reading"] != null && args["reading"] is String) {
      reading = args["reading"];
    } else {
      reading = ""; // or default values
    }

    String date;
    if (args["date"] != null && args["date"] is String) {
      date = args["date"];
    } else {
      date = ""; // or default values
    }

    Map<String, String>? notes;
    if (args["notes"] != null && args["notes"] is Map<String, String>) {
      notes = args["notes"];
    } else {
      notes = {}; // or default values
    }

    setState(() {
      this.items = items;
      this.openedDaysItems = openedDaysItems;
      this.notes = notes;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(intToArabic(convertToDDMMYYYY(date))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/calendar', arguments: {
              "data": items,
              "openedDays": openedDaysItems,
            });
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (openedDaysItems.contains(date)) {
                    openedDaysItems.remove(date);
                  } else {
                    openedDaysItems.add(date);
                  }
                });
              },
              icon: Icon(
              openedDaysItems.contains(date)
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
              ),
              color: openedDaysItems.contains(date)
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
              height: MediaQuery.of(context).size.height * 0.6, // ⬅️ 70% of the height
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
            Container(
              height: MediaQuery.of(context).size.height * 0.18, // ⬅️ 18% of the height
              child: TextField(
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'اية لمستك و قرار اخدته',
                ),
                keyboardType: TextInputType.multiline,
                controller: TextEditingController(
                  text: notes?[date] ?? "",
                ),
                onChanged: (value) async {
                  notes?[date] = value;
                  await saveNotes(notes ?? {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}