import 'package:flutter/material.dart';
import 'dart:async';
import '../theme.dart';
import 'result_screen.dart';

const List<Map<String, dynamic>> _questions = [
  {
    'question': 'Which option describes you the best?',
    'options': ['I like to help others','I like solving problems','I prefer creative work','I enjoy leadership roles'],
  },
  {
    'question': 'How do you prefer to study?',
    'options': ['Reading textbooks','Watching videos','Hands-on practice','Group discussions'],
  },
  {
    'question': 'What motivates you most?',
    'options': ['Recognition and praise','Personal growth','Helping others','Financial rewards'],
  },
  {
    'question': 'How do you handle stress?',
    'options': ['Talk to friends','Exercise or sports','Meditation or rest','Work harder to solve it'],
  },
  {
    'question': 'Which subject interests you most?',
    'options': ['Science and Math','Arts and Literature','Social Studies','Physical Education'],
  },
];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  int? _selectedOption;
  int _timeLeft = 30 * 60;
  Timer? _timer;
  final List<int?> _answers = List.filled(5, null);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        timer.cancel();
        _submitQuiz();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  String get _timeDisplay {
    final minutes = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _nextQuestion() {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an answer')),
      );
      return;
    }
    _answers[_currentQuestion] = _selectedOption;
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = _answers[_currentQuestion];
      });
    } else {
      _submitQuiz();
    }
  }

  void _submitQuiz() {
    _timer?.cancel();
    final answered = _answers.where((a) => a != null).length;
    final score = ((answered / _questions.length) * 100).round();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(score: score)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final options = question['options'] as List<String>;
    final optionLabels = ['A', 'B', 'C', 'D'];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.primaryDark),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  const Text('Exam',
                      style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary, width: 1.5),
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Q.${_currentQuestion + 1}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(question['question'] as String,
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            height: 1.4)),
                    const SizedBox(height: 24),
                    ...List.generate(options.length, (index) {
                      final isSelected = _selectedOption == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedOption = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.greyLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.white.withOpacity(0.2)
                                      : AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(optionLabels[index],
                                      style: TextStyle(
                                          color: isSelected ? AppColors.white : AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(options[index],
                                    style: TextStyle(
                                        color: isSelected ? AppColors.white : AppColors.primaryDark,
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4))
                ],
              ),
              child: Row(
                children: [
                  Text('${_currentQuestion + 1} of ${_questions.length}',
                      style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentQuestion + 1) / _questions.length,
                        backgroundColor: AppColors.primaryLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentQuestion == _questions.length - 1 ? 'Submit' : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
}
