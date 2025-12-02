import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:flutter_application_1/modules/data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class CalanderParent extends StatefulWidget {
  const CalanderParent({super.key});

  @override
  State<CalanderParent> createState() => _CalanderParentState();
}

class _CalanderParentState extends State<CalanderParent> {
  Map<String,dynamic> data = {};
  Set<String> openedDays = {};
  Map<int,List<bool>> toggles = {};
  List<Data>? dataItems;
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<File> _getTogglesFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/notes.json'); // writable location
  }

  Future<void> deleteTogglesFile() async {
    final file = await _getTogglesFile();

    if (await file.exists()) {
      await file.delete();
      print("toggles file deleted.");
    } else {
      print("toggles file does not exist.");
    }
  }

  Future<void> deleteDatabaseIfExists() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'master_db.db');
    await deleteDatabase(path);
    print('deleted');
  }

  getTogglesData() async {
    final togglesFile = await _getTogglesFile();

    if (!await togglesFile.exists()) {
      return <int, List<bool>>{};
    }

    final togglesContent = await togglesFile.readAsString();
    if (togglesContent.trim().isEmpty) {
      return <int, List<bool>>{};
    }

    final decoded = jsonDecode(togglesContent);

    if (decoded is! Map<String, dynamic>) {
      return <int, List<bool>>{};
    }

    final Map<int, List<bool>> toggles = {};

    decoded.forEach((key, value) {
      // Convert key: String → int
      final intKey = int.tryParse(key);
      if (intKey == null) return;

      // Convert value: dynamic → List<bool>
      final List<bool> boolList = [];

      if (value is List) {
        for (final item in value) {
          if (item is bool) {
            boolList.add(item);
          } else {
            // If stored as string "true"/"false"
            boolList.add(item.toString().toLowerCase() == "true");
          }
        }
      }

      toggles[intKey] = boolList;
    });

    setState(() {
      this.toggles = toggles;
    });

    return toggles;
  }

  Widget _buildCard({required String title, required String subtitle, required VoidCallback onTap, Color? color, Widget? leading}){
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: title,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: color ?? Colors.orange.withOpacity(0.9),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(minHeight: 120),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                if (leading != null) ...[
                  leading,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown[900])),
                      const SizedBox(height: 8),
                      Text(subtitle, style: GoogleFonts.cairo(fontSize: 14, color: Colors.brown[700])),
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('مقدمة كراسة', style: GoogleFonts.cairo()),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/background.jpeg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.85), BlendMode.dstATop),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header image / title
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 80),
                          const SizedBox(height: 12),
//                           Text('كل طريق روحي حقيقي يبدأ بخطوة صغيرة... خطوة صادقة نحو ربنا يسوع.', style: GoogleFonts.cairo(fontSize: 14, color: Colors.brown[800]), textAlign: TextAlign.center),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),

                    // Cards grid / list (7 cards total)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        SizedBox(
                          width: isWide ? (constraints.maxWidth/2 - 26) : constraints.maxWidth,
                          child: _buildCard(
                            title: 'تأملات من الكتاب المقدس',
                            subtitle: 'تأملات من الاكتاب المقدس تساعدك ان تفهم كلام الرب وتزوجها في حياتك اليومية',
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.book, color: Colors.orange),
                            ),
                            color: Colors.orange.shade200.withOpacity(0.9),
                            onTap: () async {
                              await _databaseService.getData();
                              await deleteTogglesFile();
                              Navigator.pushNamed(context, '/calendar');
                            },
                          ),
                        ),

                        SizedBox(
                          width: isWide ? (constraints.maxWidth/2 - 26) : constraints.maxWidth,
                          child: _buildCard(
                            title: 'جدول متابعة شهرى',
                            subtitle: 'تقدر من خلاله نتائج حضورك للقداس والاجتماع وممارسة سر المعالجة',
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.calendar_month, color: Colors.orange),
                            ),
                            color: Colors.yellow.shade100.withOpacity(0.9),
                            onTap: () async {
                              await getTogglesData();
                              await deleteDatabaseIfExists();
                              Navigator.pushNamed(context, '/monthly_data', arguments: {
                                "toggles": toggles,
                              });
                            },
                          ),
                        ),

                        SizedBox(
                          width: isWide ? (constraints.maxWidth/2 - 26) : constraints.maxWidth,
                          child: _buildCard(
                            title: 'تأمل عملي يومي',
                            subtitle: 'خطوات عملية للتأمل اليومي تساعدك تدخل الى كلمة الله وتسمع صوته',
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.menu_book, color: Colors.orange),
                            ),
                            color: Colors.orange.shade50.withOpacity(0.95),
                            onTap: () {},
                          ),
                        ),

                        SizedBox(
                          width: isWide ? (constraints.maxWidth/2 - 26) : constraints.maxWidth,
                          child: _buildCard(
                            title: 'حياة قديس',
                            subtitle: 'حياة قديس تكون لك مثال حي للتثبيت والنمو في الايمان',
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.person, color: Colors.orange),
                            ),
                            color: Colors.orange.shade100.withOpacity(0.95),
                            onTap: () {},
                          ),
                        ),

                        SizedBox(
                          width: isWide ? (constraints.maxWidth/2 - 26) : constraints.maxWidth,
                          child: _buildCard(
                            title: 'خطوات فحص الضمير',
                            subtitle: 'خطوات فحص الضمير تساعدك تراجع نفسك بصدق وتستعد للمواجهة مع الله',
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.self_improvement, color: Colors.orange),
                            ),
                            color: Colors.yellow.shade50.withOpacity(0.95),
                            onTap: () {},
                          ),
                        ),

                        SizedBox(
                          width: isWide ? (constraints.maxWidth/2 - 26) : constraints.maxWidth,
                          child: _buildCard(
                            title: 'خطوات ساعة السجود',
                            subtitle: 'خطوات ساعة السجود امام ذاكرك الرب لتعيش لحظة لقاء عميق مع المسيح',
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.access_time, color: Colors.orange),
                            ),
                            color: Colors.orange.shade200.withOpacity(0.95),
                            onTap: () {},
                          ),
                        ),

                        SizedBox(
                          width: isWide ? (constraints.maxWidth/2 - 26) : constraints.maxWidth,
                          child: _buildCard(
                            title: 'فضيلة لكل شهر',
                            subtitle: 'فضيلة لكل شهر علشان تتعلمها وتعيشها عمليًا',
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.star, color: Colors.orange),
                            ),
                            color: Colors.orange.shade300.withOpacity(0.95),
                            onTap: () {},
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 20),

                    // Footer / note
                    Text('الفكرة مش إنك تملأ كراسة... لكن إنك تنمو روحياً وتكتشف جمال الحياة مع ربنا.', style: GoogleFonts.cairo(fontSize: 13, color: Colors.white), textAlign: TextAlign.center),

                    const SizedBox(height: 30),
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}