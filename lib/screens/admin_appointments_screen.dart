import 'package:flutter/material.dart';
import '../theme.dart';

const List<Map<String, dynamic>> _appointments = [
  {'name': 'Rahul Sharma', 'initials': 'R', 'date': '23 May 2024', 'time': '10:00 AM', 'status': 'Confirmed', 'color': AppColors.green},
  {'name': 'Neha Singh', 'initials': 'N', 'date': '24 May 2024', 'time': '11:30 AM', 'status': 'Pending', 'color': AppColors.orange},
  {'name': 'Amit Verma', 'initials': 'A', 'date': '19 May 2024', 'time': '02:00 PM', 'status': 'Completed', 'color': AppColors.blue},
];

class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('My Appointment',
              style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 18)),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey,
            indicatorColor: AppColors.primary,
            tabs: [Tab(text: 'Upcoming (2)'), Tab(text: 'Past (1)')],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: _appointments.where((a) => a['status'] != 'Completed').map((a) => _AppointmentCard(appt: a)).toList(),
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: _appointments.where((a) => a['status'] == 'Completed').map((a) => _AppointmentCard(appt: a, isPast: true)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appt;
  final bool isPast;

  const _AppointmentCard({required this.appt, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    final statusColor = appt['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), shape: BoxShape.circle),
                child: Center(child: Text(appt['initials'] as String,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appt['name'] as String,
                        style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('${appt['date']} • ${appt['time']}',
                        style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                      child: Text(appt['status'] as String,
                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isPast) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Complete', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
