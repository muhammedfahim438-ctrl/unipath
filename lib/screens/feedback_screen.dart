import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 4;
  final TextEditingController _feedbackController =
      TextEditingController();
  bool _postAnonymously = true;
  bool _isSubmitting = false;

  final List<String> _ratingLabels = [
    'Poor', 'Fair', 'Good', 'Great', 'Excellent'
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please write your feedback')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = AuthService.currentUser;
      final cached = await AuthService.getCachedProfile();
      final studentName = cached?['name'] ?? 'Student';
      final department = cached?['department'] ?? '';
      final mobile = user?.phoneNumber ?? '';

      await FirebaseFirestore.instance
          .collection('feedback')
          .add({
        'rating': _rating,
        'ratingLabel': _ratingLabels[_rating - 1],
        'feedback': _feedbackController.text.trim(),
        'isAnonymous': _postAnonymously,
        'studentName':
            _postAnonymously ? 'Anonymous' : studentName,
        'department': department,
        'mobile': _postAnonymously ? '' : mobile,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF22C55E), size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Thank You!',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark)),
              const SizedBox(height: 8),
              const Text(
                'Your feedback has been submitted successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppColors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10)),
                  ),
                  child: const Text('Done',
                      style:
                          TextStyle(color: AppColors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting feedback: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Feedback',
            style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Rate your experience',
                style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            // ── Star Rating ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _rating = starIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6),
                    child: Icon(
                      starIndex <= _rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: starIndex <= _rating
                          ? const Color(0xFFFBBF24)
                          : AppColors.grey
                              .withValues(alpha: 0.4),
                      size: 44,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _ratingLabels[_rating - 1],
                  key: ValueKey(_rating),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Feedback Text ──
            const Text('Write your feedback',
                style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ValueListenableBuilder(
              valueListenable: _feedbackController,
              builder: (context, value, child) {
                final charCount = value.text.length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _feedbackController,
                      maxLength: 300,
                      maxLines: 5,
                      style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 14),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'Write your feedback...',
                        hintStyle: TextStyle(
                            color: AppColors.grey
                                .withValues(alpha: 0.6)),
                        filled: true,
                        fillColor: AppColors.greyLight,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2)),
                        contentPadding:
                            const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('$charCount / 300',
                        style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12)),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Anonymous Toggle ──
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: const [
                        Text('Post Anonymously',
                            style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        SizedBox(height: 2),
                        Text(
                            'Your identity will be kept private',
                            style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _postAnonymously,
                    onChanged: (val) => setState(
                        () => _postAnonymously = val),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isSubmitting ? null : _submitFeedback,
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
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text('Submit Feedback'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}