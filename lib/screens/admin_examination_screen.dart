import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class AdminExaminationScreen extends StatefulWidget {
  const AdminExaminationScreen({super.key});

  @override
  State<AdminExaminationScreen> createState() =>
      _AdminExaminationScreenState();
}

class _AdminExaminationScreenState extends State<AdminExaminationScreen> {
  String? _expandedDept; // which department card is expanded
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final studentsSnap =
          await FirebaseFirestore.instance.collection('students').get();

      // Group by department
      final deptMap = <String, List<Map<String, dynamic>>>{};
      for (final doc in studentsSnap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final dept = data['department']?.toString() ?? 'Unknown';
        deptMap[dept] = [...(deptMap[dept] ?? []), data];
      }

      // Build departments list with year-wise counts
      final depts = deptMap.entries.map((e) {
        final students = e.value;

        // Count students per year
        final yearCounts = <String, int>{};
        for (final s in students) {
          final year = s['year']?.toString() ?? 'Unknown';
          yearCounts[year] = (yearCounts[year] ?? 0) + 1;
        }

        // Sort year keys: numeric first (1,2,3…), then alpha
        final sortedYears = yearCounts.keys.toList()
          ..sort((a, b) {
            final ia = int.tryParse(a);
            final ib = int.tryParse(b);
            if (ia != null && ib != null) return ia.compareTo(ib);
            return a.compareTo(b);
          });

        return {
          'name': e.key,
          'students': students.length,
          'data': students,
          'yearCounts': yearCounts,
          'sortedYears': sortedYears,
        };
      }).toList();

      // Sort by student count descending
      depts.sort(
          (a, b) => (b['students'] as int).compareTo(a['students'] as int));

      if (mounted) {
        setState(() {
          _departments = depts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _deptIcon(String dept) {
    if (dept.contains('Computer') || dept.contains('BCA')) {
      return Icons.computer_rounded;
    } else if (dept.contains('IOT') || dept.contains('Internet')) {
      return Icons.device_hub_rounded;
    } else if (dept.contains('Bio') ||
        dept.contains('Food') ||
        dept.contains('Micro')) {
      return Icons.biotech_rounded;
    } else if (dept.contains('BBA') || dept.contains('Management')) {
      return Icons.business_rounded;
    } else if (dept.contains('Commerce') || dept.contains('Com')) {
      return Icons.account_balance_rounded;
    } else if (dept.contains('Forensic') || dept.contains('Criminology')) {
      return Icons.policy_rounded;
    } else if (dept.contains('Psychology')) {
      return Icons.psychology_rounded;
    } else if (dept.contains('Fashion') ||
        dept.contains('Visual') ||
        dept.contains('CS & HM')) {
      return Icons.palette_rounded;
    } else {
      return Icons.school_rounded;
    }
  }

  Color _deptColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.blue,
      AppColors.green,
      AppColors.orange,
      AppColors.red,
    ];
    return colors[index % colors.length];
  }

  String _yearLabel(String year) {
    switch (year) {
      case '1':
        return '1st Year';
      case '2':
        return '2nd Year';
      case '3':
        return '3rd Year';
      case '4':
        return '4th Year';
      case '5':
        return '5th Year';
      default:
        return year;
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
          'Examination',
          style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _buildDepartmentList(),
    );
  }

  // ── Department List ────────────────────────────────────────────────────────
  Widget _buildDepartmentList() {
    if (_departments.isEmpty) {
      return const Center(
        child: Text('No departments found',
            style: TextStyle(color: AppColors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _departments.length,
      itemBuilder: (context, index) {
        final dept = _departments[index];
        final color = _deptColor(index);
        final isExpanded = _expandedDept == dept['name'];

        return GestureDetector(
          onTap: () {
            setState(() {
              // Toggle: tap again to collapse
              _expandedDept = isExpanded ? null : dept['name'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: isExpanded ? 0.15 : 0.08),
                    blurRadius: isExpanded ? 18 : 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                // ── Header row ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(_deptIcon(dept['name']),
                            color: color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dept['name'],
                              style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Total Students: ${dept['students']}',
                              style: const TextStyle(
                                  color: AppColors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.grey),
                      ),
                    ],
                  ),
                ),

                // ── Year-wise breakdown (visible when expanded) ──
                if (isExpanded) _buildYearBreakdown(dept, color),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Year-wise Breakdown ────────────────────────────────────────────────────
  Widget _buildYearBreakdown(Map<String, dynamic> dept, Color color) {
    final yearCounts = dept['yearCounts'] as Map<String, int>;
    final sortedYears = dept['sortedYears'] as List<String>;
    final total = dept['students'] as int;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                'Year-wise Attendance',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // One row per year
          ...sortedYears.map((year) {
            final count = yearCounts[year] ?? 0;
            final fraction = total > 0 ? count / total : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _yearLabel(year),
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                      Text(
                        '$count students',
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 8,
                      backgroundColor: color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 18),

          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              Text(
                '$total students',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}