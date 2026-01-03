import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:flutter_application_1/loading.dart';

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
  bool _isLoaded = false;
  bool _isLoading = true;
  bool _noteEdited = false;

  // Add font size state
  double _readingFontSize = 16.0; // Default font size
  final double _minFontSize = 12.0;
  final double _maxFontSize = 24.0;
  final double _fontSizeStep = 2.0;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
    final noteContent = await _database_service_getNoteSafe(date);
    setState(() {
      title = dataItem?.title ?? "";
      reading = dataItem?.reading ?? "";
      opened = dataItem?.opened == 1;
      _notesController?.text = noteContent ?? "";
      _isLoading = false;
    });
  }

  Future<String?> _database_service_getNoteSafe(String date) async {
    try {
      return await _databaseService.getNoteContentByDate(date);
    } catch (_) {
      return null;
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

  String convertToDDMMYYYY(String date) {
    final parts = date.split('-');
    if (parts.length != 3) return date;

    String mm = parts[0];
    String dd = parts[1];
    String yyyy = parts[2];

    return "$dd-$mm-$yyyy";
  }

  // Font size control methods
  void _increaseFontSize() {
    setState(() {
      if (_readingFontSize < _maxFontSize) {
        _readingFontSize += _fontSizeStep;
      }
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_readingFontSize > _minFontSize) {
        _readingFontSize -= _fontSizeStep;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double opacity = (_scrollOffset / 50).clamp(0.0, 1.0);

    return _isLoading
        ? Loading()
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Opacity(
                opacity: 1 - opacity,
                child: Text(
                  intToArabic(convertToDDMMYYYY(date ?? "")),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                Opacity(
                  opacity: 1 - opacity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        opened = !opened;
                      });

                      await _databaseService.updateDataOpened(
                        date!,
                        opened ? 1 : 0,
                      );
                    },
                    icon: Icon(
                      opened
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: Text(
                      opened ? "قرأته" : "لم أقرأه",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: opened ? Colors.green : Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
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

                // Pale overlay
                Container(color: Colors.white.withOpacity(0.30)),

                // Main content
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableHeight = constraints.maxHeight;
                    final readingHeight = availableHeight * 0.55;
                    final notesMinHeight = 120.0;
                    final notesMaxHeight = availableHeight * 0.30;

                    return SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 80),

                            // Section 1: Title + Reading inside a Card
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Color(0xFFF8EDE0),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Title Row with Font Size Controls
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Decrease Font Size Button
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.zoom_out,
                                                    size: 20,
                                                    color:
                                                        _readingFontSize <=
                                                            _minFontSize
                                                        ? Colors.grey
                                                        : Colors.blue,
                                                  ),
                                                  onPressed:
                                                      _readingFontSize <=
                                                          _minFontSize
                                                      ? null
                                                      : _decreaseFontSize,
                                                  constraints: BoxConstraints(
                                                    minWidth: 20,
                                                    minHeight: 20,
                                                  ),
                                                  tooltip: 'تصغير الخط',
                                                ),

                                                // Font Size Display
                                                Text(
                                                  '${_readingFontSize.toInt()}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue[800],
                                                  ),
                                                ),

                                                // Increase Font Size Button
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.zoom_in,
                                                    size: 20,
                                                    color:
                                                        _readingFontSize >=
                                                            _maxFontSize
                                                        ? Colors.grey
                                                        : Colors.blue,
                                                  ),
                                                  onPressed:
                                                      _readingFontSize >=
                                                          _maxFontSize
                                                      ? null
                                                      : _increaseFontSize,
                                                  constraints: BoxConstraints(
                                                    minWidth: 20,
                                                    minHeight: 20,
                                                  ),
                                                  tooltip: 'تكبير الخط',
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Invisible placeholder to balance layout
                                          Container(
                                            child: Text(
                                              intToArabic(title),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Divider(),
                                    const SizedBox(height: 8),

                                    // Reading area (scrollable)
                                    SizedBox(
                                      height: readingHeight,
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          // Updated: Pass font size to StyledBodyText
                                          child: Text(
                                            textDirection: TextDirection.rtl,
                                            reading,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: _readingFontSize,
                                              height: 1.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Section 2: Notes card
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Color(0xFFF8EDE0),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // Invisible placeholder
                                        Opacity(
                                          opacity: 0,
                                          child: _noteEdited
                                              ? ElevatedButton.icon(
                                                  onPressed: () {},
                                                  icon: Icon(Icons.save),
                                                  label: Text("حفظ"),
                                                )
                                              : SizedBox(width: 0, height: 0),
                                        ),

                                        // Centered title
                                        Expanded(
                                          child: Text(
                                            "ملاحظات",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),

                                        // Actual save button
                                        _noteEdited
                                            ? ElevatedButton.icon(
                                                onPressed: () async {
                                                  await _databaseService
                                                      .updateNoteContent(
                                                        date!,
                                                        _notesController!.text,
                                                      );
                                                  setState(() {
                                                    _noteEdited = false;
                                                  });
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "تم الحفظ",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            TextStyle(),
                                                      ),
                                                      duration: Duration(
                                                        seconds: 1,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.save,
                                                  size: 18,
                                                ),
                                                label: Text(
                                                  "حفظ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 8,
                                                      ),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: notesMinHeight,
                                        maxHeight: notesMaxHeight,
                                      ),
                                      child: TextField(
                                        maxLines: null,
                                        expands: false,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'اية لمستك و قرار اخدته',
                                          hintStyle: TextStyle(),
                                        ),
                                        keyboardType: TextInputType.multiline,
                                        controller: _notesController,
                                        onChanged: (value) {
                                          setState(() {
                                            _noteEdited = true;
                                          });
                                        },
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
                    );
                  },
                ),
              ],
            ),
          );
  }
}
