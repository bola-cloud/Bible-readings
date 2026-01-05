import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/calendar.dart';
import 'package:flutter_application_1/daily_meditation.dart';
import 'package:flutter_application_1/f7s_al_damer.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/howTo.dart';
import 'package:flutter_application_1/landing_page.dart';
import 'package:flutter_application_1/manner.dart';
import 'package:flutter_application_1/masba7_3a2ly.dart';
import 'package:flutter_application_1/monthly_data.dart';
import 'package:flutter_application_1/profile_page.dart';
import 'package:flutter_application_1/reading.dart';
import 'package:flutter_application_1/register.dart';
import 'package:flutter_application_1/saint.dart';
import 'package:flutter_application_1/statistics.dart';
import 'package:flutter_application_1/sujood_hour.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For desktop (Windows/Linux/Mac), initialize sqflite ffi and set the
  // global databaseFactory so the sqflite openDatabase/getDatabasesPath APIs work.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible Readings',
      theme: ThemeData(primarySwatch: Colors.grey),
      // Use `home` so we render the correct initial screen directly.
      home: const LandingPage(),
      routes: {
        '/landing': (context) => const LandingPage(),
        // '/' must not be present when `home` is non-null (see Flutter docs)
        // Landing page is provided via `home` above.
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const Home(),
        '/calendar': (context) => const Calendar(),
        '/reading': (context) => const Reading(),
        '/monthly_data': (context) => const MonthlyData(),
        '/statistics': (context) => const Statistics(),
        '/f7s_al_damer': (context) => const F7sAlDamer(),
        '/sujood_hour': (context) => const SujoodHour(),
        '/daily_meditation': (context) => const DailyMeditation(),
        '/manner': (context) => const Manner(),
        '/saint': (context) => const Saint(),
        '/masba7_3a2ly': (context) => const Masba73a2ly(),
        '/howTo': (context) => const HowTo(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
