import 'package:flutter/material.dart';
import '../theme.dart';
import 'dashboard_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String date;
  final String time;
  final String slot;
  final String session;

  const BookingConfirmationScreen({
    super.key,
    required this.date,
    required this.time,
    required this.slot,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(45),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF22C55E), size: 50),
              ),
              const SizedBox(height: 24),
              const Text('Your session is confirmed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark)),
              const SizedBox(height: 8),
              const Text('We look forward to helping you.',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.grey)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                        Icons.calendar_today_rounded, 'Date', date),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.access_time_rounded, 'Time', time),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.event_seat_rounded, 'Slot', slot),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.psychology_rounded, 'Session', session),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DashboardScreen()),
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Home',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text('$label: ',
            style: const TextStyle(
                color: AppColors.grey,
                fontSize: 14)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ),
      ],
    );
  }
}