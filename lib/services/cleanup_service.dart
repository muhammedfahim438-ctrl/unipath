import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────
//  Save to: lib/services/cleanup_service.dart
//
//  Client-side fallback cleanup for old appointments.
//
//  This is a SAFETY NET, not the primary mechanism — the
//  primary cleanup should be a scheduled Cloud Function that
//  runs daily on the server, even when the app is closed.
//  This client-side version only runs when an admin actually
//  opens the app, so it complements (not replaces) the
//  Cloud Function. Both are safe to run together since each
//  appointment is only ever deleted once.
//
//  Rule: delete any appointment where:
//    - status is 'completed' or 'cancelled'
//    - dateTimestamp is more than 7 days in the past
//  Also deletes the matching 'notifications' doc, if any.
// ─────────────────────────────────────────

class CleanupService {
  static const _deletableStatuses = ['completed', 'cancelled'];

  /// Deletes old completed/cancelled appointments (7+ days past
  /// their session date) and any matching notification docs.
  /// Safe to call repeatedly — silently does nothing if there's
  /// nothing to clean up. Call this from initState() of the
  /// admin dashboard or admin appointments screen.
  static Future<int> runCleanup() async {
    final db = FirebaseFirestore.instance;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));

    int deletedCount = 0;

    try {
      for (final status in _deletableStatuses) {
        final snapshot = await db
            .collection('appointments')
            .where('status', isEqualTo: status)
            .get();

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final ts = data['dateTimestamp'];

          DateTime? apptDate;
          if (ts is Timestamp) {
            apptDate = ts.toDate();
          } else if (ts is DateTime) {
            apptDate = ts;
          }

          if (apptDate == null) continue;
          if (!apptDate.isBefore(cutoff)) continue;

          // Delete matching notification(s), matched by
          // studentName + date + time (no direct appointmentId
          // link exists on notifications today).
          final studentName = data['studentName'];
          final dateStr = data['date'];
          final time = data['time'];

          if (studentName != null && dateStr != null && time != null) {
            final notifSnap = await db
                .collection('notifications')
                .where('studentName', isEqualTo: studentName)
                .where('date', isEqualTo: dateStr)
                .where('time', isEqualTo: time)
                .get();

            for (final notifDoc in notifSnap.docs) {
              await notifDoc.reference.delete();
            }
          }

          await doc.reference.delete();
          deletedCount++;
        }
      }
    } catch (e) {
      // Cleanup failures should never crash the app or block
      // the screen that triggered it — just skip silently.
    }

    return deletedCount;
  }
}