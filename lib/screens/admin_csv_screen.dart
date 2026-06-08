import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/csv_service.dart';

class AdminCsvScreen extends StatefulWidget {
  const AdminCsvScreen({super.key});

  @override
  State<AdminCsvScreen> createState() =>
      _AdminCsvScreenState();
}

class _AdminCsvScreenState extends State<AdminCsvScreen> {
  bool _isLoading = true;
  bool _isGenerating = false;
  Map<String, dynamic> _stats = {
    'total': 0,
    'visual': 0,
    'auditory': 0,
    'kinesthetic': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await CsvService.getReportStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  Future<void> _generateCSV() async {
    setState(() => _isGenerating = true);
    try {
      await CsvService.generateAndShareCSV();
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
          icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Learning Style Report',
            style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ── Header card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                            Icons.assessment_rounded,
                            color: AppColors.white,
                            size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          'Learning Style Quiz Results',
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_stats['total']} students have completed the quiz',
                          style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Stats ──
                  const Text('Learning Style Distribution',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Visual',
                          value: '${_stats['visual']}',
                          icon: Icons.visibility_rounded,
                          color: AppColors.primary,
                          lightColor:
                              AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Auditory',
                          value: '${_stats['auditory']}',
                          icon: Icons.hearing_rounded,
                          color: AppColors.blue,
                          lightColor:
                              const Color(0xFFDBEAFE),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Kinesthetic',
                          value:
                              '${_stats['kinesthetic']}',
                          icon: Icons.touch_app_rounded,
                          color: AppColors.green,
                          lightColor:
                              const Color(0xFFDCFCE7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── CSV info ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primaryLight),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: const [
                        Text('CSV Report Contains:',
                            style: TextStyle(
                                color:
                                    AppColors.primaryDark,
                                fontWeight:
                                    FontWeight.w700,
                                fontSize: 14)),
                        SizedBox(height: 12),
                        _InfoRow(
                            icon: Icons.person_rounded,
                            text: 'Student Name'),
                        _InfoRow(
                            icon: Icons.school_rounded,
                            text: 'Department'),
                        _InfoRow(
                            icon: Icons
                                .calendar_today_rounded,
                            text: 'Year'),
                        _InfoRow(
                            icon:
                                Icons.visibility_rounded,
                            text: 'Visual Score'),
                        _InfoRow(
                            icon: Icons.hearing_rounded,
                            text: 'Auditory Score'),
                        _InfoRow(
                            icon:
                                Icons.touch_app_rounded,
                            text: 'Kinesthetic Score'),
                        _InfoRow(
                            icon: Icons.star_rounded,
                            text: 'Dominant Style'),
                        _InfoRow(
                            icon:
                                Icons.percent_rounded,
                            text: 'Score Percentage'),
                        _InfoRow(
                            icon:
                                Icons.date_range_rounded,
                            text: 'Date Completed'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Generate button ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _stats['total'] == 0
                          ? null
                          : _isGenerating
                              ? null
                              : _generateCSV,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2))
                          : const Icon(
                              Icons.download_rounded),
                      label: Text(
                        _isGenerating
                            ? 'Generating...'
                            : 'Generate & Share CSV',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    14)),
                      ),
                    ),
                  ),
                  if (_stats['total'] == 0) ...[
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'No quiz results yet. Students need to complete the quiz first.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color lightColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(title,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.grey)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(
      {required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon,
              size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(
                  color: AppColors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}