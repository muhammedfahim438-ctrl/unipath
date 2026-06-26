import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() =>
      _AdminStudentsScreenState();
}

class _AdminStudentsScreenState
    extends State<AdminStudentsScreen> {
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String _selectedDept = 'All';
  List<String> _departments = ['All'];

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('students')
          .get();

      final students = snap.docs
          .map((d) => {...d.data(), 'id': d.id})
          .toList();

      final depts = students
          .map((s) => s['department']?.toString() ?? '')
          .where((d) => d.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      setState(() {
        _allStudents = students;
        _filteredStudents = students;
        _departments = ['All', ...depts];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((s) {
        final name =
            (s['name'] ?? '').toString().toLowerCase();
        final dept = (s['department'] ?? '').toString();
        final matchesSearch = query.isEmpty ||
            name.contains(query) ||
            dept.toLowerCase().contains(query);
        final matchesDept =
            _selectedDept == 'All' || dept == _selectedDept;
        return matchesSearch && matchesDept;
      }).toList();
    });
  }

  void _onDeptChanged(String? dept) {
    setState(() => _selectedDept = dept ?? 'All');
    _filterStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Students',
            style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.white),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    hintStyle:
                        const TextStyle(color: AppColors.grey),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.greyLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _departments.length,
                    itemBuilder: (context, i) {
                      final dept = _departments[i];
                      final selected = dept == _selectedDept;
                      return GestureDetector(
                        onTap: () => _onDeptChanged(dept),
                        child: Container(
                          margin:
                              const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.greyLight,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            dept,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.white
                                  : AppColors.grey,
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredStudents.length} students',
                  style: const TextStyle(
                      color: AppColors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : _filteredStudents.isEmpty
                    ? const Center(
                        child: Text('No students found',
                            style: TextStyle(
                                color: AppColors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, i) {
                          final s = _filteredStudents[i];
                          return _buildStudentCard(s);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> s) {
    final name = s['name'] ?? 'Unknown';
    final dept = s['department'] ?? '';
    final year = s['year'] ?? '';
    final mobile = s['mobile'] ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AdminStudentDetailScreen(student: s),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty
                      ? name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                      '$dept ${year.isNotEmpty ? "• $year" : ""}',
                      style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(mobile,
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
  }
}

// ─── Student Detail Screen ─────────────────────────────────────
class AdminStudentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const AdminStudentDetailScreen(
      {super.key, required this.student});

  @override
  State<AdminStudentDetailScreen> createState() =>
      _AdminStudentDetailScreenState();
}

class _AdminStudentDetailScreenState
    extends State<AdminStudentDetailScreen> {
  Map<String, dynamic>? _quizResult;
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final mobile = widget.student['mobile'] ?? '';
    final email = widget.student['email'] ?? '';

    try {
      // Try doc by email ID directly
      if (email.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('learning_style_results')
            .doc(email)
            .get();
        if (doc.exists) {
          _quizResult = doc.data() as Map<String, dynamic>;
        }
      }

      // Try doc by mobile ID directly
      if (_quizResult == null && mobile.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('learning_style_results')
            .doc(mobile)
            .get();
        if (doc.exists) {
          _quizResult = doc.data() as Map<String, dynamic>;
        }
      }

      // Load appointments by mobile
      QuerySnapshot apptSnap = await FirebaseFirestore
          .instance
          .collection('appointments')
          .where('mobile', isEqualTo: mobile)
          .get();

      if (apptSnap.docs.isEmpty && email.isNotEmpty) {
        apptSnap = await FirebaseFirestore.instance
            .collection('appointments')
            .where('email', isEqualTo: email)
            .get();
      }

      setState(() {
        _appointments = apptSnap.docs
            .map((d) => d.data() as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final name = s['name'] ?? 'Unknown';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(name,
            style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Personal Information',
                    Icons.person_rounded,
                    AppColors.primary,
                    [
                      _buildInfoRow('Name', s['name']),
                      _buildInfoRow('Mobile', s['mobile']),
                      _buildInfoRow('Email', s['email']),
                      _buildInfoRow('Gender', s['gender']),
                      _buildInfoRow(
                          'Date of Birth', s['dob']),
                      _buildInfoRow(
                          'Department', s['department']),
                      _buildInfoRow('Year', s['year']),
                      _buildInfoRow(
                          '12th Major', s['major12th']),
                      _buildInfoRow('Year of Passing',
                          s['yearOfPassing']),
                      _buildInfoRow('Parent Contact',
                          s['parentContact']),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Learning Style Quiz',
                    Icons.quiz_rounded,
                    AppColors.blue,
                    _quizResult == null
                        ? [
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('No quiz taken yet',
                                  style: TextStyle(
                                      color: AppColors.grey)),
                            )
                          ]
                        : [
                            _buildInfoRow('Dominant Style',
                                _quizResult!['dominant_style']),
                            _buildInfoRow('Score',
                                _quizResult!['score_percent']
                                    ?.toString()),
                            _buildInfoRow('Visual Score',
                                _quizResult!['visual_score']
                                    ?.toString()),
                            _buildInfoRow('Auditory Score',
                                _quizResult!['auditory_score']
                                    ?.toString()),
                            _buildInfoRow('Kinesthetic Score',
                                _quizResult![
                                        'kinesthetic_score']
                                    ?.toString()),
                          ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Counselling History (${_appointments.length})',
                    Icons.calendar_month_rounded,
                    AppColors.green,
                    _appointments.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                  'No appointments yet',
                                  style: TextStyle(
                                      color: AppColors.grey)),
                            )
                          ]
                        : _appointments
                            .map((a) => Container(
                                  margin: const EdgeInsets
                                      .only(bottom: 8),
                                  padding:
                                      const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.greyLight,
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      _buildInfoRow(
                                          'Date', a['date']),
                                      _buildInfoRow(
                                          'Time', a['time']),
                                      _buildInfoRow('Status',
                                          a['status']),
                                      _buildInfoRow('Reason',
                                          a['reason']),
                                    ],
                                  ),
                                ))
                            .toList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, IconData icon,
      Color color, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}