import 'package:flutter/material.dart';
import '../theme.dart';
import 'admin_appointments_screen.dart';

// ─────────────────────────────────────────
//  Admin — Select Counsellor
//  Save to: lib/screens/admin_counsellor_select_screen.dart
//
//  Shown when admin taps "Appointments" from the dashboard.
//  Admin picks a counsellor (or "All Counsellors") and is taken
//  to AdminAppointmentsScreen filtered accordingly.
// ─────────────────────────────────────────

class AdminCounsellorSelectScreen extends StatelessWidget {
  const AdminCounsellorSelectScreen({super.key});

  static const List<String> counsellors = [
    'Showmiya SHA',
    'Dr. Rekha B. Raveendran',
    'Ms. Nivedha S',
    'Mr. Kiran Prasadh',
    'Mr. Dhanush Prabhu Ram P K',
  ];

  static const Map<String, String> titles = {
    'Showmiya SHA': 'Assistant Professor & HoD',
    'Dr. Rekha B. Raveendran': 'Assistant Professor',
    'Ms. Nivedha S': 'Assistant Professor',
    'Mr. Kiran Prasadh': 'Assistant Professor',
    'Mr. Dhanush Prabhu Ram P K': 'Assistant Professor',
  };

  void _openAppointments(BuildContext context, String? counsellor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminAppointmentsScreen(counsellorFilter: counsellor),
      ),
    );
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
        title: const Text('Appointments',
            style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Select a counsellor to view their appointments',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // ── All Counsellors ──
          _CounsellorTile(
            name: 'All Counsellors',
            subtitle: 'View every appointment',
            icon: Icons.groups_rounded,
            onTap: () => _openAppointments(context, null),
          ),
          const SizedBox(height: 20),

          const Text(
            'Counsellors',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          ...counsellors.map((name) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CounsellorTile(
                  name: name,
                  subtitle: titles[name] ?? '',
                  icon: Icons.person_rounded,
                  onTap: () => _openAppointments(context, name),
                ),
              )),
        ],
      ),
    );
  }
}

class _CounsellorTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _CounsellorTile({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.grey, fontSize: 12)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.grey, size: 22),
          ],
        ),
      ),
    );
  }
}