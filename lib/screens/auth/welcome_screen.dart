import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/earth_video_hero.dart';
import '../navigation/main_nav_scaffold.dart';
import '../scan/camera_capture_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onNext() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _proceedToApp();
    }
  }

  void _proceedToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _skipToScan() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: Column(
              children: [
                // Top page view content
                Expanded(
                  child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildSlide1(),
                  _buildSlide2(),
                  _buildSlide3(),
                  _buildSlide4(),
                  _buildSlide5(),
                ],
              ),
            ),

            // Dots indicator (Exactly 6 dots matching Figma reference)
            // Dots indicator (Exactly 6 dots matching Figma inspect: 150x10, spacing 18)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 9),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFDBFF9C)
                          : const Color(0xFF696969),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
              child: Column(
                children: [
                  // Primary Button (Figma inspect: 300x44, radius 30, fill #DBFF9C, text #201F1F, DM Sans Bold 20)
                  SizedBox(
                    width: 300,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDBFF9C),
                        foregroundColor: const Color(0xFF201F1F),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _onNext,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getButtonText(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                  color: const Color(0xFF201F1F),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: Color(0xFF201F1F),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage != 4) ...[
                    const SizedBox(
                      height: 24,
                    ), // Matches Figma ~26.8 dp gap between buttons
                    // Secondary Button (Figma inspect: 296x42, radius 30, stroke 1px #9AB668, text #9AB668, DM Sans Bold 20)
                    SizedBox(
                      width: 296,
                      height: 42,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF9AB668),
                            width: 1.0,
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _skipToScan,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Skip To Scan',
                              style: GoogleFonts.dmSans(
                                color: const Color(0xFF9AB668),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_currentPage == 4) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Takes 60 seconds · no account required',
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFFD8D8D8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                            children: const [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: AppColors.splashLime,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
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

  String _getButtonText() {
    switch (_currentPage) {
      case 0:
        return 'Accept the Mission';
      case 1:
        return "What we're building";
      case 2:
        return "See what's possible";
      case 3:
        return 'Join the mission';
      case 4:
        return 'Scan my shoes';
      default:
        return 'Next';
    }
  }

  // ─── SLIDE 1: Time to act now (Matches media_1793949039568_a8507e92.jpg) ───
  Widget _buildSlide1() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          // Plain uppercase tag (No box/pill border) - Space Grotesk 14sp
          Text(
            'SPACESHIP EARTH • 2026',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.splashLime,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 18),

          // Earth Orbit Looping Video (or high-res Figma satellite artwork fallback)
          const EarthVideoHero(height: 250),
          const SizedBox(height: 18),

          // Headline & Statistics Group (Figma inspect: W 371, H 138, Spacing 9, DM Sans)
          SizedBox(
            width: 371,
            child: Column(
              children: [
                Text(
                  'Time to act now',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: AppColors.splashLime,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 9), // Exact Figma spacing = 9
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFFD8D8D8),
                      fontSize: 15.5,
                      height: 1.5, // Exact Figma line height = 150%
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w400,
                    ),
                    children: const [
                      TextSpan(
                        text: '23.9 billion',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' pairs of shoes a year for '),
                      TextSpan(
                        text: '8 billion',
                        style: TextStyle(
                          color: AppColors.splashLime,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' people, and just '),
                      TextSpan(
                        text: 'one planet',
                        style: TextStyle(
                          color: AppColors.splashLime,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text:
                            '. Once discarded, they take decades to disappear.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Community Section Title (Figma inspect: W 331, H 68, Space Grotesk Bold 24, Line height 125%, Color #D3C6FF)
          SizedBox(
            width: 331,
            child: Text(
              "This is EarthDNA's\nProject S.H.O.E.S.",
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFFD3C6FF),
                fontSize: 24, // Exact Figma size = 24
                fontWeight: FontWeight.w700, // Exact Figma Bold
                height: 1.25, // Exact Figma 125% line height
                letterSpacing: 0.0, // Exact Figma 0% letter spacing
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Community Subtitle - DM Sans 14sp, Line height 150%
          Text(
            "You've just been recruited as a Sole Saver —\nand welcomed into our Planetary Healers community.",
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              color: const Color(0xFFD8D8D8),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ─── SLIDE 2: The problem lives in your closet (Matches FTUE-2 Figma Inspect) ──
  Widget _buildSlide2() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background High Heel Line-Art (Figma inspect: X 324, Y 532, Rotation -130.61°, Stroke #DBFF9C 30%)
              Positioned(
                right: -25,
                bottom: 8,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.30,
                    child: Image.asset(
                      AppAssets.ftue2HeelIllustration,
                      width: 125,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  // Tag Pill Badge (Figma inspect: 133x18, Space Grotesk Bold 12, fill #DBFF9C, text #201F1F, tracking 4%)
          Container(
            width: 133,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.splashLime,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'MISSION BRIEFING',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFF201F1F),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.48, // 4%
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Main Headline (Figma inspect: 396x72, DM Sans Bold 36, Line height 100%, Color #F3F6EF)
          SizedBox(
            width: 396,
            child: Text(
              'The problem lives in\nyour closet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: const Color(0xFFF3F6EF),
                fontSize: 36,
                fontWeight: FontWeight.w700,
                height: 1.05,
                letterSpacing: 0.0,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Continuous line-art shoes artwork (Figma inspect: Sandal, Sneaker, Heel line-art)
          Image.asset(
            AppAssets.ftue2ShoesIllustration,
            height: 145,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),

          // First Paragraph (Figma inspect: 384x78, DM Sans Medium 16, Line height 150%, 19 pairs bold lime)
          SizedBox(
            width: 384,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.dmSans(
                  color: const Color(0xFFD8D8D8),
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.0,
                ),
                children: [
                  TextSpan(
                    text: 'An average American owns ',
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFFD8D8D8),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '19 pairs of shoes',
                    style: GoogleFonts.dmSans(
                      color: AppColors.splashLime,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text:
                        '. Most sit in a closet until they reach a landfill. No second owner. No second life. Just shelf, then trash.',
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFFD8D8D8),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Second Headline: Every city is running out of room (Figma inspect: Space Grotesk Bold 24, #D3C6FF)
          Text(
            'Every city is running\nout of room.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFD3C6FF),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),

          // Second Paragraph: 22 billion pairs (Figma inspect: DM Sans Medium 16, Line height 150%)
          SizedBox(
            width: 384,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.dmSans(
                  color: const Color(0xFFD8D8D8),
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.0,
                ),
                children: [
                  TextSpan(
                    text: '22 billion pairs',
                    style: GoogleFonts.dmSans(
                      color: AppColors.splashLime,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' land in landfills every year. Most take over ',
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFFD8D8D8),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '1,000 years',
                    style: GoogleFonts.dmSans(
                      color: AppColors.splashLime,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' to disappear. Every pair rescued buys that city more time.',
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFFD8D8D8),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SLIDE 3: Your shoes have been places (Matches FTUE-3 Figma Inspect) ──
  Widget _buildSlide3() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              // Tag Pill Badge (Figma inspect: 225x30, radius 30, fill #DBFF9C, text #201F1F)
              Container(
                width: 225,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.splashLime,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'EVERY SHOE HAS A STORY',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFF201F1F),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Main Headline (Figma inspect: DM Sans Bold 36, #F3F6EF & Lime)
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFFF3F6EF),
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    height: 1.1,
                  ),
                  children: const [
                    TextSpan(text: 'Your shoes have\nbeen '),
                    TextSpan(
                      text: 'places.',
                      style: TextStyle(color: AppColors.splashLime),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Timeline Steps: Made -> Worn -> What Next? (Figma inspect: W 114 each, Spacing 3, Stroke 1px arrow, Lavender & Lime)
              SizedBox(
                width: 364,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 114, // Exact Figma inspect arrow W: 114, H: 0
                      child: _buildTimelineStep(
                        title: 'Made',
                        subtitle: 'Materials + Labor',
                        titleColor: AppColors.ftueLavender,
                        lineColor: AppColors.ftueLavender,
                      ),
                    ),
                    SizedBox(
                      width: 114, // Exact Figma inspect arrow W: 114, H: 0
                      child: _buildTimelineStep(
                        title: 'Worn',
                        subtitle: 'Miles + Memories',
                        titleColor: AppColors.ftueLavender,
                        lineColor: AppColors.ftueLavender,
                      ),
                    ),
                    SizedBox(
                      width: 114, // Exact Figma inspect arrow W: 114, H: 0
                      child: _buildTimelineStep(
                        title: 'What Next?',
                        subtitle: 'You Decide',
                        titleColor: AppColors.splashLime,
                        lineColor: AppColors.splashLime,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Two Paragraphs Group (Figma inspect: W 391, H 179, Spacing 47, DM Sans, Line height 150%)
              SizedBox(
                width: 391,
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFFD8D8D8),
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.0,
                        ),
                        children: [
                          TextSpan(
                            text: 'Most',
                            style: GoogleFonts.dmSans(
                              color: const Color(0xFFF3F6EF),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(
                            text:
                                " end up in landfills.\nNot because there's no other option — but\nbecause a solution was unknown.",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 47), // Exact Figma inspect spacing = 47
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFFD8D8D8),
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.0,
                        ),
                        children: [
                          TextSpan(
                            text: 'ShoeDNA™',
                            style: GoogleFonts.dmSans(
                              color: AppColors.splashLime,
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' AI is here! Take four shoe\nphotos. Less than a minute. Shoes rescued.',
                            style: GoogleFonts.dmSans(
                              color: const Color(0xFFD8D8D8),
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Viewfinder Card & Caption (Figma inspect: W 412, H 238, DM Sans Medium 16)
              SizedBox(
                width: 370,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        AppAssets.ftue3ViewfinderShoe,
                        width: 370,
                        height: 185,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Point. Scan. Discover.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFFD8D8D8),
                        fontSize: 16, // Exact Figma inspect: DM Sans Medium 16
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SLIDE 4: An OS for Earth's sustainable future (Matches FTUE-4 Figma) ──
  Widget _buildSlide4() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              // Pill Badge (Figma inspect: Space Grotesk Bold 12, fill #DBFF9C, text #201F1F)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.splashLime,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'BUILT IN BOSTON',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFF201F1F),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.48, // 4%
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Main Headline (Figma inspect: DM Sans Bold 36, Line height 105%, Color #F3F6EF)
              SizedBox(
                width: 391,
                child: Text(
                  "An OS for Earth's\nsustainable future.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFFF3F6EF),
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description Paragraph (Figma inspect: 391 width, DM Sans Medium 16, Line height 150%)
              SizedBox(
                width: 391,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFFD8D8D8),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.0,
                    ),
                    children: const [
                      TextSpan(
                        text: "Earth didn't come with an operating system. ",
                      ),
                      TextSpan(
                        text: '(OS) EarthDNA',
                        style: TextStyle(
                          color: AppColors.splashLime,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text:
                            " is building it. We're a Boston-based climate tech nonprofit on a mission to put Earth's Data iNto Action (DNA). ",
                      ),
                      TextSpan(
                        text: 'Project S.H.O.E.S.',
                        style: TextStyle(
                          color: AppColors.splashLime,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' is our first AI deployment. Together, we turn material waste into future value.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3D Wireframe Knot Artwork (Figma inspect transparent PNG asset, scaled up)
              Image.asset(
                AppAssets.ftue4WireframeKnot,
                height: 230,
                width: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),

              // Buckminster Fuller Quote Block (Figma inspect: 268x75, Spacing 9, Space Grotesk 150%)
              SizedBox(
                width: 270,
                child: Container(
                  padding: const EdgeInsets.only(left: 14),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppColors.splashLime, width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We are called to be architects\nof the future, not its victims.',
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFFD8D8D8),
                          fontSize: 14.5,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 9), // Exact Figma inspect spacing = 9
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '— R. Buckminster Fuller',
                          style: GoogleFonts.spaceGrotesk(
                            color: AppColors.splashLime,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SLIDE 5: Planetary Healer / Sole Saver Badge (Matches FTUE-5 Figma) ──
  Widget _buildSlide5() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              // Pill Badge (Figma inspect: Space Grotesk Bold 12, fill #DBFF9C, text #201F1F)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.splashLime,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'STAR DATE: 04.20.2026',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFF201F1F),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.48, // 4%
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Main Headline (Figma inspect: 367 width, DM Sans Bold 36, Line height 105%)
              SizedBox(
                width: 367,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFFF3F6EF),
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                      letterSpacing: 0.0,
                    ),
                    children: const [
                      TextSpan(text: 'Today, you are a\nplanetary '),
                      TextSpan(
                        text: 'healer.',
                        style: TextStyle(color: AppColors.splashLime),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle 1 (Figma inspect: DM Sans 16, Line height 150%)
              SizedBox(
                width: 367,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFFD9D9D9),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.0,
                    ),
                    children: const [
                      TextSpan(
                        text: 'The mission is simple. The impact is vast.\n',
                      ),
                      TextSpan(
                        text: 'Four photos. Four angles. One mission.',
                        style: TextStyle(
                          color: AppColors.splashLime,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle 2 (Figma inspect: DM Sans 16, Line height 150%, color #D9D9D9)
              SizedBox(
                width: 367,
                child: Text(
                  'Your shoes become data that changes what happens to millions of pairs. Through collective action, we get one step closer to a planet that wastes nothing.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFFD9D9D9),
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Section Title: "Your badge awaits" (Figma inspect: W 361, H 38, Space Grotesk Medium 30, #F3F6EF)
              SizedBox(
                width: 361,
                child: Text(
                  'Your badge awaits',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFFF3F6EF),
                    fontSize: 30, // Exact Figma inspect: Size 30
                    fontWeight: FontWeight.w500, // Medium
                    height: 1.0, // Line height 100%
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sole Saver Badge Card (High-res Figma transparent PNG asset)
              SizedBox(
                width: 360,
                child: Image.asset(
                  AppAssets.ftue5SoleSaverBadge,
                  width: 360,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required Color titleColor,
    required Color lineColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            color: titleColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.0,
          ),
        ),
        const SizedBox(height: 3), // Exact Figma inspect: Spacing 3
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.visible,
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.0,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 8,
          width: double.infinity,
          child: CustomPaint(
            painter: _TimelineArrowPainter(color: lineColor),
          ),
        ),
      ],
    );
  }
}

class _TimelineArrowPainter extends CustomPainter {
  final Color color;

  const _TimelineArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final y = size.height / 2;
    final endX = size.width;

    // Horizontal line
    canvas.drawLine(Offset(0, y), Offset(endX, y), paint);

    // Chevron arrow tip
    const arrowLen = 5.5;
    const arrowSpread = 3.5;
    final path = Path()
      ..moveTo(endX - arrowLen, y - arrowSpread)
      ..lineTo(endX, y)
      ..lineTo(endX - arrowLen, y + arrowSpread);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TimelineArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
