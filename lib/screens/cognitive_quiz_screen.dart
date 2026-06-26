import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'cognitive_result_screen.dart';

class CognitiveQuizScreen extends StatefulWidget {
  const CognitiveQuizScreen({super.key});

  @override
  State<CognitiveQuizScreen> createState() => _CognitiveQuizScreenState();
}

class _CognitiveQuizScreenState extends State<CognitiveQuizScreen>
    with SingleTickerProviderStateMixin {
  // ── Colors (UniPath brand) ──────────────────────────────────────────────
  static const Color _primary = Color(0xFF5B21B6);
  static const Color _dark = Color(0xFF3B0764);
  static const Color _light = Color(0xFFEDE9FE);
  static const Color _surface = Color(0xFFF8F7FF);

  // ── State ───────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  final Map<int, int> _answers = {}; // questionIndex → score (1-4)
  bool _loading = true;
  bool _submitting = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Domain color map
  static const Map<String, Color> _domainColors = {
    'Attention & Concentration': Color(0xFF7C3AED),
    'Memory & Learning': Color(0xFF2563EB),
    'Logical Reasoning & Problem Solving': Color(0xFF059669),
    'Analytical Thinking': Color(0xFFD97706),
    'Decision Making': Color(0xFFDC2626),
    'Emotional Intelligence': Color(0xFFDB2777),
    'Creativity & Adaptability': Color(0xFF0891B2),
    'Self-Awareness & Growth Mindset': Color(0xFF65A30D),
  };

  static const Map<String, IconData> _domainIcons = {
    'Attention & Concentration': Icons.center_focus_strong_rounded,
    'Memory & Learning': Icons.psychology_rounded,
    'Logical Reasoning & Problem Solving': Icons.account_tree_rounded,
    'Analytical Thinking': Icons.analytics_rounded,
    'Decision Making': Icons.balance_rounded,
    'Emotional Intelligence': Icons.favorite_rounded,
    'Creativity & Adaptability': Icons.lightbulb_rounded,
    'Self-Awareness & Growth Mindset': Icons.self_improvement_rounded,
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _loadQuestions();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Data loading ────────────────────────────────────────────────────────
  Future<void> _loadQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('cognitive_questions')
          .orderBy('order')
          .get();

      if (snapshot.docs.isEmpty) {
        // Seed default 20 questions if collection is empty
        await _seedDefaultQuestions();
        final seeded = await FirebaseFirestore.instance
            .collection('cognitive_questions')
            .orderBy('order')
            .get();
        setState(() {
          _questions = seeded.docs.map((d) => {...d.data(), 'id': d.id}).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _questions =
              snapshot.docs.map((d) => {...d.data(), 'id': d.id}).toList();
          _loading = false;
        });
      }
      _animController.forward();
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $e')),
        );
      }
    }
  }

  Future<void> _seedDefaultQuestions() async {
    final batch = FirebaseFirestore.instance.batch();
    final col = FirebaseFirestore.instance.collection('cognitive_questions');

    final defaults = [
      // Attention & Concentration (1-3)
      {'domain': 'Attention & Concentration', 'order': 1, 'text': 'How well can you concentrate on a difficult task without distractions?'},
      {'domain': 'Attention & Concentration', 'order': 2, 'text': 'How easily can you regain focus after interruptions?'},
      {'domain': 'Attention & Concentration', 'order': 3, 'text': 'How consistently do you complete your planned tasks on time?'},
      // Memory & Learning (4-6)
      {'domain': 'Memory & Learning', 'order': 4, 'text': 'How easily can you remember information after learning it?'},
      {'domain': 'Memory & Learning', 'order': 5, 'text': 'How effectively can you recall instructions and important details?'},
      {'domain': 'Memory & Learning', 'order': 6, 'text': 'How well can you connect new knowledge with previous learning?'},
      // Logical Reasoning (7-9)
      {'domain': 'Logical Reasoning & Problem Solving', 'order': 7, 'text': 'How effectively do you analyze problems before finding solutions?'},
      {'domain': 'Logical Reasoning & Problem Solving', 'order': 8, 'text': 'How comfortable are you when solving new or complex problems?'},
      {'domain': 'Logical Reasoning & Problem Solving', 'order': 9, 'text': 'How often do you verify your solutions before making decisions?'},
      // Analytical Thinking (10-11)
      {'domain': 'Analytical Thinking', 'order': 10, 'text': 'How often do you evaluate information before accepting it as true?'},
      {'domain': 'Analytical Thinking', 'order': 11, 'text': 'How effectively can you identify important information from large amounts of data?'},
      // Decision Making (12-13)
      {'domain': 'Decision Making', 'order': 12, 'text': 'How confidently do you make important decisions?'},
      {'domain': 'Decision Making', 'order': 13, 'text': 'How well do you consider different options before choosing a solution?'},
      // Emotional Intelligence (14-15)
      {'domain': 'Emotional Intelligence', 'order': 14, 'text': 'How effectively do you manage stress during difficult situations?'},
      {'domain': 'Emotional Intelligence', 'order': 15, 'text': 'How well do you understand and control your emotions?'},
      // Creativity & Adaptability (16-17)
      {'domain': 'Creativity & Adaptability', 'order': 16, 'text': 'How often do you generate new ideas or creative solutions?'},
      {'domain': 'Creativity & Adaptability', 'order': 17, 'text': 'How quickly can you learn new skills or adapt to changes?'},
      // Self-Awareness & Growth Mindset (18-20)
      {'domain': 'Self-Awareness & Growth Mindset', 'order': 18, 'text': 'How clearly do you understand your strengths and weaknesses?'},
      {'domain': 'Self-Awareness & Growth Mindset', 'order': 19, 'text': 'How actively do you work towards improving yourself?'},
      {'domain': 'Self-Awareness & Growth Mindset', 'order': 20, 'text': 'How consistently do you work towards achieving your future goals?'},
    ];

    for (final q in defaults) {
      batch.set(col.doc(), {
        ...q,
        'options': ['Strongly Disagree', 'Disagree', 'Agree', 'Strongly Agree'],
        'scores': [1, 2, 3, 4],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  // ── Navigation ──────────────────────────────────────────────────────────
  void _selectAnswer(int score) {
    setState(() => _answers[_currentIndex] = score);
  }

  void _goNext() {
    if (_answers[_currentIndex] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer before continuing.'),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_currentIndex < _questions.length - 1) {
      _animController.reset();
      setState(() => _currentIndex++);
      _animController.forward();
    } else {
      _submitQuiz();
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      _animController.reset();
      setState(() => _currentIndex--);
      _animController.forward();
    }
  }

  // ── Submit ───────────────────────────────────────────────────────────────
  Future<void> _submitQuiz() async {
    setState(() => _submitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final mobile = prefs.getString('loggedInMobile') ?? '';

      // Calculate domain-wise scores
      final Map<String, int> domainScores = {};
      final Map<String, int> domainMax = {};

      for (int i = 0; i < _questions.length; i++) {
        final domain = _questions[i]['domain'] as String;
        final score = _answers[i] ?? 0;
        domainScores[domain] = (domainScores[domain] ?? 0) + score;
        domainMax[domain] = (domainMax[domain] ?? 0) + 4; // max 4 per question
      }

      final totalScore = domainScores.values.fold(0, (a, b) => a + b);
      final maxScore = _questions.length * 4; // 80 for 20 questions

      // Read student data from cached profile (set by AuthService on login)
      Map<String, dynamic> studentData = {};
      final profileJson = prefs.getString('profile');
      if (profileJson != null) {
        try {
          studentData = Map<String, dynamic>.from(
              jsonDecode(profileJson) as Map);
        } catch (_) {}
      }

      // Fallback: query Firestore by mobile if cache missed
      if (studentData.isEmpty && mobile.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('students')
            .where('mobile', isEqualTo: mobile)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          studentData = snap.docs.first.data();
        }
      }

      // Use mobile as doc ID (matches registerStudent which sets doc('+91$mobile'))
      final studentMobile = (studentData['mobile'] as String?)?.isNotEmpty == true
          ? studentData['mobile'] as String
          : mobile;
      final resultRef = FirebaseFirestore.instance
          .collection('cognitive_results')
          .doc(studentMobile.isNotEmpty ? studentMobile : null);

      await resultRef.set({
        'mobile': mobile,
        'name': studentData['name'] ?? '',
        'email': studentData['email'] ?? '',
        'department': studentData['department'] ?? '',
        'year': studentData['year'] ?? '',
        'totalScore': totalScore,
        'maxScore': maxScore,
        'domainScores': domainScores,
        'domainMax': domainMax,
        'answers': _answers.map((k, v) => MapEntry(k.toString(), v)),
        'totalQuestions': _questions.length,
        'createdAt': FieldValue.serverTimestamp(),
        'date': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CognitiveResultScreen(
            totalScore: totalScore,
            maxScore: maxScore,
            domainScores: domainScores,
            domainMax: domainMax,
            studentName: studentData['name'] ?? 'Student',
          ),
        ),
      );
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving results: $e')),
        );
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: _primary),
              const SizedBox(height: 16),
              Text('Loading questions...',
                  style: TextStyle(color: _dark.withValues(alpha: 0.6), fontSize: 15)),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: _surface,
        body: const Center(child: Text('No questions found.')),
      );
    }

    final q = _questions[_currentIndex];
    final domain = q['domain'] as String;
    final domainColor = _domainColors[domain] ?? _primary;
    final domainIcon = _domainIcons[domain] ?? Icons.quiz_rounded;
    final options = (q['options'] as List).cast<String>();
    final scores = (q['scores'] as List).cast<int>();
    final totalQ = _questions.length;
    final progress = (_currentIndex + 1) / totalQ;
    final answeredCount = _answers.length;

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            _buildHeader(progress, answeredCount, totalQ),

            // ── Question card ────────────────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      // Domain tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: domainColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: domainColor.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(domainIcon, size: 16, color: domainColor),
                            const SizedBox(width: 8),
                            Text(
                              domain,
                              style: TextStyle(
                                color: domainColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Question number + text
                      Text(
                        '${_currentIndex + 1}. ${q['text']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Options
                      ...List.generate(options.length, (i) {
                        final isSelected = _answers[_currentIndex] == scores[i];
                        final label =
                            String.fromCharCode(65 + i); // A, B, C, D
                        return _OptionTile(
                          label: label,
                          text: options[i],
                          isSelected: isSelected,
                          primaryColor: _primary,
                          onTap: () => _selectAnswer(scores[i]),
                        );
                      }),

                      const SizedBox(height: 24),

                      // Tip
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFFDE68A), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tip: There are no right or wrong answers. Answer based on your true behaviour.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.amber.shade800,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom navigation ────────────────────────────────────────
            _buildBottomNav(totalQ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double progress, int answered, int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _light,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.arrow_back_rounded, color: _dark, size: 20),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Cognitive Level Test',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                ),
              ),
              Text(
                '$answered / $total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _primary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: _light,
              valueColor: const AlwaysStoppedAnimation<Color>(_primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(int total) {
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == total - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (!isFirst)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goPrev,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          if (!isFirst) const SizedBox(width: 12),

          // Next / Submit button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _goNext,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Icon(
                      isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                      size: 18),
              label: Text(_submitting
                  ? 'Saving...'
                  : isLast
                      ? 'Submit Test'
                      : 'Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Option Tile Widget ───────────────────────────────────────────────────────
class _OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: primaryColor.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : [
                  const BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 4,
                      offset: Offset(0, 1))
                ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? primaryColor : const Color(0xFF374151),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: primaryColor, size: 22),
          ],
        ),
      ),
    );
  }
}