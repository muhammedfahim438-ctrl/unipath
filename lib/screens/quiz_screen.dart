import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import 'result_screen.dart';

// ── Section 1 — Visual ────────────────────────────────────────
const List<String> _section1 = [
  'I enjoy doodling and even my notes have lots of pictures and arrows in them.',
  'I remember something better if I write it down.',
  'I get lost or am late if someone tells me how to get somewhere and I don\'t write down directions.',
  'When trying to remember something new, it helps me to get a picture of it in my mind.',
  'If I am taking a test, I can see the textbook page and where the answer is located.',
  'It helps me to look at the person while listening; it keeps me focused.',
  'Using flashcards helps me to retain material for tests.',
  'It\'s hard for me to understand what a person is saying when there are people talking or music playing.',
  'It\'s hard for me to understand a joke when someone tells me.',
  'It is better for me to get work done in a quiet place.',
];

// ── Section 2 — Auditory ──────────────────────────────────────
const List<String> _section2 = [
  'My written work doesn\'t look neat. My papers have crossed-out words and erasures.',
  'It helps to use my finger as a pointer when reading to keep my place.',
  'Papers with very small print or poor copies are tough on me.',
  'I understand how to do something if someone tells me, rather than having to read it.',
  'I remember things that I hear, rather than things that I see or read.',
  'Writing is tiring. I press down too hard with my pen or pencil.',
  'My eyes get tired fast, even though the eye doctor says my eyes are ok.',
  'When I read, I mix up words that look alike, such as "them" and "then".',
  'It\'s hard for me to read other people\'s handwriting.',
  'If I had the choice, I would choose to hear new information rather than read it.',
];

