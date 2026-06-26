import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

// ─────────────────────────────────────────
//  Admin Cognitive Screen
//  Save to: lib/screens/admin_cognitive_screen.dart
// ─────────────────────────────────────────

class AdminCognitiveScreen extends StatefulWidget {
  const AdminCognitiveScreen({super.key});

  @override
  State<AdminCognitiveScreen> createState() => _AdminCognitiveScreenState();
}

class _AdminCognitiveScreenState extends State<AdminCognitiveScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF5B21B6);
  static const Color _dark = Color(0xFF3B0764);
  static const Color _light = Color(0xFFEDE9FE);
  static const Color _surface = Color(0xFFF8F7FF);

  late TabController _tabController;
  int _currentTab = 0;

  List<Map<String, dynamic>> _results = [];
  bool _loadingResults = true;
  String _searchQuery = '';
  String _filterDept = 'All';
  List<String> _departments = ['All'];

  List<Map<String, dynamic>> _questions = [];
  bool _loadingQuestions = true;

  final _questionController = TextEditingController();
  String _selectedDomain = 'Attention & Concentration';
  bool _addingQuestion = false;

  static const List<String> _domains = [
    'Attention & Concentration',
    'Memory & Learning',
    'Logical Reasoning & Problem Solving',
    'Analytical Thinking',
    'Decision Making',
    'Emotional Intelligence',
    'Creativity & Adaptability',
    'Self-Awareness & Growth Mindset',
  ];

  static const Map<String, Color> _domainColors = {
    'Attention & Concentration': Color(0xFF7C3AED),
    'Memory & Learning': Color(0xFF2563EB),
    'Logical Reasoning & Problem Solving': Color(0xFF059669),
    'Analytical Thinking': Color(0xFFD97706),
    'Decision Making': Color(0xFFDC2626),
    'Emotional Intelligence': Color(0xFFDB2777),
    'Creativity & Adaptability': Color(0xFF0891B2),
    'Self-Awareness & Growth Mindset': Color(0xFF65A30D),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() => _currentTab = _tabController.index);
    });
    _loadResults();
    _loadQuestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('cognitive_results')
          .orderBy('createdAt', descending: true)
          .get();

      // Fetch all students once, keyed by mobile for quick lookup
      // (students doc ID = '+91mobile', cognitive_results doc ID = '+91mobile')
      final studentsSnap = await FirebaseFirestore.instance
          .collection('students')
          .get();
      final studentsByMobile = <String, Map<String, dynamic>>{};
      for (final d in studentsSnap.docs) {
        // doc ID is '+91mobile'
        studentsByMobile[d.id] = {...d.data(), 'id': d.id};
        // also index by mobile field value as fallback
        final mob = (d.data()['mobile'] as String? ?? '').trim();
        if (mob.isNotEmpty) studentsByMobile[mob] = {...d.data(), 'id': d.id};
      }

      final results = snapshot.docs.map((d) {
        final data = <String, dynamic>{...d.data(), 'id': d.id};
        // cognitive_results doc ID = '+91mobile'
        final student = studentsByMobile[d.id];
        if (student != null) {
          data['name']       = student['name']       ?? data['name'];
          data['mobile']     = student['mobile']     ?? data['mobile'];
          data['department'] = student['department'] ?? data['department'];
          data['year']       = student['year']       ?? data['year'];
          data['email']      = student['email']      ?? data['email'];
        }
        return data;
      }).toList();

      final depts = <String>{'All'};
      for (final r in results) {
        final dept = r['department'] as String? ?? '';
        if (dept.isNotEmpty) depts.add(dept);
      }

      if (mounted) {
        setState(() {
          _results = results;
          _departments = depts.toList()..sort();
          _loadingResults = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingResults = false);
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('cognitive_questions')
          .orderBy('order')
          .get();

      if (mounted) {
        setState(() {
          _questions =
              snapshot.docs.map((d) => {...d.data(), 'id': d.id}).toList();
          _loadingQuestions = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingQuestions = false);
    }
  }

  Future<void> _addQuestion() async {
    final text = _questionController.text.trim();
    if (text.isEmpty) {
      _showSnack('Please enter a question.');
      return;
    }

    setState(() => _addingQuestion = true);
    try {
      final nextOrder = _questions.isEmpty
          ? 1
          : (_questions
                  .map((q) => q['order'] as int? ?? 0)
                  .reduce((a, b) => a > b ? a : b) +
              1);

      await FirebaseFirestore.instance.collection('cognitive_questions').add({
        'text': text,
        'domain': _selectedDomain,
        'order': nextOrder,
        'options': ['Strongly Disagree', 'Disagree', 'Agree', 'Strongly Agree'],
        'scores': [1, 2, 3, 4],
        'createdAt': FieldValue.serverTimestamp(),
      });

      _questionController.clear();
      await _loadQuestions();
      _showSnack('Question added successfully!');
    } catch (e) {
      _showSnack('Error adding question: $e');
    }
    if (mounted) setState(() => _addingQuestion = false);
  }

  Future<void> _deleteQuestion(String id, String text) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Question',
            style: TextStyle(
                color: Color(0xFF3B0764), fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete:\n\n"$text"',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    try {
      await FirebaseFirestore.instance
          .collection('cognitive_questions')
          .doc(id)
          .delete();
      await _loadQuestions();
      _showSnack('Question deleted.');
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  void _downloadCSV() {
    if (_results.isEmpty) {
      _showSnack('No results to export.');
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln(
        'Name,Mobile,Email,Department,Year,Total Score,Max Score,Percentage,Level,'
        'Attention & Concentration,Memory & Learning,Logical Reasoning & Problem Solving,'
        'Analytical Thinking,Decision Making,Emotional Intelligence,'
        'Creativity & Adaptability,Self-Awareness & Growth Mindset,Date');

    for (final r in _results) {
      final score = r['totalScore'] as int? ?? 0;
      final max = r['maxScore'] as int? ?? 80;
      final pct = (score / max * 100).round();
      final level = _getLevel(score);
      final ds = r['domainScores'] as Map<String, dynamic>? ?? {};

      String cell(String key) =>
          '"${(r[key] ?? '').toString().replaceAll('"', '""')}"';
      String domain(String d) => '"${ds[d] ?? 0}"';

      buffer.writeln(
        '${cell('name')},${cell('mobile')},${cell('email')},'
        '${cell('department')},${cell('year')},'
        '"$score","$max","$pct%","$level",'
        '${domain('Attention & Concentration')},'
        '${domain('Memory & Learning')},'
        '${domain('Logical Reasoning & Problem Solving')},'
        '${domain('Analytical Thinking')},'
        '${domain('Decision Making')},'
        '${domain('Emotional Intelligence')},'
        '${domain('Creativity & Adaptability')},'
        '${domain('Self-Awareness & Growth Mindset')},'
        '"${r['date'] ?? ''}"',
      );
    }

    final bytes = utf8.encode(buffer.toString());
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute(
          'download',
          'cognitive_results_\${DateTime.now().toIso8601String().substring(0, 10)}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
    anchor.remove();

    _showSnack('CSV downloaded!');
  }

  String _getLevel(int score) {
    if (score >= 65) return 'Advanced';
    if (score >= 50) return 'Strong';
    if (score >= 35) return 'Developing';
    return 'Support Required';
  }

  Color _getLevelColor(int score) {
    if (score >= 65) return const Color(0xFF059669);
    if (score >= 50) return const Color(0xFF2563EB);
    if (score >= 35) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredResults {
    return _results.where((r) {
      final name = (r['name'] as String? ?? '').toLowerCase();
      final mobile = (r['mobile'] as String? ?? '').toLowerCase();
      final dept = (r['department'] as String? ?? '');
      final matchSearch = _searchQuery.isEmpty ||
          name.contains(_searchQuery.toLowerCase()) ||
          mobile.contains(_searchQuery.toLowerCase());
      final matchDept = _filterDept == 'All' || dept == _filterDept;
      return matchSearch && matchDept;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cognitive Assessment',
          style: TextStyle(
              color: _dark, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_currentTab == 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: _primary),
              onPressed: () {
                setState(() => _loadingResults = true);
                _loadResults();
              },
              tooltip: 'Refresh',
            ),
          if (_currentTab == 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _downloadCSV,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('CSV'),
                style: TextButton.styleFrom(
                  foregroundColor: _primary,
                  textStyle:
                      const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primary,
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: _primary,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Student Results'),
            Tab(text: 'Manage Questions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResultsTab(),
          _buildQuestionsTab(),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    if (_loadingResults) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }

    final filtered = _filteredResults;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  _StatBox(
                      label: 'Total',
                      value: '${_results.length}',
                      color: _primary),
                  const SizedBox(width: 10),
                  _StatBox(
                    label: 'Advanced',
                    value:
                        '${_results.where((r) => (r['totalScore'] as int? ?? 0) >= 65).length}',
                    color: const Color(0xFF059669),
                  ),
                  const SizedBox(width: 10),
                  _StatBox(
                    label: 'Support',
                    value:
                        '${_results.where((r) => (r['totalScore'] as int? ?? 0) < 35).length}',
                    color: const Color(0xFFDC2626),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search by name or mobile...',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: Color(0xFF9CA3AF)),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: _surface,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _departments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final dept = _departments[i];
                    final selected = _filterDept == dept;
                    return GestureDetector(
                      onTap: () => setState(() => _filterDept = dept),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? _primary : _surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? _primary
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          dept,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF6B7280),
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
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.psychology_outlined,
                          size: 56,
                          color: _primary.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text(
                        _results.isEmpty
                            ? 'No results yet.\nStudents haven\'t taken the test.'
                            : 'No results match your search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _dark.withValues(alpha: 0.4),
                            fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _ResultCard(
                    result: filtered[i],
                    levelColor: _getLevelColor(
                        filtered[i]['totalScore'] as int? ?? 0),
                    level:
                        _getLevel(filtered[i]['totalScore'] as int? ?? 0),
                    domainColors: _domainColors,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildQuestionsTab() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Question',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _dark),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedDomain,
                decoration: InputDecoration(
                  labelText: 'Cognitive Domain',
                  labelStyle: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: _surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                items: _domains
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d,
                              style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedDomain = v ?? _domains[0]),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _questionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter question text...',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: _surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _light,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: _primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Options are auto-set: A=Strongly Disagree, B=Disagree, C=Agree, D=Strongly Agree',
                        style: TextStyle(fontSize: 11, color: _dark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addingQuestion ? null : _addQuestion,
                  icon: _addingQuestion
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.add_rounded, size: 20),
                  label: Text(
                      _addingQuestion ? 'Adding...' : 'Add Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _surface,
          child: Row(
            children: [
              Text(
                '${_questions.length} Questions Total',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _dark.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              ...(_domains.map((d) {
                final count =
                    _questions.where((q) => q['domain'] == d).length;
                if (count == 0) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (_domainColors[d] ?? _primary)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _domainColors[d] ?? _primary,
                    ),
                  ),
                );
              }).take(4).toList()),
            ],
          ),
        ),
        Expanded(
          child: _loadingQuestions
              ? const Center(
                  child: CircularProgressIndicator(color: _primary))
              : _questions.isEmpty
                  ? Center(
                      child: Text('No questions found.',
                          style: TextStyle(
                              color: _dark.withValues(alpha: 0.4))))
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: _questions.length,
                      itemBuilder: (_, i) {
                        final q = _questions[i];
                        final domain = q['domain'] as String? ?? '';
                        final color =
                            _domainColors[domain] ?? _primary;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: color.withValues(alpha: 0.2),
                                width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${q['order'] ?? i + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3),
                                      decoration: BoxDecoration(
                                        color: color.withValues(
                                            alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        domain,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      q['text'] as String? ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _dark,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFFDC2626),
                                    size: 20),
                                onPressed: () => _deleteQuestion(
                                    q['id'] as String,
                                    q['text'] as String? ?? ''),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// ── Result Card ───────────────────────────────────────────────────────────────
class _ResultCard extends StatefulWidget {
  final Map<String, dynamic> result;
  final Color levelColor;
  final String level;
  final Map<String, Color> domainColors;

  const _ResultCard({
    required this.result,
    required this.levelColor,
    required this.level,
    required this.domainColors,
  });

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final score = r['totalScore'] as int? ?? 0;
    final max = r['maxScore'] as int? ?? 80;
    final pct = (score / max * 100).round();
    final ds = r['domainScores'] as Map<String, dynamic>? ?? {};
    final dm = r['domainMax'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: widget.levelColor.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
              color: widget.levelColor.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.levelColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (() {
                          final n = (r['name'] as String? ?? '').trim();
                          return (n.isNotEmpty ? n[0] : 'S').toUpperCase();
                        })(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: widget.levelColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['name'] as String? ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${r['department'] ?? ''} • Year ${r['year'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.levelColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.level,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: widget.levelColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$score/$max',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: widget.levelColor,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.levelColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded,
                          size: 13, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(r['mobile'] as String? ?? '',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280))),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_rounded,
                          size: 13, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (r['date'] as String? ?? '').substring(
                              0,
                              (r['date'] as String? ?? '').length > 10
                                  ? 10
                                  : (r['date'] as String? ?? '')
                                      .length),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Domain Breakdown',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...ds.entries.map((e) {
                    final dScore = e.value as int? ?? 0;
                    final dMax = dm[e.key] as int? ?? 4;
                    final dPct = dScore / dMax;
                    final color = widget.domainColors[e.key] ??
                        const Color(0xFF5B21B6);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.key,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280)),
                                ),
                              ),
                              Text(
                                '$dScore/$dMax',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: dPct,
                              minHeight: 6,
                              backgroundColor:
                                  const Color(0xFFF3F4F6),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stat Box ──────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}