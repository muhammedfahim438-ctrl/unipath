import 'package:flutter/material.dart';
import '../theme.dart';
import 'student_login_screen.dart';
import 'admin_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primaryDark),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose how you want to continue',
                style: TextStyle(color: AppColors.grey, fontSize: 14),
              ),
              const SizedBox(height: 40),
              _RoleCard(
                icon: Icons.manage_accounts_rounded,
                title: 'Admin',
                subtitle: 'Manage and monitor\nthe application',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
                },
              ),
              const SizedBox(height: 20),
              _RoleCard(
                icon: Icons.school_rounded,
                title: 'Student',
                subtitle: 'Access learning and\ncounselling services',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const StudentLoginScreen()));
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryLight, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 13,
                        height: 1.4,
                      )),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
