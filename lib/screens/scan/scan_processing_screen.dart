import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/scan_provider.dart';
import 'match_review_screen.dart';

class ScanProcessingScreen extends StatefulWidget {
  const ScanProcessingScreen({super.key});

  @override
  State<ScanProcessingScreen> createState() => _ScanProcessingScreenState();
}

class _ScanProcessingScreenState extends State<ScanProcessingScreen> {
  Timer? _pollingTimer;
  int _pollCount = 0;

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
    // Poll backend every 2 seconds for identification results
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      _pollCount++;
      final scan = Provider.of<ScanProvider>(context, listen: false);
      final results = await scan.pollResults();

      if (mounted) setState(() {});

      if (results != null) {
        final status = results['status'] as String? ?? '';
        final allResolved = results['allResolved'] as bool? ?? false;

        if (status == 'review' || allResolved || _pollCount >= 3) {
          timer.cancel();
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MatchReviewScreen(resultsData: results),
              ),
            );
          }
        }
      } else if (_pollCount >= 4) {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const MatchReviewScreen(),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scan = Provider.of<ScanProvider>(context);
    final shoeCount = scan.session?.shoes.length ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5E9), // Light green from Figma Page 43
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              // Floating Shoe Illustration with Sparkles
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.auto_awesome,
                    size: 28,
                    color: Color(0xFF65A30D),
                  ),
                  Positioned(
                    top: 10,
                    right: 20,
                    child: const Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: Color(0xFF84CC16),
                    ),
                  ),
                  Transform.rotate(
                    angle: -0.2,
                    child: const Icon(
                      Icons.roller_skating,
                      size: 88,
                      color: Color(0xFF166534),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Title (Page 43)
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
              const SizedBox(height: 28),

              // Progress Counter
              Text(
                '${(_pollCount > shoeCount ? shoeCount : _pollCount)} of $shoeCount pairs analyzed',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),

              // Analysis Step Checklist (Page 43)
              for (int i = 0; i < shoeCount; i++)
                _buildAnalysisStep(
                  shoeNumber: i + 1,
                  isDone: _pollCount > i,
                  isAnalyzing: _pollCount == i,
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
    );
  }

  Widget _buildAnalysisStep({
    required int shoeNumber,
    required bool isDone,
    required bool isAnalyzing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD6F0CE).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFF16A34A) : Colors.white,
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
                    : null,
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
              color: isDone || isAnalyzing ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
