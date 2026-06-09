import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

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

  // ─── Show student details popup ───────────────────────────
  Future<void> _showStudentDetails(
      BuildContext context, Map<String, dynamic> appt) async {
    // Try to find student by studentId field first, then by name
    final studentId = appt['studentId'] ?? appt['userId'] ?? '';
    final studentName = appt['studentName'] ?? '';

    Map<String, dynamic>? studentData;

    try {
      // Try fetching by document ID
      if (studentId.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .get();
        if (doc.exists) studentData = doc.data();
      }

      // Fallback: query by name
      if (studentData == null && studentName.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('students')
            .where('name', isEqualTo: studentName)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) studentData = snap.docs.first.data();
      }
    } catch (_) {}

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => _StudentDetailsDialog(
        appt: appt,
        studentData: studentData,
      ),
    );
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
        title: const Text('Appointments',
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
                            onViewDetails: () =>
                                _showStudentDetails(context, appt),
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
                            onViewDetails: () =>
                                _showStudentDetails(context, appt),
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
  final VoidCallback onViewDetails;

  const _AppointmentCard({
    required this.appt,
    required this.statusColor,
    required this.statusLabel,
    required this.isPast,
    required this.onComplete,
    required this.onCancel,
    required this.onViewDetails,
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
                        'Slot: ${appt['slot'] ?? ''} • ${appt['department'] ?? ''}',
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
                onPressed: onViewDetails,
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

// ─── Student Details Dialog ────────────────────────────────
class _StudentDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> appt;
  final Map<String, dynamic>? studentData;

  const _StudentDetailsDialog({
    required this.appt,
    required this.studentData,
  });

  Widget _row(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.grey)),
                const SizedBox(height: 2),
                Text(value.isEmpty ? '—' : value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = studentData ?? {};
    final name = s['name'] ?? appt['studentName'] ?? 'Student';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 10),
              Text(name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark)),
              const SizedBox(height: 4),
              Text(s['department'] ?? appt['department'] ?? '',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.grey)),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Student fields from Firestore
              if (studentData == null)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Student record not found in database.',
                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                )
              else ...[
                _row('Full Name', s['name']?.toString() ?? '', Icons.person_rounded, AppColors.primary),
                _row('Email', s['email']?.toString() ?? '', Icons.email_rounded, AppColors.blue),
                _row('Phone', (s['phone'] ?? s['mobile'] ?? '').toString(), Icons.phone_rounded, AppColors.green),
                _row('Department', s['department']?.toString() ?? '', Icons.school_rounded, AppColors.orange),
                _row('Semester / Year', (s['semester'] ?? s['year'] ?? '').toString(), Icons.menu_book_rounded, AppColors.primary),
                _row('Register No.', (s['registerNo'] ?? s['registrationNumber'] ?? s['rollNo'] ?? '').toString(), Icons.badge_rounded, AppColors.blue),
                if ((s['address'] ?? '').toString().isNotEmpty)
                  _row('Address', s['address'].toString(), Icons.location_on_rounded, AppColors.red),
              ],

              // Appointment info
              const Divider(),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Appointment Info',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark)),
              ),
              const SizedBox(height: 12),
              _row('Date & Time',
                  '${appt['date'] ?? ''} • ${appt['time'] ?? ''}',
                  Icons.calendar_today_rounded, AppColors.primary),
              _row('Slot', appt['slot']?.toString() ?? '',
                  Icons.access_time_rounded, AppColors.orange),
              _row('Status',
                  (appt['status'] ?? '').toString().toUpperCase(),
                  Icons.info_rounded, AppColors.green),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Close',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}