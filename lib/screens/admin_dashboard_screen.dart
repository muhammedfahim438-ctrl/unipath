import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import 'welcome_screen.dart';
import '../services/auth_service.dart';
import 'admin_appointments_screen.dart';
import 'admin_examination_screen.dart';
import 'admin_feedback_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_csv_screen.dart';
import 'admin_students_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // ✅ All stats that match the Analytics screen
  int _totalStudents = 0;
  int _totalAppointments = 0;
  int _completedSessions = 0;
  int _pendingSessions = 0;
  int _cancelledSessions = 0;
  int _totalFeedback = 0;
  double _avgRating = 0.0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      // ✅ Run all queries in parallel — same as Analytics screen
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('students').get(),
        FirebaseFirestore.instance.collection('appointments').get(),
        FirebaseFirestore.instance.collection('feedback').get(),
      ]);

      final studentsSnap     = results[0];
      final appointmentsSnap = results[1];
      final feedbackSnap     = results[2];

      // ✅ Count appointment statuses (case-insensitive, same as Analytics)
      int completed = 0, pending = 0, cancelled = 0;
      for (final doc in appointmentsSnap.docs) {
        final status =
            (doc.data()['status'] ?? '').toString().toLowerCase().trim();
        if (status == 'completed') {
          completed++;
        } else if (status == 'pending') {
          pending++;
        } else if (status == 'cancelled') {
          cancelled++;
        }
      }

      // ✅ Average rating — same logic as Analytics screen
      double totalRating = 0;
      int ratingCount = 0;
      for (final doc in feedbackSnap.docs) {
        final data = doc.data();
        if (data.containsKey('rating') && data['rating'] != null) {
          totalRating += (data['rating'] as num).toDouble();
          ratingCount++;
        }
      }
      final avgRating = ratingCount == 0 ? 0.0 : totalRating / ratingCount;

      if (mounted) {
        setState(() {
          _totalStudents      = studentsSnap.docs.length;
          _totalAppointments  = appointmentsSnap.docs.length;
          _completedSessions  = completed;
          _pendingSessions    = pending;
          _cancelledSessions  = cancelled;
          _totalFeedback      = feedbackSnap.docs.length;
          _avgRating          = avgRating;
          _isLoading          = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  // ── Screens for each nav tab ──
  Widget _buildBody() {
    // Home dashboard content
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Welcome Row ──
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(Icons.person,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Hello, Admin',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark)),
                          Text('Super Admin',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Stats Grid — now shows real values like Analytics ──
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard(
                        'Total Students',
                        '$_totalStudents',
                        Icons.people_rounded,
                        AppColors.primary,
                        AppColors.primaryLight,
                      ),
                      _buildStatCard(
                        'Total Appointments',
                        '$_totalAppointments',
                        Icons.calendar_month_rounded,
                        AppColors.blue,
                        const Color(0xFFDBEAFE),
                      ),
                      _buildStatCard(
                        'Completed Sessions',
                        '$_completedSessions',
                        Icons.check_circle_rounded,
                        AppColors.green,
                        const Color(0xFFDCFCE7),
                      ),
                      _buildStatCard(
                        'Pending Sessions',
                        '$_pendingSessions',
                        Icons.pending_rounded,
                        AppColors.orange,
                        const Color(0xFFFFEDD5),
                      ),
                      _buildStatCard(
                        'Cancelled Sessions',
                        '$_cancelledSessions',
                        Icons.cancel_rounded,
                        AppColors.red,
                        const Color(0xFFFEE2E2),
                      ),
                      // ✅ NEW: Total Feedback card
                      _buildStatCard(
                        'Total Feedback',
                        '$_totalFeedback',
                        Icons.feedback_rounded,
                        AppColors.primary,
                        AppColors.primaryLight,
                      ),
                      // ✅ NEW: Avg Rating card
                      _buildStatCard(
                        'Avg Rating',
                        '${_avgRating.toStringAsFixed(1)} ★',
                        Icons.star_rounded,
                        const Color(0xFFF59E0B),
                        const Color(0xFFFEF3C7),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Quick Actions ──
                  const Text('Quick Actions',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 16),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildActionCard(
                        'Examination',
                        Icons.assignment_rounded,
                        AppColors.primary,
                        AppColors.primaryLight,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AdminExaminationScreen()),
                        ),
                      ),
                      _buildActionCard(
                        'Appointments',
                        Icons.calendar_today_rounded,
                        AppColors.blue,
                        const Color(0xFFDBEAFE),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AdminAppointmentsScreen()),
                        ),
                      ),
                      _buildActionCard(
                        'Analytics',
                        Icons.bar_chart_rounded,
                        AppColors.green,
                        const Color(0xFFDCFCE7),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AdminAnalyticsScreen()),
                        ),
                      ),
                      _buildActionCard(
                        'Feedback',
                        Icons.feedback_rounded,
                        AppColors.orange,
                        const Color(0xFFFFEDD5),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AdminFeedbackScreen()),
                        ),
                      ),
                      _buildActionCard(
  'Students',
  Icons.people_rounded,
  AppColors.primary,
  AppColors.primaryLight,
  () => Navigator.push(
    context,
    MaterialPageRoute(
        builder: (_) => const AdminStudentsScreen()),
  ),
),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Logout Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.primary),
                      label: const Text('Logout',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminCsvScreen()),
              ),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.download_rounded, color: AppColors.white),
              label: const Text('CSV Report',
                  style: TextStyle(
                      color: AppColors.white, fontWeight: FontWeight.w600)),
            ),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        title: const Text('Admin Dashboard',
            style: TextStyle(
                color: AppColors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.white),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color lightColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(title,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    Color lightColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark)),
          ],
        ),
      ),
    );
  }
}