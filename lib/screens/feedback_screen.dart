import 'package:flutter/material.dart';
import '../theme.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 4;
  final TextEditingController _feedbackController = TextEditingController();
  bool _postAnonymously = true;

  final List<String> _ratingLabels = ['Poor','Fair','Good','Great','Excellent'];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your feedback')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback submitted! Thank you.'),
        backgroundColor: AppColors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Feedback',
            style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Rate your experience',
                style: TextStyle(color: AppColors.primaryDark, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      starIndex <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: starIndex <= _rating ? const Color(0xFFFBBF24) : AppColors.grey.withOpacity(0.4),
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
                      color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Write your feedback',
                style: TextStyle(color: AppColors.primaryDark, fontSize: 15, fontWeight: FontWeight.w700)),
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
                      style: const TextStyle(color: AppColors.primaryDark, fontSize: 14),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'Write your feedback...',
                        hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.6)),
                        filled: true,
                        fillColor: AppColors.greyLight,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('$charCount / 300',
                        style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                  color: AppColors.greyLight, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Post Anonymously',
                            style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        SizedBox(height: 2),
                        Text('Your identity will be kept private',
                            style: TextStyle(color: AppColors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _postAnonymously,
                    onChanged: (val) => setState(() => _postAnonymously = val),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Submit Feedback'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
