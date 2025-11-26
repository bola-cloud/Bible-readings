import 'package:flutter/material.dart';
import 'package:flutter_application_1/styled_body_text.dart';
import 'package:flutter_application_1/styled_button.dart';

class Reading extends StatelessWidget {
  const Reading({super.key});


   @override
  Widget build(BuildContext context) {

    // final String data = ModalRoute.of(context)!.settings.arguments as String;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // your logic instead of Navigator.pop()
            Navigator.pushNamed(context, '/calendar', arguments: {
              "data": items,
              "openedDays": openedDaysItems,
            });
          },
        ),
        backgroundColor: Colors.grey,
      ),
      body: Scaffold(
        body: Column(
          children: [
            StyledBodyText(
              reading
            ),
            StyledButton(
              onPressed: () {
                openedDaysItems.remove(date);
                Navigator.pushNamed(context, '/calendar', arguments: {
                  "data": items,
                  "openedDays": openedDaysItems,
                });
              },
              child: Text('mark as unread'),
            ),
          ],
        ),
      ),
    );
  }
}