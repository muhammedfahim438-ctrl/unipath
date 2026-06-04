import 'package:flutter/material.dart';
import '../theme.dart';
import 'booking_confirmation_screen.dart';

class BookCounsellingScreen extends StatefulWidget {
  const BookCounsellingScreen({super.key});

  @override
  State<BookCounsellingScreen> createState() => _BookCounsellingScreenState();
}

class _BookCounsellingScreenState extends State<BookCounsellingScreen> {
  DateTime _focusedMonth = DateTime(2026, 5);
  DateTime? _selectedDate;
  String? _selectedTime;
  int? _selectedSlot;

  final List<String> _times = ['12:00 PM','02:00 PM','03:00 PM','04:00 PM','05:00 PM'];
  final List<String> _slots = ['Slot 1','Slot 2','Slot 3','Slot 4'];

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  String _monthName(int month) {
    const months = ['January','February','March','April','May','June',
        'July','August','September','October','November','December'];
    return months[month - 1];
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final offset = firstDay.weekday == 7 ? 0 : firstDay.weekday;
    List<DateTime?> days = List.filled(offset, null);
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }
    while (days.length % 7 != 0) { days.add(null); }
    return days;
  }

  void _confirmBooking() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a time')));
      return;
    }
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a slot')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(
          date: '${_selectedDate!.day} ${_monthName(_selectedDate!.month)} ${_selectedDate!.year}',
          time: _selectedTime!,
          slot: _slots[_selectedSlot!],
          session: 'Counselling Session',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays();
    final dayHeaders = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Book Counselling',
            style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Select Date',
                style: TextStyle(color: AppColors.primaryDark, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryLight, width: 1.5),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: _previousMonth,
                          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary)),
                      Text('${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                          style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 15)),
                      IconButton(onPressed: _nextMonth,
                          icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: dayHeaders.map((d) => Expanded(
                      child: Center(child: Text(d,
                          style: const TextStyle(color: AppColors.grey, fontSize: 12, fontWeight: FontWeight.w600))),
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: days.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4, childAspectRatio: 1),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      if (day == null) return const SizedBox();
                      final isSelected = _selectedDate != null &&
                          _selectedDate!.day == day.day &&
                          _selectedDate!.month == day.month &&
                          _selectedDate!.year == day.year;
                      final isToday = today.day == day.day && today.month == day.month && today.year == day.year;
                      final isPast = day.isBefore(DateTime(today.year, today.month, today.day));
                      return GestureDetector(
                        onTap: isPast ? null : () => setState(() => _selectedDate = day),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : isToday ? AppColors.primaryLight : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text('${day.day}',
                                style: TextStyle(
                                    color: isPast ? AppColors.grey.withOpacity(0.4) :
                                        isSelected ? AppColors.white :
                                        isToday ? AppColors.primary : AppColors.primaryDark,
                                    fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                                    fontSize: 13)),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Select Time',
                style: TextStyle(color: AppColors.primaryDark, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _times.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.greyLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(time,
                        style: TextStyle(
                            color: isSelected ? AppColors.white : AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Select Slot',
                style: TextStyle(color: AppColors.primaryDark, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(_slots.length, (index) {
                final isSelected = _selectedSlot == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSlot = index),
                    child: Container(
                      margin: EdgeInsets.only(right: index < _slots.length - 1 ? 10 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(_slots[index],
                            style: TextStyle(
                                color: isSelected ? AppColors.white : AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Confirm Booking'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
