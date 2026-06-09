import 'package:flutter/material.dart';
import '../theme.dart';
import 'book_counselling_screen.dart';
import 'dashboard_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int visualScore;
  final int auditoryScore;
  final int kinestheticScore;
  final String dominantStyle;
  final bool quizJustCompleted;

  const ResultScreen({
    super.key,
    required this.score,
    required this.visualScore,
    required this.auditoryScore,
    required this.kinestheticScore,
    required this.dominantStyle,
    this.quizJustCompleted = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  String get _label {
    if (widget.score >= 80) return 'Excellent!';
    if (widget.score >= 60) return 'Great!';
    if (widget.score >= 40) return 'Good';
    return 'Keep Going!';
  }

  Color get _labelColor {
    if (widget.score >= 80) return AppColors.green;
    if (widget.score >= 60) return AppColors.primary;
    if (widget.score >= 40) return AppColors.orange;
    return AppColors.red;
  }

  String get _styleDescription {
    switch (widget.dominantStyle) {
      case 'Visual':
        return 'You learn best by seeing. You prefer diagrams, charts, and written instructions.';
      case 'Auditory':
        return 'You learn best by listening. You prefer verbal instructions and discussions.';
      case 'Kinesthetic':
        return 'You learn best by doing. You prefer hands-on activities and practical work.';
      default:
        return 'You are a multi-sensory learner!';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.score / 100,
    ).animate(CurvedAnimation(
        parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primaryDark),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 12),
              const Text('Your Result',
                  style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 30),

              // ── Circular progress ──
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (context, child) {
                  return SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 14,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryLight),
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: _progressAnim.value,
                            strokeWidth: 14,
                            strokeCap: StrokeCap.round,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                          ),
                        ),
                        Text(
                          '${(widget.score * _progressAnim.value).round()}%',
                          style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 36,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              Text(_label,
                  style: TextStyle(
                      color: _labelColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),

              // ── Dominant style ──
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.dominantStyle} Learner',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              // ── Score breakdown ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text('Score Breakdown',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildScoreBar(
                        'Visual',
                        widget.visualScore,
                        AppColors.primary),
                    const SizedBox(height: 8),
                    _buildScoreBar(
                        'Auditory',
                        widget.auditoryScore,
                        AppColors.blue),
                    const SizedBox(height: 8),
                    _buildScoreBar(
                        'Kinesthetic',
                        widget.kinestheticScore,
                        AppColors.green),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Style description ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_rounded,
                            color: AppColors.white,
                            size: 20),
                        SizedBox(width: 8),
                        Text('Counselling Suggestion',
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _styleDescription,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          height: 1.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'You are recommended to book a counselling session with our expert.',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Book Session button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const BookCounsellingScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Book Session'),
                ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            DashboardScreen(quizJustCompleted: widget.quizJustCompleted)),
                    (route) => false,
                  );
                },
                child: const Text('Go to Dashboard',
                    style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 14)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBar(
      String label, int score, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 30,
              backgroundColor:
                  color.withValues(alpha: 0.15),
              valueColor:
                  AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$score/30',
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}