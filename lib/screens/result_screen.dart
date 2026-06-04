import 'package:flutter/material.dart';
import '../theme.dart';
import 'book_counselling_screen.dart';
import 'dashboard_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  const ResultScreen({super.key, required this.score});

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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
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
              const Spacer(),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
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
                            valueColor: AlwaysStoppedAnimation<Color>(
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
              const SizedBox(height: 20),
              Text(_label,
                  style: TextStyle(
                      color: _labelColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lightbulb_rounded,
                            color: AppColors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Counselling Suggestion',
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You are recommended to book a counselling session with our expert.',
                      style: TextStyle(
                          color: AppColors.white, fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BookCounsellingScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
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
                        builder: (_) => const DashboardScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Go to Dashboard',
                    style: TextStyle(color: AppColors.grey, fontSize: 14)),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
