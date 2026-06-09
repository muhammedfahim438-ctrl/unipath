import 'package:flutter/material.dart';
import '../theme.dart';
import 'booking_confirmation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

// ─────────────────────────────────────────
//  Screen 8 — Book Counselling
//  Save to: lib/screens/book_counselling_screen.dart
// ─────────────────────────────────────────

class BookCounsellingScreen extends StatefulWidget {
  const BookCounsellingScreen({super.key});

  @override
  State<BookCounsellingScreen> createState() => _BookCounsellingScreenState();
}

class _BookCounsellingScreenState extends State<BookCounsellingScreen> {
  // ✅ FIX 1: Always start from the CURRENT month, not a hardcoded date
  late DateTime _focusedMonth;
  DateTime? _selectedDate;
  String? _selectedTime;
  int? _selectedSlot;
  bool _isLoading = false;

  // ✅ FIX 2: Compute today and the 30-day deadline once
  final DateTime _today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  late final DateTime _maxDate;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_today.year, _today.month);
    _maxDate = _today.add(const Duration(days: 30));
  }

  final List<String> _times = [
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  final List<String> _slots = ['Slot 1', 'Slot 2', 'Slot 3', 'Slot 4'];

  // ✅ FIX 3: Block going to a month before the current month
  void _previousMonth() {
    final prevMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    if (!prevMonth.isBefore(DateTime(_today.year, _today.month))) {
      setState(() => _focusedMonth = prevMonth);
    }
  }

  // ✅ FIX 4: Block going beyond the month that contains maxDate
  void _nextMonth() {
    final nextMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    final maxMonth = DateTime(_maxDate.year, _maxDate.month);
    if (!nextMonth.isAfter(maxMonth)) {
      setState(() => _focusedMonth = nextMonth);
    }
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // ✅ FIX 5: Holiday logic — every Sunday + 2nd & 3rd Saturday are holidays
  bool _isHoliday(DateTime day) {
    // Sunday (weekday == 7)
    if (day.weekday == DateTime.sunday) return true;

    // Saturday (weekday == 6) — check if it's the 2nd or 3rd Saturday
    if (day.weekday == DateTime.saturday) {
      // Count how many Saturdays have occurred in this month up to and including `day`
      int saturdayCount = 0;
      for (int d = 1; d <= day.day; d++) {
        final dt = DateTime(day.year, day.month, d);
        if (dt.weekday == DateTime.saturday) saturdayCount++;
      }
      // 2nd or 3rd Saturday → holiday
      if (saturdayCount == 2 || saturdayCount == 3) return true;
    }

    return false;
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    // Offset: Mon=1 … Sun=7 → Mon column = 0
    final offset = firstDay.weekday == 7 ? 0 : firstDay.weekday - 1;

    List<DateTime?> days = [];

    for (int i = 0; i < offset; i++) {
      days.add(null);
    }
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }
    while (days.length % 7 != 0) {
      days.add(null);
    }

    return days;
  }

  Future<void> _confirmBooking() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date')));
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time')));
      return;
    }
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a slot')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cached = await AuthService.getCachedProfile();
      final studentName = cached?['name'] ?? 'Student';
      final studentDept = cached?['department'] ?? '';
      final studentMobile = cached?['mobile'] ?? '';
      final studentYear = cached?['year'] ?? '';

      final dateStr =
          '${_selectedDate!.day} ${_monthName(_selectedDate!.month)} ${_selectedDate!.year}';

      await FirebaseFirestore.instance.collection('appointments').add({
        'studentName': studentName,
        'department': studentDept,
        'mobile': studentMobile,
        'year': studentYear,
        'date': dateStr,
        'dateTimestamp': _selectedDate,
        'time': _selectedTime,
        'slot': _slots[_selectedSlot!],
        'session': 'Counselling Session',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _notifyFaculty(
        studentName: studentName,
        date: dateStr,
        time: _selectedTime!,
        slot: _slots[_selectedSlot!],
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            date: dateStr,
            time: _selectedTime!,
            slot: _slots[_selectedSlot!],
            session: 'Counselling Session',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _notifyFaculty({
    required String studentName,
    required String date,
    required String time,
    required String slot,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'new_booking',
        'title': 'New Counselling Booking',
        'message': '$studentName has booked a session on $date at $time ($slot)',
        'studentName': studentName,
        'date': date,
        'time': time,
        'slot': slot,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Notification failure shouldn't block booking
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays();
    final dayHeaders = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Counselling',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            const Text(
              'Select Date',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 14),

            // ── Calendar ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Month Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ Disable left arrow if already on current month
                      IconButton(
                        onPressed: _focusedMonth.year == _today.year &&
                                _focusedMonth.month == _today.month
                            ? null
                            : _previousMonth,
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: _focusedMonth.year == _today.year &&
                                  _focusedMonth.month == _today.month
                              ? AppColors.grey.withValues(alpha: 0.3)
                              : AppColors.primary,
                        ),
                      ),
                      Text(
                        '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      // ✅ Disable right arrow if next month is beyond maxDate's month
                      IconButton(
                        onPressed: _focusedMonth.year == _maxDate.year &&
                                _focusedMonth.month == _maxDate.month
                            ? null
                            : _nextMonth,
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: _focusedMonth.year == _maxDate.year &&
                                  _focusedMonth.month == _maxDate.month
                              ? AppColors.grey.withValues(alpha: 0.3)
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Day headers
                  Row(
                    children: dayHeaders
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(
                                  d,
                                  style: const TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 8),

                  // Calendar grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: days.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      if (day == null) return const SizedBox();

                      final isSelected = _selectedDate != null &&
                          _selectedDate!.day == day.day &&
                          _selectedDate!.month == day.month &&
                          _selectedDate!.year == day.year;

                      final isToday = _today.day == day.day &&
                          _today.month == day.month &&
                          _today.year == day.year;

                      // ✅ Past = before today
                      final isPast = day.isBefore(_today);

                      // ✅ Beyond 30-day window
                      final isBeyondRange = day.isAfter(_maxDate);

                      // ✅ Holiday = Sunday or 2nd/3rd Saturday
                      final isHoliday = _isHoliday(day);

                      // A day is disabled if it's past, beyond range, or a holiday
                      final isDisabled = isPast || isBeyondRange || isHoliday;

                      return GestureDetector(
                        onTap: isDisabled
                            ? null
                            : () => setState(() => _selectedDate = day),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : isToday
                                    ? AppColors.primaryLight
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: isDisabled
                                    ? AppColors.grey.withValues(alpha: 0.35)
                                    : isSelected
                                        ? AppColors.white
                                        : isToday
                                            ? AppColors.primary
                                            : AppColors.primaryDark,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Select Time ──
            const Text(
              'Select Time',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _times.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : AppColors.greyLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Select Slot ──
            const Text(
              'Select Slot',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: List.generate(_slots.length, (index) {
                final isSelected = _selectedSlot == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSlot = index),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: index < _slots.length - 1 ? 10 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _slots[index],
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // ── Confirm Booking Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm Booking',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}