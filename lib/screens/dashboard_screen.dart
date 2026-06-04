import 'package:flutter/material.dart';
import '../theme.dart';
import 'book_counselling_screen.dart';
import 'appointments_screen.dart';
import 'feedback_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';

// ─────────────────────────────────────────
//  Screen 7 — Student Dashboard
//  Save to: lib/screens/dashboard_screen.dart
// ─────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Pages for bottom nav (index 0 = home/dashboard)
  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ChatbotScreen()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Top Row: Greeting + Avatar ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hello, John! 👋',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Hope you\'re having a great day!',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.primary, size: 26),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Feature Cards Grid ──
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.05,
                children: [
                  _FeatureCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Book\nCounselling',
                    color: AppColors.primary,
                    lightColor: AppColors.primaryLight,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BookCounsellingScreen()),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.list_alt_rounded,
                    title: 'My\nAppointments',
                    color: AppColors.blue,
                    lightColor: const Color(0xFFDBEAFE),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AppointmentsScreen()),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.chat_bubble_rounded,
                    title: 'Feedback &\nThoughts',
                    color: AppColors.orange,
                    lightColor: const Color(0xFFFFEDD5),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FeedbackScreen()),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.smart_toy_rounded,
                    title: 'Chatbot\nSupport',
                    color: AppColors.green,
                    lightColor: const Color(0xFFDCFCE7),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ChatbotScreen()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Upcoming Appointment Banner ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.event_rounded,
                          color: AppColors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upcoming Session',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'May 20 • 12:00 PM • Slot 1',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: AppColors.white, size: 16),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ── Bottom Navigation Bar ──
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        backgroundColor: AppColors.white,
        elevation: 10,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_rounded),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ── Feature Card Widget ──
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color lightColor;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.lightColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            Text(
              title,
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
