import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _church = TextEditingController();
  final TextEditingController _schoolYear = TextEditingController();
  final TextEditingController _sponsor = TextEditingController();
  final TextEditingController _favoriteColor = TextEditingController();
  final TextEditingController _favoriteProgram = TextEditingController();
  final TextEditingController _favoriteGame = TextEditingController();
  final TextEditingController _favoriteHymn = TextEditingController();
  final TextEditingController _hobby = TextEditingController();

  bool _isSubmitting = false;

  bool isNumeric(String str) {
    try {
      int.parse(str);
    } on FormatException {
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final payload = {
      "name": _name.text.trim(),
      "email": _email.text.trim(),
      "phone": _phone.text.trim(),
      "church": _church.text.trim(),
      "school_year": _schoolYear.text.trim(),
      "sponsor": _sponsor.text.trim(),
      "favorite_color": _favoriteColor.text.trim(),
      "favorite_program": _favoriteProgram.text.trim(),
      "favorite_game": _favoriteGame.text.trim(),
      "favorite_hymn": _favoriteHymn.text.trim(),
      "hobby": _hobby.text.trim(),
    };

    try {
      if (!isNumeric(_phone.text.trim()) ||
          _phone.text.trim().length < 11 ||
          _phone.text.trim()[0] != '0' ||
          _phone.text.trim()[1] != '1') {
        _showError('رقم التليفون غير صالح');
        return;
      }
      final resp = await http.post(
        Uri.parse('https://stepbystep.wasl-x.com/api/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        // Save profile locally in the app database
        await DatabaseService.instance.saveUserProfile(payload);

        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم التسجيل بنجاح — جاري التحويل...',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green[700],
            duration: Duration(milliseconds: 900),
          ),
        );

        // Small delay for the user to see the message, then replace with LandingPage
        await Future.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        String msg = resp.body.isNotEmpty ? resp.body : 'خطأ فى التسجيل';
        if (msg != 'خطأ فى التسجيل') {
          try {
            final data = jsonDecode(resp.body);
            if (data is Map &&
                data.containsKey('data') &&
                data['data'] is Map &&
                data['data'].containsKey('email')) {
              final emailErrors = data['data']['email'];
              if (emailErrors is List && emailErrors.isNotEmpty) {
                if (emailErrors.contains('The email has already been taken.')) {
                  msg = 'البريد الالكترونى مستخدم بالفعل';
                } else {
                  msg = 'البريد الالكترونى غير صالح';
                }
              }
            }
          } catch (_) {}
        }
        _showError(msg);
      }
    } catch (e) {
      _showError('تعذّر الإتصال. حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = 720.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'تسجيل',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.brown[900],
            ),
          ),
        ),
        body: Stack(
          children: [
            // Background like Home
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
            Container(color: Colors.white.withOpacity(0.30)),

            // Centered card (same style as home)
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Color(0xFFF8EDE0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 24.0,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'أنا مين؟ وبحب إيه؟',
                                style: GoogleFonts.cairo(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.brown[900],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),

                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _field(_name, 'الاسم'),
                                    _field(_church, 'الكنيسة'),
                                    _field(_schoolYear, 'السنة الدراسية'),
                                    _field(_sponsor, 'شفيعك'),
                                    _field(_favoriteColor, 'لونك المفضل'),
                                    _field(_favoriteProgram, 'برنامج بتحبه'),
                                    _field(_favoriteGame, 'لعبة بتحبها'),
                                    _field(_favoriteHymn, 'ترنيمة بتحبها'),
                                    _field(_hobby, 'هوايتك'),
                                    _field(_phone, 'التليفون'),
                                    _field(_email, 'البريد الالكترونى'),

                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _isSubmitting
                                            ? null
                                            : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.brown[700],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 14,
                                          ),
                                        ),
                                        child: _isSubmitting
                                            ? SizedBox(
                                                height: 18,
                                                width: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                'ابدأ المشوار',
                                                style: GoogleFonts.cairo(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'مطلوب';
          return null;
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.brown.shade200, width: 1.8),
            borderRadius: BorderRadius.circular(28),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.brown.shade400, width: 1.8),
            borderRadius: BorderRadius.circular(28),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
