import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() =>
      _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _pastAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Load appointments from Firebase ──────────────────────
  Future<void> _loadAppointments() async {
  try {
    final user = AuthService.currentUser;
    final mobile = user?.phoneNumber ?? '';

    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('mobile', isEqualTo: mobile)
        .get();

    final upcoming = <Map<String, dynamic>>[];
    final past = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;

      final dateStr = data['date'] ?? '';
      final parts = dateStr.split(' ');
      if (parts.length >= 2) {
        data['day'] = parts[0];
        data['month'] = parts[1].toUpperCase();
      }

      final status = data['status'] ?? 'pending';
      if (status == 'completed' || status == 'cancelled') {
        past.add(data);
      } else {
        upcoming.add(data);
      }
    }

    if (mounted) {
      setState(() {
        _upcomingAppointments = upcoming;
        _pastAppointments = past;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) setState(() => _isLoading = false);
  }
}

  // ─── Cancel appointment ────────────────────────────────────
  Future<void> _cancelAppointment(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(id)
          .update({'status': 'cancelled'});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Appointment cancelled!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      _loadAppointments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return AppColors.green;
      case 'pending': return AppColors.orange;
      case 'completed': return AppColors.blue;
      case 'cancelled': return AppColors.red;
      default: return AppColors.grey;
    }
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

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
        title: const Text('My Appointments',
            style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14),
          tabs: [
            Tab(
                text:
                    'Upcoming (${_upcomingAppointments.length})'),
            Tab(text: 'Past (${_pastAppointments.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                // ── Upcoming Tab ──
                _upcomingAppointments.isEmpty
                    ? _buildEmpty('No upcoming appointments')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _upcomingAppointments.length,
                        itemBuilder: (context, index) {
                          final appt =
                              _upcomingAppointments[index];
                          return _UpcomingCard(
                            appointment: appt,
                            statusColor: _statusColor(
                                appt['status'] ?? 'pending'),
                            statusLabel: _capitalise(
                                appt['status'] ?? 'pending'),
                            onCancel: () =>
                                _cancelAppointment(appt['id']),
                          );
                        },
                      ),

                // ── Past Tab ──
                _pastAppointments.isEmpty
                    ? _buildEmpty('No past appointments')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pastAppointments.length,
                        itemBuilder: (context, index) {
                          final appt = _pastAppointments[index];
                          return _PastCard(
                            appointment: appt,
                            statusColor: _statusColor(
                                appt['status'] ?? 'completed'),
                            statusLabel: _capitalise(
                                appt['status'] ?? 'completed'),
                          );
                        },
                      ),
              ],
            ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 60, color: AppColors.primaryLight),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(
                  color: AppColors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onCancel;

  const _UpcomingCard({
    required this.appointment,
    required this.statusColor,
    required this.statusLabel,
    required this.onCancel,
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
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                padding:
                    const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Text(appointment['month'] ?? '',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    Text(appointment['day'] ?? '',
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        appointment['session'] ??
                            'Counselling Session',
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.access_time_rounded,
                          size: 13, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(appointment['time'] ?? '',
                          style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 12)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.event_seat_rounded,
                          size: 13, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(appointment['slot'] ?? '',
                          style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 12)),
                    ]),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusColor.withValues(
                              alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(20)),
                      child: Text(statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10)),
                  ),
                  child: const Text('Complete',
                      style: TextStyle(
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(
                        color: AppColors.red, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PastCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final Color statusColor;
  final String statusLabel;

  const _PastCard({
    required this.appointment,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        appointment['studentName'] ?? 'Student';
    final initials = name.isNotEmpty
        ? name[0].toUpperCase()
        : 'S';

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
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle),
                child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                        appointment['session'] ??
                            'Counselling Session',
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                        '${appointment['date'] ?? ''} • ${appointment['time'] ?? ''}',
                        style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusColor.withValues(
                              alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(20)),
                      child: Text(statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
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
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                    color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(
                    vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10)),
              ),
              child: const Text('View Details',
                  style: TextStyle(
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}