// ── Section 3 — Kinesthetic ───────────────────────────────────
const List<String> _section3 = [
  'I don\'t like to read directions; I\'d rather just start doing.',
  'I learn best when I am shown how to do something and have the opportunity to do it.',
  'Studying at a desk is not for me.',
  'I tend to solve problems through trial-and-error rather than step-by-step.',
  'Before I follow directions, it helps me to see someone else do it first.',
  'I find myself needing frequent breaks while studying.',
  'I am not skilled in giving verbal explanations or directions.',
  'I do not become easily lost, even in strange surroundings.',
  'I think better when I have the freedom to move around.',
  'When I can\'t think of a specific word, I\'ll use my hands a lot.',
];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentSection = 0; // 0=Visual, 1=Auditory, 2=Kinesthetic
  int _currentQuestion = 0;
  int? _selectedScore;
  int _timeLeft = 30 * 60;
  Timer? _timer;
  bool _isSaving = false;

  // Scores for each section
  final List<List<int?>> _answers = [
    List.filled(10, null),
    List.filled(10, null),
    List.filled(10, null),
  ];

  final List<String> _sectionNames = [
    'Section 1 — Visual',
    'Section 2 — Auditory',
    'Section 3 — Kinesthetic',
  ];

  final List<List<String>> _allQuestions = [
    _section1,
    _section2,
    _section3,
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(
        const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        timer.cancel();
        _submitQuiz();
      } else {
        if (mounted) setState(() => _timeLeft--);
      }
    });
  }

  String get _timeDisplay {
    final m = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_timeLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _totalQuestions => 30;
  int get _answeredSoFar =>
      (_currentSection * 10) + _currentQuestion;

  void _nextQuestion() {
    if (_selectedScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select Never, Sometimes or Often')),
      );
      return;
    }

    // Save answer
    _answers[_currentSection][_currentQuestion] = _selectedScore;

    if (_currentQuestion < 9) {
      // Next question in same section
      setState(() {
        _currentQuestion++;
        _selectedScore = _answers[_currentSection][_currentQuestion];
      });
    } else if (_currentSection < 2) {
      // Move to next section
      setState(() {
        _currentSection++;
        _currentQuestion = 0;
        _selectedScore = _answers[_currentSection][_currentQuestion];
      });
    } else {
      // All done!
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
        _selectedScore = _answers[_currentSection][_currentQuestion];
      });
    } else if (_currentSection > 0) {
      setState(() {
        _currentSection--;
        _currentQuestion = 9;
        _selectedScore = _answers[_currentSection][_currentQuestion];
      });
    }
  }

  Future<void> _submitQuiz() async {
    _timer?.cancel();
    setState(() => _isSaving = true);

    // Calculate section totals
    int visualScore = _answers[0]
        .map((a) => a ?? 1)
        .reduce((a, b) => a + b);
    int auditoryScore = _answers[1]
        .map((a) => a ?? 1)
        .reduce((a, b) => a + b);
    int kinestheticScore = _answers[2]
        .map((a) => a ?? 1)
        .reduce((a, b) => a + b);

    // Dominant style
    String dominantStyle = 'Visual';
    int maxScore = visualScore;
    if (auditoryScore > maxScore) {
      dominantStyle = 'Auditory';
      maxScore = auditoryScore;
    }
    if (kinestheticScore > maxScore) {
      dominantStyle = 'Kinesthetic';
    }

    // Score as percentage of max (30)
    final totalScore = visualScore + auditoryScore + kinestheticScore;
    final scorePercent = ((maxScore / 30) * 100).round();

    try {
      final user = AuthService.currentUser;
      final cached = await AuthService.getCachedProfile();
      final name = cached?['name'] ?? 'Student';
      final department = cached?['department'] ?? '';
      final year = cached?['year'] ?? '';
      final mobile = user?.phoneNumber ?? cached?['mobile'] ?? '';

      // FIX #5: Save by BOTH email AND mobile so dashboard can
      // always find the result regardless of login type.
      final email = cached?['email'] ?? '';

      final resultData = {
        'name': name,
        'department': department,
        'year': year,
        'mobile': mobile,
        'email': email,
        'visual_score': visualScore,
        'auditory_score': auditoryScore,
        'kinesthetic_score': kinestheticScore,
        'dominant_style': dominantStyle,
        'total_score': totalScore,
        'score_percent': scorePercent,
        'date': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save under mobile number (for phone-login users)
      if (mobile.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('learning_style_results')
            .doc(mobile)
            .set(resultData);
      }

      // Also save under email (for email-login users)
      if (email.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('learning_style_results')
            .doc(email)
            .set(resultData);
      }
    } catch (e) {
      // Continue even if save fails
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: scorePercent,
          visualScore: _answers[0]
              .map((a) => a ?? 1)
              .reduce((a, b) => a + b),
          auditoryScore: _answers[1]
              .map((a) => a ?? 1)
              .reduce((a, b) => a + b),
          kinestheticScore: _answers[2]
              .map((a) => a ?? 1)
              .reduce((a, b) => a + b),
          dominantStyle: dominantStyle,
          // Tell dashboard not to show the quiz popup again this session
          quizJustCompleted: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _allQuestions[_currentSection][_currentQuestion];
    final overallQuestion = _answeredSoFar + 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _previousQuestion,
                    icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.primaryDark),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        _sectionNames[_currentSection],
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primary, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(_timeDisplay,
                            style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Question ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Q.$overallQuestion',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(currentQ,
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.5)),
                    const SizedBox(height: 32),

                    // ── Score options ──
                    const Text(
                      'How often does this apply to you?',
                      style: TextStyle(
                          color: AppColors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),

                    // Never
                    _buildScoreOption(
                      score: 1,
                      label: 'Never',
                      subtitle: 'Never applies to me',
                      icon: Icons.close_rounded,
                      color: AppColors.red,
                    ),
                    const SizedBox(height: 10),

                    // Sometimes
                    _buildScoreOption(
                      score: 2,
                      label: 'Sometimes',
                      subtitle: 'Sometimes applies to me',
                      icon: Icons.remove_rounded,
                      color: AppColors.orange,
                    ),
                    const SizedBox(height: 10),

                    // Often
                    _buildScoreOption(
                      score: 3,
                      label: 'Often',
                      subtitle: 'Often applies to me',
                      icon: Icons.check_rounded,
                      color: AppColors.green,
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4))
                ],
              ),
              child: Row(
                children: [
                  Text('$overallQuestion of $_totalQuestions',
                      style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: overallQuestion / _totalQuestions,
                        backgroundColor: AppColors.primaryLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            _currentSection == 2 && _currentQuestion == 9
                                ? 'Submit'
                                : 'Next',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreOption({
    required int score,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedScore == score;
    return GestureDetector(
      onTap: () => setState(() => _selectedScore = score),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppColors.greyLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? color
                    : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: isSelected ? Colors.white : color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: isSelected
                              ? color
                              : AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}