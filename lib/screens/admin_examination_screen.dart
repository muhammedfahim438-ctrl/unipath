import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class AdminExaminationScreen extends StatefulWidget {
  const AdminExaminationScreen({super.key});

  @override
  State<AdminExaminationScreen> createState() =>
      _AdminExaminationScreenState();
}

class _AdminExaminationScreenState
    extends State<AdminExaminationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedDept;
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true;
  String _selectedCounsellorDept = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Load all students
      final studentsSnap = await FirebaseFirestore.instance
          .collection('students')
          .get();

      // Group by department
      final deptMap = <String, List<Map<String, dynamic>>>{};
      for (final doc in studentsSnap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final dept = data['department']?.toString() ?? 'Unknown';
        deptMap[dept] = [...(deptMap[dept] ?? []), data];
      }

      // Build departments list
      final depts = deptMap.entries.map((e) => {
        'name': e.key,
        'students': e.value.length,
        'data': e.value,
      }).toList();

      // Sort by student count
      depts.sort((a, b) =>
          (b['students'] as int).compareTo(a['students'] as int));

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
    } else if (dept.contains('IOT') ||
        dept.contains('Internet')) {
      return Icons.device_hub_rounded;
    } else if (dept.contains('Bio') ||
        dept.contains('Food') ||
        dept.contains('Micro')) {
      return Icons.biotech_rounded;
    } else if (dept.contains('BBA') ||
        dept.contains('Management')) {
      return Icons.business_rounded;
    } else if (dept.contains('Commerce') ||
        dept.contains('Com')) {
      return Icons.account_balance_rounded;
    } else if (dept.contains('Forensic') ||
        dept.contains('Criminology')) {
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
          onPressed: () {
            if (_selectedDept != null) {
              setState(() => _selectedDept = null);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Examination',
            style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Department'),
            Tab(text: 'View Appointment')
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
                // ── Department Tab ──
                _selectedDept == null
                    ? _buildDepartmentList()
                    : _buildStudentTable(),

                // ── View Appointment Tab ──
                _buildViewAppointment(),
              ],
            ),
    );
  }

  // ── Department List ────────────────────────────────────────
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
        return GestureDetector(
          onTap: () =>
              setState(() => _selectedDept = dept['name']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(12)),
                  child: Icon(
                      _deptIcon(dept['name']),
                      color: color,
                      size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(dept['name'],
                          style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                      Text(
                          'Total Students: ${dept['students']}',
                          style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Student Table ──────────────────────────────────────────
  Widget _buildStudentTable() {
    final dept = _departments.firstWhere(
        (d) => d['name'] == _selectedDept,
        orElse: () => {});
    final students =
        (dept['data'] as List<Map<String, dynamic>>?) ??
            [];

    return Column(
      children: [
        // Department dropdown
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primaryLight)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDept,
                isExpanded: true,
                icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary),
                style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
                items: _departments
                    .map((d) => DropdownMenuItem<String>(
                        value: d['name'],
                        child: Text(d['name'],
                            overflow:
                                TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedDept = val),
              ),
            ),
          ),
        ),

        // Table
        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(10)),
                  child: const Row(
                    children: [
                      SizedBox(
                          width: 40,
                          child: Text('S.No',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight:
                                      FontWeight.w700,
                                  fontSize: 12))),
                      Expanded(
                          child: Text('Name',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight:
                                      FontWeight.w700,
                                  fontSize: 12))),
                      Expanded(
                          child: Text('Year',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight:
                                      FontWeight.w700,
                                  fontSize: 12))),
                      Expanded(
                          child: Text('Mobile',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight:
                                      FontWeight.w700,
                                  fontSize: 12))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Student rows
                ...List.generate(students.length, (i) {
                  final s = students[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 40,
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 13))),
                        Expanded(
                            child: Text(
                                s['name'] ?? 'Unknown',
                                style: const TextStyle(
                                    color: AppColors
                                        .primaryDark,
                                    fontWeight:
                                        FontWeight.w600,
                                    fontSize: 13),
                                overflow:
                                    TextOverflow.ellipsis)),
                        Expanded(
                            child: Text(s['year'] ?? '-',
                                style: const TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 12))),
                        Expanded(
                            child: Text(
                                s['mobile'] ?? '-',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    color: AppColors
                                        .primaryDark,
                                    fontSize: 11),
                                overflow:
                                    TextOverflow.ellipsis)),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Summary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        Text('${students.length}',
                            style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 18)),
                        const Text('Students',
                            style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 11)),
                      ]),
                      Column(children: [
                        Text(_selectedDept ?? '',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                        const Text('Department',
                            style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 11)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── View Appointment ───────────────────────────────────────
  Widget _buildViewAppointment() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department dropdown
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primaryLight)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCounsellorDept,
                isExpanded: true,
                items: ['All', ..._departments.map((d) =>
                    d['name'].toString())]
                    .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d,
                            overflow:
                                TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (val) => setState(
                    () => _selectedCounsellorDept =
                        val ?? 'All'),
                style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 14),
                icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Counsellors',
              style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 12),

          // Counsellors list
          ...['Dr. Michel', 'Dr. Seethru', 'Dr. Mithra']
              .map((name) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ]),
                    child: Row(
                      children: [
                        Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle),
                            child: const Icon(
                                Icons.person_rounded,
                                color: AppColors.primary)),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Text(name,
                                style: const TextStyle(
                                    color:
                                        AppColors.primaryDark,
                                    fontWeight:
                                        FontWeight.w600,
                                    fontSize: 15))),
                        const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.grey),
                      ],
                    ),
                  )),
        ],
      ),
    );
  }
}