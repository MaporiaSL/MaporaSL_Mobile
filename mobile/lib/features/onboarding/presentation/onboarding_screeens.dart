import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<String> images = [
    "assets/onboarding_image1.png",
    "assets/onboarding_image2.png",
    "assets/onboarding_image3.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              children: [
                onboardPage(
                  image: images[0],
                  title: "Life is short and the world is ",
                  highlight: "wide",
                  description:
                      "At Friends tours and travel, we customize reliable and trustworthy educational tours to destinations all over the world",
                  buttonText: "Next",
                ),
                onboardPage(
                  image: images[1],
                  title: "It’s a big world out there go ",
                  highlight: "explore",
                  description:
                      "To get the best of your adventure you just need to leave and go where you like. we are waiting for you",
                  buttonText: "Next",
                ),
                onboardPage(
                  image: images[2],
                  title: "People don't take trips, trips take ",
                  highlight: "people",
                  description:
                      "To get the best of your adventure you just need to leave and go where you like. we are waiting for you",
                  buttonText: "Get Started",
                ),
              ],
            ),
            
            Positioned(
              top: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: currentIndex < 2 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedSlide(
                  offset: currentIndex < 2
                      ? Offset.zero
                      : const Offset(0, -0.5),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: IgnorePointer(
                    ignoring: currentIndex >= 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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

  Widget onboardPage({
    required String image,
    required String title,
    required String highlight,
    required String description,
    required String buttonText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: SizedBox(
              height:  MediaQuery.of(context).size.height * 0.54,
              width: double.infinity,
              child: Image.asset(image, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(text: title + " "), // normal text
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: BrushHighlight(highlight),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ),

          const Spacer(),

          /// Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: currentIndex == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.blue
                      : Colors.blue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          /// Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (currentIndex < 2) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                    );
                  } else {
                    // Navigate to main app screen
                    // TODO: Replace with your home screen
                    // Example: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class BrushHighlight extends StatelessWidget {
  final String text;

  const BrushHighlight(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          bottom: -6,
          child: CustomPaint(
            size: Size(text.length * 16.0, 14),
            painter: BrushUnderlinePainter(),
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFF6B35),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class BrushUnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF6B35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Start left
    path.moveTo(0, size.height * 0.6);

    // Smooth upward curve (thicker center illusion)
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width,
      size.height * 0.6,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}