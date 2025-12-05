import 'package:flutter/material.dart';

class FloatingCardsPage extends StatelessWidget {
  const FloatingCardsPage({super.key});

  // helper for a translucent rounded card
  Widget _card({
    // required double width,
    // required double height,
    required Widget child,
    double radius = 20,
    EdgeInsets? padding,
  }) {
    return Container(
      // width: width,
      // height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        // a light subtle inner gradient to mimic paper
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.88),
            Colors.white.withOpacity(0.80),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // responsive helpers
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    // recommended background asset: assets/background.jpg (add to pubspec.yaml)
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: SafeArea(
          child: Stack(
            children: [
              // background image that fills screen
              Positioned.fill(
                child: Image.asset('assets/img/carlo.jpg', fit: BoxFit.fill),
              ),

              // top centered title pill
              Positioned(
                top: h * 0.04,
                left: w * 0.12,
                right: w * 0.12,
                child: Center(
                  child: _card(
                    // width: w * 0.7,
                    // height: 52,
                    radius: 30,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: Center(
                      child: Text(
                        'حياة القديس كارلو أكوتيس',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // left large story card
              Positioned(
                top: h * 0.12,
                left: w * 0.04,
                width: w * 0.4,
                height: h * 0.44,
                child: _card(
                  // width: w * 0.56,
                  // height: h * 0.44,
                  radius: 28,
                  padding: const EdgeInsets.all(18),
                  child: Scrollbar(
                    thumbVisibility: true, // always show the scrollbar
                    thickness: 6, // optional: width of the scrollbar
                    radius: Radius.circular(8), // optional: rounded edges
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "قصته",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            // use your actual Arabic story text here
                            'كارلو كان ولد عادي جداً، يحب يلعب كمبيوتر والألعاب زي باقي الأولاد، لكن كان عنده سر جميل: كان دايماً يشكر يسوع، خصوصاً في القداس والتناول. كان يقول: "التقربٌ هو الطريق السريع إلى السماء".\n\n'
                            'كارلو استخدم الإنترنت يعمل موقع كبير عن معجزات القرابين، عشان كل الناس تعرف إن يسوع حيٌ في القربان. حتى لما تعب جداً بالسرطان، ما انشكاَش، بالعكس كان يشكر ربنا ويقول: "أنا مبسوط أقدم دمى ليسوع".',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // right info card (name, birth, death, etc)
              Positioned(
                top: h * 0.12,
                right: w * 0.04,
                width: w * 0.5,
                height: h * 0.2,
                child: _card(
                  // width: w * 0.5,
                  // height: h * 0.32,
                  radius: 22,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text.rich(
                        TextSpan(
                          text: "اسمه:", // Default style
                          style: TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: "كارلو أكوتيس", // Different style
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: "سنة الميلاد:", // Default style
                          style: TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: "1991 - إيطاليا", // Different style
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          text: "الوفاة:", // Default style
                          style: TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: "2006 وعمره 15 سنه", // Different style
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6),
                      // Text('إعلان تطويبه: 2020'),
                      Text.rich(
                        TextSpan(
                          text: "إعلان تطويبه:", // Default style
                          style: TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: "2020", // Different style
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          text: "إعلان قداسته:", // Default style
                          style: TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: "2025/9/7", // Different style
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // right lower virtues card
              Positioned(
                top: h * 0.6,
                right: w * 0.35,
                width: w * 0.32,
                height: h * 0.32,
                child: _card(
                  // width: w * 0.22,
                  // height: h * 0.32,
                  radius: 20,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'فضيلته',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'الشكر: كارلو كان يشكر ربنا في كل الظروف: في الصحة، في المرض، في الدراسة، في اللعب... وكان يشوف كل حاجة عطية من ربنا.',
                      ),
                    ],
                  ),
                ),
              ),

              // bottom left small message card
              Positioned(
                top: h * 0.33,
                right: w * 0.04,
                width: w * 0.46,
                height: h * 0.25,
                child: _card(
                  // width: w * 0.46,
                  // height: h * 0.22,
                  radius: 20,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'رسالة لنا',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'أنا كمان أقدر أشكر ربنا على الحاجات الصغيرة اللي عندي: أسرتي، أصحابي، المدرسة، الأكل... حتى الإنترنت والموبايل ممكن أستخدمهم عشان أشكر ربنا.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
