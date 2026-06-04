import 'package:flutter/material.dart';
import '../theme.dart';

const List<Map<String, dynamic>> _departments = [
  {'name': 'Computer Science', 'icon': Icons.computer_rounded, 'students': 120, 'color': AppColors.primary,
    'data': [{'name': 'John', 'status': 'Complete', 'mark': '80%'}, {'name': 'Rose', 'status': 'Complete', 'mark': '50%'}, {'name': 'David', 'status': 'Complete', 'mark': '40%'}]},
  {'name': 'IOT', 'icon': Icons.device_hub_rounded, 'students': 98, 'color': AppColors.blue,
    'data': [{'name': 'Alice', 'status': 'Complete', 'mark': '75%'}, {'name': 'Bob', 'status': 'Pending', 'mark': '-'}]},
  {'name': 'Biology', 'icon': Icons.biotech_rounded, 'students': 85, 'color': AppColors.green,
    'data': [{'name': 'Priya', 'status': 'Complete', 'mark': '90%'}, {'name': 'Rahul', 'status': 'Complete', 'mark': '65%'}]},
  {'name': 'Physics', 'icon': Icons.science_rounded, 'students': 75, 'color': AppColors.orange,
    'data': [{'name': 'Sam', 'status': 'Complete', 'mark': '55%'}]},
];

class AdminExaminationScreen extends StatefulWidget {
  const AdminExaminationScreen({super.key});

  @override
  State<AdminExaminationScreen> createState() => _AdminExaminationScreenState();
}

class _AdminExaminationScreenState extends State<AdminExaminationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedDeptIndex;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Examination',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: 'Department'), Tab(text: 'View Appointment')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _selectedDeptIndex == null
              ? ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _departments.length,
                  itemBuilder: (context, index) {
                    final dept = _departments[index];
                    final color = dept['color'] as Color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDeptIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46, height: 46,
                              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                              child: Icon(dept['icon'] as IconData, color: color, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dept['name'] as String,
                                      style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 15)),
                                  Text('Total Students: ${dept['students']}',
                                      style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : _buildStudentTable(),
          _buildViewAppointment(),
        ],
      ),
    );
  }

  Widget _buildStudentTable() {
    final dept = _departments[_selectedDeptIndex!];
    final students = dept['data'] as List<Map<String, dynamic>>;
    final completed = students.where((s) => s['status'] == 'Complete').length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primaryLight)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: dept['name'] as String,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 14),
                items: _departments.map((d) => DropdownMenuItem<String>(value: d['name'] as String, child: Text(d['name'] as String))).toList(),
                onChanged: (_) => setState(() => _selectedDeptIndex = null),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    children: [
                      SizedBox(width: 40, child: Text('S.No', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12))),
                      Expanded(child: Text('Name', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12))),
                      Expanded(child: Text('Status', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12))),
                      Expanded(child: Text('Mark', textAlign: TextAlign.right, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(students.length, (i) {
                  final s = students[i];
                  final isComplete = s['status'] == 'Complete';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        SizedBox(width: 40, child: Text('${i + 1}', style: const TextStyle(color: AppColors.grey, fontSize: 13))),
                        Expanded(child: Text(s['name'] as String, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 13))),
                        Expanded(child: Text(s['status'] as String,
                            style: TextStyle(color: isComplete ? AppColors.green : AppColors.orange, fontWeight: FontWeight.w600, fontSize: 12))),
                        Expanded(child: Text(s['mark'] as String, textAlign: TextAlign.right,
                            style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 13))),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [Text('${students.length} stds', style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 14)), const Text('Total', style: TextStyle(color: AppColors.grey, fontSize: 11))]),
                      Column(children: [Text('$completed complete', style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 14)), const Text('Complete', style: TextStyle(color: AppColors.grey, fontSize: 11))]),
                      Column(children: [Text(completed == students.length ? '100%' : '-', style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 14)), const Text('Avg', style: TextStyle(color: AppColors.grey, fontSize: 11))]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewAppointment() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primaryLight)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'CS',
                isExpanded: true,
                items: ['CS', 'IOT', 'Biology', 'Physics'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (_) {},
                style: const TextStyle(color: AppColors.primaryDark, fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Counsellors', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          ...['Michel', 'Seethru', 'Mithra'].map((name) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
            child: Row(
              children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: const Icon(Icons.person_rounded, color: AppColors.primary)),
                const SizedBox(width: 14),
                Expanded(child: Text(name, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 15))),
                const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
