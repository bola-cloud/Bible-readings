import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_service.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/auth_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  Profile? _profile;

  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _churchCtl = TextEditingController();
  final _schoolYearCtl = TextEditingController();
  final _sponsorCtl = TextEditingController();
  final _favoriteColorCtl = TextEditingController();
  final _favoriteProgramCtl = TextEditingController();
  final _favoriteGameCtl = TextEditingController();
  final _favoriteHymnCtl = TextEditingController();
  final _hobbyCtl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    // 1) Try to fetch from remote API if token exists
    try {
      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        final p = await ApiService.getProfile();
        _profile = p;
        _applyProfileToControllers(p);
        setState(() => _loading = false);
        return;
      }
    } catch (e) {
      // API fetch failed — will try local DB next
    }

    // 2) Fallback to local DB profile
    try {
      final local = await DatabaseService.instance.getUserProfile();
      if (local != null) {
        // local is Map<String,dynamic>
        final p = Profile(
          id: 1,
          name: local['name'] ?? '',
          phone: local['phone'] ?? '',
          church: local['church'] ?? '',
          schoolYear: local['school_year'] ?? '',
          sponsor: local['sponsor'] ?? '',
          favoriteColor: local['favorite_color'] ?? '',
          favoriteProgram: local['favorite_program'] ?? '',
          favoriteGame: local['favorite_game'] ?? '',
          favoriteHymn: local['favorite_hymn'] ?? '',
          hobby: local['hobby'] ?? '',
        );
        _profile = p;
        _applyProfileToControllers(p);
        setState(() => _loading = false);
        return;
      }
    } catch (e) {
      // Local DB fetch failed
    }

    // If we reach here nothing loaded
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('لا توجد بيانات للعرض')));
      setState(() => _loading = false);
    }
  }

  void _applyProfileToControllers(Profile p) {
    _nameCtl.text = p.name;
    _phoneCtl.text = p.phone ?? '';
    _churchCtl.text = p.church ?? '';
    _schoolYearCtl.text = p.schoolYear ?? '';
    _sponsorCtl.text = p.sponsor ?? '';
    _favoriteColorCtl.text = p.favoriteColor ?? '';
    _favoriteProgramCtl.text = p.favoriteProgram ?? '';
    _favoriteGameCtl.text = p.favoriteGame ?? '';
    _favoriteHymnCtl.text = p.favoriteHymn ?? '';
    _hobbyCtl.text = p.hobby ?? '';
  }

  bool isNumeric(String str) {
    try {
      int.parse(str);
    } on FormatException {
      return false;
    }
    return true;
  }

  String intToEnglish(dynamic n) {
    const english = "0123456789";
    const arabic = "٠١٢٣٤٥٦٧٨٩";

    String s = n.toString();

    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(arabic[i], english[i]);
    }

    return s;
  }

  Future<void> _update() async {
    setState(() => _saving = true);
    final updated = Profile(
      id: _profile?.id,
      name: _nameCtl.text.trim(),
      phone: _phoneCtl.text.trim(),
      church: _churchCtl.text.trim(),
      schoolYear: _schoolYearCtl.text.trim(),
      sponsor: _sponsorCtl.text.trim(),
      favoriteColor: _favoriteColorCtl.text.trim(),
      favoriteProgram: _favoriteProgramCtl.text.trim(),
      favoriteGame: _favoriteGameCtl.text.trim(),
      favoriteHymn: _favoriteHymnCtl.text.trim(),
      hobby: _hobbyCtl.text.trim(),
    );

    Exception? lastErr;

    String phone = intToEnglish(_phoneCtl.text.trim());

    if (!isNumeric(phone) ||
        phone.length != 11 ||
        phone[0] != '0' ||
        phone[1] != '1') {
      _showStyledMessage('رقم التليفون غير صالح', success: false);
      setState(() => _saving = false);
      return;
    }

    // Try update remote if token present
    try {
      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        final res = await ApiService.updateProfile(updated);
        _profile = res;
        _applyProfileToControllers(res);
      }
    } catch (e) {
      lastErr = Exception('API update failed: $e');
    }

    // Save locally regardless
    try {
      await DatabaseService.instance.saveUserProfile(updated.toJson());
    } catch (e) {
      lastErr = Exception('Local save failed: $e');
    }

    if (mounted) {
      if (lastErr == null) {
        _showSuccessDialog();
      } else {
        _showStyledMessage('حدثت مشكلة أثناء التحديث', success: false);
      }
      setState(() => _saving = false);
    }
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
            'الملف الشخصي',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown[900],
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.brown[900]),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Stack(
          children: [
            // Background like Home/Register
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
                        child: _loading
                            ? SizedBox(
                                height: 300,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'تعديل الملف الشخصى',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.brown[900],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 18),
                                    _styledField(_nameCtl, 'الاسم'),
                                    _styledField(_phoneCtl, 'التليفون'),
                                    _styledField(_churchCtl, 'الكنيسة'),
                                    _styledField(
                                      _schoolYearCtl,
                                      'السنة الدراسية',
                                    ),
                                    _styledField(_sponsorCtl, 'شفيعك'),
                                    _styledField(
                                      _favoriteColorCtl,
                                      'لونك المفضل',
                                    ),
                                    _styledField(
                                      _favoriteProgramCtl,
                                      'برنامج بتحبه',
                                    ),
                                    _styledField(
                                      _favoriteGameCtl,
                                      'لعبة بتحبها',
                                    ),
                                    _styledField(
                                      _favoriteHymnCtl,
                                      'ترنيمة بتحبها',
                                    ),
                                    _styledField(_hobbyCtl, 'هوايتك'),
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _saving ? null : _update,
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
                                        child: _saving
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
                                                'حفظ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),
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

  Widget _styledField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
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

  void _showStyledMessage(String message, {bool success = true}) {
    final snack = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      backgroundColor: success ? Colors.green[700] : Colors.red[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          Icon(success ? Icons.check_circle : Icons.error, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFFF8EDE0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[700]),
            const SizedBox(height: 12),
            Text(
              'تم التحديث بنجاح',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.brown[900],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تم حفظ التغييرات محليًا، وتمت محاولة التزامن مع الخادم.',
              style: TextStyle(color: Colors.brown[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(ctx).pop();
            },
            child: Text(
              'حسناً',
              style: TextStyle(color: Colors.brown[900]),
            ),
          ),
        ],
      ),
    );
  }
}
