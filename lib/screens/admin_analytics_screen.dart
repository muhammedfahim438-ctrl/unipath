import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() =>
      _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState
    extends State<AdminAnalyticsScreen> {
  bool _isLoading = true;
  int _totalStudents = 0;
  int _totalAppointments = 0;
  int _completedSessions = 0;
  int _pendingSessions = 0;
  int _totalFeedback = 0;
  int _totalThoughts = 0;
  double _avgRating = 0.0;
  Map<String, int> _departmentWise = {};
  Map<String, int> _appointmentsByStatus = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      // ── Students ──
      final studentsSnap = await FirebaseFirestore.instance
          .collection('students')
          .get();

      // ── Appointments ──
      final appointmentsSnap = await FirebaseFirestore
          .instance
          .collection('appointments')
          .get();

      // ── Feedback ──
      final feedbackSnap = await FirebaseFirestore.instance
          .collection('feedback')
          .get();

      // ── Thoughts ──
      final thoughtsSnap = await FirebaseFirestore.instance
          .collection('thoughts')
          .get();

      // Calculate stats
      final completed = appointmentsSnap.docs
          .where((d) => d['status'] == 'completed')
          .length;
      final pending = appointmentsSnap.docs
          .where((d) => d['status'] == 'pending')
          .length;
      final cancelled = appointmentsSnap.docs
          .where((d) => d['status'] == 'cancelled')
          .length;

      // Average rating
      double totalRating = 0;
      for (final doc in feedbackSnap.docs) {
        totalRating +=
            (doc['rating'] as num?)?.toDouble() ?? 0;
      }
      final avgRating = feedbackSnap.docs.isEmpty
          ? 0.0
          : totalRating / feedbackSnap.docs.length;

      // Department wise students
      final deptMap = <String, int>{};
      for (final doc in studentsSnap.docs) {
        final dept =
            doc['department']?.toString() ?? 'Unknown';
        deptMap[dept] = (deptMap[dept] ?? 0) + 1;
      }

      // Sort by count
      final sortedDepts = Map.fromEntries(
        deptMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );

      if (mounted) {
        setState(() {
          _totalStudents = studentsSnap.docs.length;
          _totalAppointments = appointmentsSnap.docs.length;
          _completedSessions = completed;
          _pendingSessions = pending;
          _totalFeedback = feedbackSnap.docs.length;
          _totalThoughts = thoughtsSnap.docs.length;
          _avgRating = avgRating;
          _departmentWise = sortedDepts;
          _appointmentsByStatus = {
            'Completed': completed,
            'Pending': pending,
            'Cancelled': cancelled,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Analytics Dashboard',
            style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.white),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ── Stats Grid ──
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _StatCard(
                          title: 'Total Students',
                          value: '$_totalStudents',
                          icon: Icons.people_rounded,
                          color: AppColors.primary,
                          lightColor: AppColors.primaryLight,
                        ),
                        _StatCard(
                          title: 'Total Appointments',
                          value: '$_totalAppointments',
                          icon: Icons.calendar_month_rounded,
                          color: AppColors.blue,
                          lightColor:
                              const Color(0xFFDBEAFE),
                        ),
                        _StatCard(
                          title: 'Completed Sessions',
                          value: '$_completedSessions',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.green,
                          lightColor:
                              const Color(0xFFDCFCE7),
                        ),
                        _StatCard(
                          title: 'Pending Sessions',
                          value: '$_pendingSessions',
                          icon: Icons.pending_rounded,
                          color: AppColors.orange,
                          lightColor:
                              const Color(0xFFFFEDD5),
                        ),
                        _StatCard(
                          title: 'Total Feedback',
                          value: '$_totalFeedback',
                          icon: Icons.feedback_rounded,
                          color: AppColors.primary,
                          lightColor: AppColors.primaryLight,
                        ),
                        _StatCard(
                          title: 'Avg Rating',
                          value:
                              '${_avgRating.toStringAsFixed(1)} ⭐',
                          icon: Icons.star_rounded,
                          color: const Color(0xFFF59E0B),
                          lightColor:
                              const Color(0xFFFEF3C7),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Appointment Status ──
                    _buildSectionTitle('Appointment Status'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: _appointmentsByStatus
                            .entries
                            .map((e) => _buildProgressRow(
                                  e.key,
                                  e.value,
                                  _totalAppointments,
                                  _statusColor(e.key),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Department wise ──
                    _buildSectionTitle(
                        'Students by Department'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: _departmentWise.isEmpty
                          ? const Center(
                              child: Text(
                                  'No data available',
                                  style: TextStyle(
                                      color: AppColors.grey)))
                          : Column(
                              children: _departmentWise
                                  .entries
                                  .take(10)
                                  .map((e) =>
                                      _buildDeptRow(
                                          e.key,
                                          e.value,
                                          _totalStudents))
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // ── Engagement ──
                    _buildSectionTitle(
                        'Student Engagement'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _EngagementCard(
                            title: 'Thoughts Shared',
                            value: '$_totalThoughts',
                            icon: Icons
                                .chat_bubble_rounded,
                            color: AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _EngagementCard(
                            title: 'Feedback Given',
                            value: '$_totalFeedback',
                            icon: Icons.feedback_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed': return AppColors.green;
      case 'Pending': return AppColors.orange;
      case 'Cancelled': return AppColors.red;
      default: return AppColors.grey;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark));
  }

  Widget _buildProgressRow(
      String label, int value, int total, Color color) {
    final percent =
        total == 0 ? 0.0 : value / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
              Text('$value',
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor:
                  color.withValues(alpha: 0.1),
              valueColor:
                  AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeptRow(
      String dept, int count, int total) {
    final percent =
        total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(dept,
                    style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text('$count',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor:
                  AppColors.primaryLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                      AppColors.primary),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color lightColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(title,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Engagement Card ───────────────────────────────────────────
class _EngagementCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _EngagementCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey)),
        ],
      ),
    );
  }
}