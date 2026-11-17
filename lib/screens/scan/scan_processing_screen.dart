import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../providers/scan_provider.dart';
import 'match_review_screen.dart';

class ScanProcessingScreen extends StatefulWidget {
  const ScanProcessingScreen({super.key});

  @override
  State<ScanProcessingScreen> createState() => _ScanProcessingScreenState();
}

class _ScanProcessingScreenState extends State<ScanProcessingScreen> {
  Timer? _pollingTimer;
  int _pollCount = 1;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Poll every 1.8 seconds to advance the analysis steps smoothly
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1800), (timer) async {
      final scan = Provider.of<ScanProvider>(context, listen: false);
      final rawShoeCount = scan.session?.shoes.length ?? 0;
      final shoeCount = rawShoeCount > 0 ? rawShoeCount : 1;

      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _pollCount++;
      });

      // Poll real backend in parallel if online
      final results = await scan.pollResults();

      if (_pollCount > shoeCount + 1) {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MatchReviewScreen(resultsData: results),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scan = Provider.of<ScanProvider>(context);
    final rawCount = scan.session?.shoes.length ?? 0;
    final shoeCount = rawCount > 0 ? rawCount : 1;
    final analyzedCount = min(_pollCount - 1, shoeCount).clamp(0, shoeCount);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5E9), // Light green from Figma
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                children: [
                  const Spacer(),

                  // Floating Shoe Illustration with Orbital Ring & Sparkles (Figma Scan_Processing)
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft glow circle
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                        ),

                        // Orbital ring
                        Transform.rotate(
                          angle: -0.28,
                          child: Container(
                            width: 160,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.elliptical(160, 72)),
                              border: Border.all(
                                color: const Color(0xFF84CC16).withValues(alpha: 0.45),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        // Sparkles
                        const Positioned(
                          top: 14,
                          right: 28,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 22,
                            color: Color(0xFF84CC16),
                          ),
                        ),
                        const Positioned(
                          bottom: 22,
                          left: 20,
                          child: Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Color(0xFF65A30D),
                          ),
                        ),

                        // Sneaker image at dynamic angle
                        Transform.rotate(
                          angle: -0.22,
                          child: Image.asset(
                            AppAssets.ftue3ViewfinderShoe,
                            width: 105,
                            height: 105,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.roller_skating,
                              size: 84,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title
                  const Text(
                    'Reading your soles',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  const Text(
                    'We\'re analyzing each pair to identify the shoe, materials, condition, and potential next steps.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Progress Counter (Figma: "3 of 4 pairs analyzed")
                  Text(
                    '$analyzedCount of $shoeCount ${shoeCount == 1 ? "pair" : "pairs"} analyzed',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Analysis Step Checklist (Figma Scan_Processing)
                  for (int i = 0; i < shoeCount; i++)
                    _buildAnalysisStep(
                      shoeNumber: i + 1,
                      isDone: (_pollCount - 1) > i,
                      isAnalyzing: (_pollCount - 1) == i,
                    ),

                  const Spacer(),

                  // Footer
                  const Text(
                    'SHOEDNA PROCESSING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF65A30D),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisStep({
    required int shoeNumber,
    required bool isDone,
    required bool isAnalyzing,
  }) {
    final isWaiting = !isDone && !isAnalyzing;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: isWaiting
            ? const Color(0xFFD6F0CE).withValues(alpha: 0.4)
            : const Color(0xFFD6F0CE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF16A34A)
                  : (isAnalyzing ? Colors.white : Colors.white.withValues(alpha: 0.6)),
              shape: BoxShape.circle,
            ),
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : isAnalyzing
                    ? const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                        ),
                      )
                    : const Center(
                        child: Text(
                          '•',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
          ),
          const SizedBox(width: 14),
          Text(
            isDone
                ? 'Shoe $shoeNumber Identified'
                : isAnalyzing
                    ? 'Shoe $shoeNumber Analyzing...'
                    : 'Shoe $shoeNumber Waiting...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isWaiting
                  ? const Color(0xFF64748B)
                  : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
