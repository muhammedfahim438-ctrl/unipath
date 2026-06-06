import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../services/auth_service.dart';

class ThoughtsScreen extends StatefulWidget {
  final bool showAppBar;
  const ThoughtsScreen({super.key, this.showAppBar = true});

  @override
  State<ThoughtsScreen> createState() => _ThoughtsScreenState();
}

class _ThoughtsScreenState extends State<ThoughtsScreen> {
  final _thoughtController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _thoughts = [];

  @override
  void initState() {
    super.initState();
    _loadThoughts();
  }

  @override
  void dispose() {
    _thoughtController.dispose();
    super.dispose();
  }

  // ─── Load all thoughts ─────────────────────────────────────
  Future<void> _loadThoughts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('thoughts')
          .orderBy('createdAt', descending: true)
          .get();

      final thoughts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      if (mounted) {
        setState(() {
          _thoughts = thoughts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Submit thought ────────────────────────────────────────
  Future<void> _submitThought() async {
    if (_thoughtController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please write something first!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final cached = await AuthService.getCachedProfile();
      final department = cached?['department'] ?? '';

      await FirebaseFirestore.instance
          .collection('thoughts')
          .add({
        'text': _thoughtController.text.trim(),
        'department': department,
        'createdAt': FieldValue.serverTimestamp(),
        // Always anonymous — no name saved!
      });

      _thoughtController.clear();
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thought shared anonymously! 💙'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Reload thoughts
      _loadThoughts();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─── Time ago helper ───────────────────────────────────────
  String _timeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    final date = (timestamp as dynamic).toDate();
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Share Your Thoughts',
            style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
      ) : null,
      body: Column(
        children: [
          // ── Post box ──
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What\'s on your mind today?',
                  style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _thoughtController,
                  maxLines: 3,
                  maxLength: 300,
                  style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 14),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText:
                        'Share your thoughts anonymously...',
                    hintStyle: TextStyle(
                        color:
                            AppColors.grey.withValues(alpha: 0.6),
                        fontSize: 13),
                    filled: true,
                    fillColor: AppColors.greyLight,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2)),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 14, color: AppColors.grey),
                    const SizedBox(width: 4),
                    const Text('Your identity is always kept private',
                        style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 12)),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : _submitThought,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2))
                          : const Text('Post',
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Thoughts list ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : _thoughts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.chat_bubble_outline,
                                size: 60,
                                color: AppColors.primaryLight),
                            SizedBox(height: 16),
                            Text('No thoughts shared yet!',
                                style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 16)),
                            Text(
                                'Be the first to share!',
                                style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _thoughts.length,
                        itemBuilder: (context, index) {
                          final thought = _thoughts[index];
                          return _ThoughtCard(
                            thought: thought,
                            timeAgo: _timeAgo(
                                thought['createdAt']),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Thought Card ──────────────────────────────────────────────
class _ThoughtCard extends StatelessWidget {
  final Map<String, dynamic> thought;
  final String timeAgo;

  const _ThoughtCard({
    required this.thought,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Anonymous avatar ──
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person_outline,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Anonymous',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const Spacer(),
                    Text(timeAgo,
                        style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  thought['text'] ?? '',
                  style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 14,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}