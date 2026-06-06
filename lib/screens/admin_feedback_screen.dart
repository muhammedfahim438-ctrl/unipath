import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() =>
      _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState
    extends State<AdminFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDept = 'All Departments';
  List<Map<String, dynamic>> _feedbackData = [];
  List<Map<String, dynamic>> _thoughtsData = [];
  bool _isLoading = true;

  final List<String> _departments = [
    'All Departments',
    'B.Com Computer Applications',
    'B.Com Professional Accounting',
    'B.Com Information Technology',
    'B.Com Banking',
    'B.Com Business Analytics',
    'B.Com Accounting & Finance',
    'M.Com Finance and Control',
    'B.Sc Computer Science',
    'BCA',
    'B.Sc Information Technology',
    'B.Sc AI & ML',
    'B.Sc Computer Science with Data Science',
    'B.Sc Internet of Things',
    'BCA Business Analytics',
    'M.Sc Data Science',
    'B.Sc Biotechnology',
    'B.Sc Microbiology',
    'B.Sc Food Science and Nutrition',
    'M.Sc Biotechnology',
    'M.Sc Microbiology',
    'M.Sc Food Science and Nutrition',
    'BBA Computer Applications',
    'BBA International Business',
    'BBA Logistics',
    'BBA Aviation Management',
    'B.Sc CS & HM',
    'B.Sc Costume Design and Fashion',
    'B.Sc Visual Communication',
    'B.Sc Digital and Cyber Forensic Science',
    'B.A Criminology',
    'B.Sc Forensic Science',
    'B.Sc Psychology',
    'M.A Criminology',
    'M.Sc Forensic Science',
    'B.A English Literature',
    'Master of Social Work',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Load feedback and thoughts from Firebase ─────────────
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load feedback
      Query feedbackQuery = FirebaseFirestore.instance
          .collection('feedback')
          .orderBy('createdAt', descending: true);

      if (_selectedDept != 'All Departments') {
        feedbackQuery = feedbackQuery.where('department',
            isEqualTo: _selectedDept);
      }

      final feedbackSnap = await feedbackQuery.get();

      // Load thoughts
      final thoughtsSnap = await FirebaseFirestore.instance
          .collection('thoughts')
          .orderBy('createdAt', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _feedbackData = feedbackSnap.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();

          _thoughtsData = thoughtsSnap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Time ago helper ───────────────────────────────────────
  String _timeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    try {
      final date = timestamp.toDate();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return '';
    }
  }

  // ─── Format date ───────────────────────────────────────────
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final date = timestamp.toDate();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Feedback & Thoughts',
            style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
      ),
      body: Column(
        children: [
          // ── Department Dropdown ──
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primaryLight)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDept,
                  isExpanded: true,
                  icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary),
                  style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                  items: _departments
                      .map((d) => DropdownMenuItem(
                          value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedDept = val);
                      _loadData();
                    }
                  },
                ),
              ),
            ),
          ),

          // ── Tab Bar ──
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey,
            indicatorColor: AppColors.primary,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14),
            tabs: [
              Tab(text: 'Feedback (${_feedbackData.length})'),
              Tab(text: 'Thoughts (${_thoughtsData.length})'),
            ],
          ),

          // ── Tab Content ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // ── Feedback Tab ──
                      _feedbackData.isEmpty
                          ? _buildEmpty('No feedback yet')
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.all(16),
                              itemCount: _feedbackData.length,
                              itemBuilder: (context, index) {
                                final item =
                                    _feedbackData[index];
                                return _FeedbackCard(
                                  item: item,
                                  date: _formatDate(
                                      item['createdAt']),
                                );
                              },
                            ),

                      // ── Thoughts Tab ──
                      _thoughtsData.isEmpty
                          ? _buildEmpty('No thoughts yet')
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.all(16),
                              itemCount: _thoughtsData.length,
                              itemBuilder: (context, index) {
                                final item =
                                    _thoughtsData[index];
                                return _ThoughtCard(
                                  item: item,
                                  timeAgo: _timeAgo(
                                      item['createdAt']),
                                );
                              },
                            ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.feedback_outlined,
              size: 60, color: AppColors.primaryLight),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(
                  color: AppColors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

// ── Feedback Card ─────────────────────────────────────────────
class _FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String date;

  const _FeedbackCard({required this.item, required this.date});

  @override
  Widget build(BuildContext context) {
    final name = item['studentName'] ?? 'Anonymous';
    final initials = name.isNotEmpty
        ? name[0].toUpperCase()
        : 'A';
    final rating = (item['rating'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle),
                child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 17)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(name,
                    style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
              Text(date,
                  style: const TextStyle(
                      color: AppColors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < rating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: i < rating
                    ? const Color(0xFFFBBF24)
                    : AppColors.grey.withValues(alpha: 0.4),
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(item['feedback'] ?? '',
              style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 13,
                  height: 1.4)),
          if (item['department'] != null &&
              item['department'].toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(item['department'],
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}

// ── Thought Card ──────────────────────────────────────────────
class _ThoughtCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String timeAgo;

  const _ThoughtCard(
      {required this.item, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle),
            child: const Center(
              child: Icon(Icons.person_outline,
                  color: AppColors.primary, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Anonymous',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    const Spacer(),
                    Text(timeAgo,
                        style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(item['text'] ?? '',
                    style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 13,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}