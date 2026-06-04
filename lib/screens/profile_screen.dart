import 'package:flutter/material.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile',
            style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 12),
            const Text('John Doe',
                style: TextStyle(color: AppColors.primaryDark, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('1st Year • Computer Science',
                style: TextStyle(color: AppColors.grey, fontSize: 13)),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: const [
                  _InfoRow(icon: Icons.person_rounded, label: 'Name', value: 'John Doe'),
                  Divider(height: 24),
                  _InfoRow(icon: Icons.school_rounded, label: 'Department', value: 'Computer Science'),
                  Divider(height: 24),
                  _InfoRow(icon: Icons.calendar_today_rounded, label: 'Year', value: '1st Year'),
                  Divider(height: 24),
                  _InfoRow(icon: Icons.cake_rounded, label: 'DOB', value: '20 May 2005'),
                  Divider(height: 24),
                  _InfoRow(icon: Icons.person_outline_rounded, label: 'Gender', value: 'Male'),
                  Divider(height: 24),
                  _InfoRow(icon: Icons.phone_rounded, label: 'Mobile No.', value: '+91 98765 43210'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
