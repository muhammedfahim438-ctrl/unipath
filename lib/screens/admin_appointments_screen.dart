import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  // null = show all appointments, regardless of counsellor
  final String? counsellorFilter;

  const AdminAppointmentsScreen({super.key, this.counsellorFilter});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState
    extends State<AdminAppointmentsScreen>
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

  // ─── Load ALL appointments from Firebase ──────────────────
  Future<void> _loadAppointments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .orderBy('createdAt', descending: true)
          .get();

      final upcoming = <Map<String, dynamic>>[];
      final past = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // ── Filter by counsellor if one was selected ──
        // (filtered client-side so no Firestore composite index
        // is required for counsellor + orderBy(createdAt))
        if (widget.counsellorFilter != null &&
            data['counsellor'] != widget.counsellorFilter) {
          continue;
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

  // ─── Complete appointment ──────────────────────────────────
  Future<void> _completeAppointment(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(id)
          .update({'status': 'completed'});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Session marked as completed!'),
          backgroundColor: AppColors.green,
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
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Appointments',
                style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
            if (widget.counsellorFilter != null)
              Text(widget.counsellorFilter!,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14),
          tabs: [
            Tab(text:
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
                // ── Upcoming ──
                _upcomingAppointments.isEmpty
                    ? _buildEmpty('No upcoming appointments')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            _upcomingAppointments.length,
                        itemBuilder: (context, index) {
                          final appt =
                              _upcomingAppointments[index];
                          return _AppointmentCard(
                            appt: appt,
                            statusColor: _statusColor(
                                appt['status'] ?? 'pending'),
                            statusLabel: _capitalise(
                                appt['status'] ?? 'pending'),
                            isPast: false,
                            onComplete: () =>
                                _completeAppointment(
                                    appt['id']),
                            onCancel: () =>
                                _cancelAppointment(
                                    appt['id']),
                          );
                        },
                      ),

                // ── Past ──
                _pastAppointments.isEmpty
                    ? _buildEmpty('No past appointments')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pastAppointments.length,
                        itemBuilder: (context, index) {
                          final appt =
                              _pastAppointments[index];
                          return _AppointmentCard(
                            appt: appt,
                            statusColor: _statusColor(
                                appt['status'] ?? 'completed'),
                            statusLabel: _capitalise(
                                appt['status'] ?? 'completed'),
                            isPast: true,
                            onComplete: () {},
                            onCancel: () {},
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

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appt;
  final Color statusColor;
  final String statusLabel;
  final bool isPast;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _AppointmentCard({
    required this.appt,
    required this.statusColor,
    required this.statusLabel,
    required this.isPast,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final name = appt['studentName'] ?? 'Student';
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
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                child: Center(
                  child: Text(initials,
                      style: TextStyle(
                          color: statusColor,
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
                    Text(name,
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                        '${appt['date'] ?? ''} • ${appt['time'] ?? ''}',
                        style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                        'Counsellor: ${appt['counsellor'] ?? ''} • ${appt['department'] ?? ''}',
                        style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                          color: statusColor
                              .withValues(alpha: 0.12),
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
          if (!isPast) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onComplete,
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
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                      color: AppColors.primary, width: 1.5),
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
        ],
      ),
    );
  }
}