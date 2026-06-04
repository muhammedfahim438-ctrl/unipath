import 'package:flutter/material.dart';
import '../theme.dart';
import 'admin_examination_screen.dart';
import 'admin_appointments_screen.dart';
import 'admin_feedback_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminExaminationScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAppointmentsScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFeedbackScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: const [
                  Icon(Icons.menu_rounded, color: AppColors.white, size: 26),
                  Expanded(
                    child: Center(
                      child: Text('Admin Dashboard',
                          style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Icon(Icons.notifications_none_rounded, color: AppColors.white, size: 26),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                            child: const Icon(Icons.manage_accounts_rounded, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Hello, Admin',
                                  style: TextStyle(color: AppColors.primaryDark, fontSize: 18, fontWeight: FontWeight.w800)),
                              Text('Super Admin', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.people_rounded, color: AppColors.primary),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Students', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                                Text('1,248', style: TextStyle(color: AppColors.primaryDark, fontSize: 22, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Quick Actions',
                          style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 14),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.4,
                        children: [
                          _AdminCard(icon: Icons.assignment_rounded, label: 'Exam', color: AppColors.primary,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminExaminationScreen()))),
                          _AdminCard(icon: Icons.calendar_month_rounded, label: 'Appointments', color: AppColors.orange,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAppointmentsScreen()))),
                          _AdminCard(icon: Icons.bar_chart_rounded, label: 'Analytics', color: AppColors.blue,
                              onTap: () {}),
                          _AdminCard(icon: Icons.feedback_rounded, label: 'Feedback', color: AppColors.green,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFeedbackScreen()))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        backgroundColor: AppColors.white,
        elevation: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Examination'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.feedback_rounded), label: 'Feedback'),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
