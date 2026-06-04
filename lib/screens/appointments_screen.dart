import 'package:flutter/material.dart';
import '../theme.dart';

// ─────────────────────────────────────────
//  Screen 10 — My Appointments
//  Save to: lib/screens/appointments_screen.dart
// ─────────────────────────────────────────

// Sample appointment data
const List<Map<String, dynamic>> _upcomingAppointments = [
  {
    'name': 'Counselling Session',
    'date': 'MAY',
    'day': '20',
    'time': '12:00 PM',
    'slot': 'Slot 1',
    'room': 'Counselling Room 1',
    'status': 'Confirmed',
  },
  {
    'name': 'Counselling Session',
    'date': 'MAY',
    'day': '28',
    'time': '02:00 PM',
    'slot': 'Slot 2',
    'room': 'Counselling Room 2',
    'status': 'Pending',
  },
];

const List<Map<String, dynamic>> _pastAppointments = [
  {
    'name': 'Amit Verma',
    'date': 'MAY',
    'day': '19',
    'time': '02:00 PM',
    'slot': 'Slot 1',
    'room': 'Counselling Room 1',
    'status': 'Completed',
    'initials': 'A',
  },
];

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppColors.green;
      case 'Pending':
        return AppColors.orange;
      case 'Completed':
        return AppColors.blue;
      default:
        return AppColors.grey;
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
        title: const Text(
          'My Appointments',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: [
            Tab(
                text:
                    'Upcoming (${_upcomingAppointments.length})'),
            Tab(text: 'Past (${_pastAppointments.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Upcoming Tab ──
          _upcomingAppointments.isEmpty
              ? _EmptyState(message: 'No upcoming appointments')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _upcomingAppointments.length,
                  itemBuilder: (context, index) {
                    final appt = _upcomingAppointments[index];
                    return _UpcomingCard(
                      appointment: appt,
                      statusColor: _statusColor(appt['status']),
                    );
                  },
                ),

          // ── Past Tab ──
          _pastAppointments.isEmpty
              ? _EmptyState(message: 'No past appointments')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pastAppointments.length,
                  itemBuilder: (context, index) {
                    final appt = _pastAppointments[index];
                    return _PastCard(
                      appointment: appt,
                      statusColor: _statusColor(appt['status']),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

// ── Upcoming Appointment Card ──
class _UpcomingCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final Color statusColor;

  const _UpcomingCard({
    required this.appointment,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Badge
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      appointment['date'],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      appointment['day'],
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['name'],
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 13, color: AppColors.grey),
                        const SizedBox(width: 4),
                        Text(
                          appointment['time'],
                          style: const TextStyle(
                              color: AppColors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.event_seat_rounded,
                            size: 13, color: AppColors.grey),
                        const SizedBox(width: 4),
                        Text(
                          appointment['slot'],
                          style: const TextStyle(
                              color: AppColors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: AppColors.grey),
                        const SizedBox(width: 4),
                        Text(
                          appointment['room'],
                          style: const TextStyle(
                              color: AppColors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appointment['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Action Buttons ──
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Session marked as complete!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Complete'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Appointment cancelled')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Past Appointment Card ──
class _PastCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final Color statusColor;

  const _PastCard({
    required this.appointment,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    appointment['initials'] ?? 'A',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['name'],
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appointment['date']} ${appointment['day']} • ${appointment['time']}',
                      style:
                          const TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appointment['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Viewing details...')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ──
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded,
              size: 60, color: AppColors.primaryLight),
          const SizedBox(height: 16),
          Text(message,
              style:
                  const TextStyle(color: AppColors.grey, fontSize: 15)),
        ],
      ),
    );
  }
}
