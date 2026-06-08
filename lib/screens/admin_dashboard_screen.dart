import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import 'welcome_screen.dart';
import '../services/auth_service.dart';
import 'admin_appointments_screen.dart';
import 'admin_feedback_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_examination_screen.dart';
import 'admin_csv_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  int _totalStudents = 0;
  int _totalAppointments = 0;
  int _completedSessions = 0;
  int _pendingSessions = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Get total students
      final studentsSnap = await FirebaseFirestore.instance
          .collection('students')
          .get();

      // Get appointments
      final appointmentsSnap = await FirebaseFirestore.instance
          .collection('appointments')
          .get();

      final completed = appointmentsSnap.docs
          .where((d) => d['status'] == 'completed')
          .length;
      final pending = appointmentsSnap.docs
          .where((d) => d['status'] == 'pending')
          .length;

      if (mounted) {
        setState(() {
          _totalStudents = studentsSnap.docs.length;
          _totalAppointments = appointmentsSnap.docs.length;
          _completedSessions = completed;
          _pendingSessions = pending;
          _isLoading = false;
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
      MaterialPageRoute(
          builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
        builder: (_) => const AdminCsvScreen()),
  ),
  backgroundColor: AppColors.primary,
  icon: const Icon(Icons.download_rounded,
      color: AppColors.white),
  label: const Text('CSV Report',
      style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600)),
),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        title: const Text('Admin Dashboard',
            style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary))
          : SingleChildScrollView(
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
                          borderRadius:
                              BorderRadius.circular(25),
                        ),
                        child: const Icon(Icons.person,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text('Hello, Admin',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark)),
                          const Text('Super Admin',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Stats Grid ──
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
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
                    physics:
                        const NeverScrollableScrollPhysics(),
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
      builder: (_) => const AdminExaminationScreen()),
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
        builder: (_) => const AdminAppointmentsScreen()),
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
      builder: (_) => const AdminAnalyticsScreen()),
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
      builder: (_) => const AdminFeedbackScreen()),
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
                        side: const BorderSide(
                            color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) =>
            setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        backgroundColor: AppColors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Examination',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback_rounded),
            label: 'Feedback',
          ),
        ],
      ),
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
                      fontSize: 11,
                      color: AppColors.grey)),
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