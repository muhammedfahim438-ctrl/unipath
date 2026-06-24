import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import 'book_counselling_screen.dart';
import 'dashboard_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int visualScore;
  final int auditoryScore;
  final int kinestheticScore;
  final String dominantStyle;
  final bool quizJustCompleted;

  const ResultScreen({
    super.key,
    required this.score,
    required this.visualScore,
    required this.auditoryScore,
    required this.kinestheticScore,
    required this.dominantStyle,
    this.quizJustCompleted = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;
  Map<String, dynamic>? _profile;

  String get _label {
    if (widget.score >= 80) return 'Excellent!';
    if (widget.score >= 60) return 'Great!';
    if (widget.score >= 40) return 'Good';
    return 'Keep Going!';
  }

  Color get _labelColor {
    if (widget.score >= 80) return AppColors.green;
    if (widget.score >= 60) return AppColors.primary;
    if (widget.score >= 40) return AppColors.orange;
    return AppColors.red;
  }

  String get _styleDescription {
    switch (widget.dominantStyle) {
      case 'Visual':
        return 'You learn best by seeing. You prefer diagrams, charts, and written instructions.';
      case 'Auditory':
        return 'You learn best by listening. You prefer verbal instructions and discussions.';
      case 'Kinesthetic':
        return 'You learn best by doing. You prefer hands-on activities and practical work.';
      default:
        return 'You are a multi-sensory learner!';
    }
  }

  String get _studyTips {
    switch (widget.dominantStyle) {
      case 'Visual':
        return '- Use color-coded notes and mind maps\n- Watch video tutorials\n- Draw diagrams and flowcharts\n- Use flashcards with images';
      case 'Auditory':
        return '- Record lectures and replay them\n- Read notes aloud\n- Join study groups for discussion\n- Use rhymes and mnemonics';
      case 'Kinesthetic':
        return '- Take frequent breaks while studying\n- Use real-life examples\n- Do practice problems and experiments\n- Write and rewrite key concepts';
      default:
        return '- Combine visual, auditory, and hands-on methods\n- Experiment with different study styles\n- Stay consistent with your schedule';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.score / 100,
    ).animate(CurvedAnimation(
        parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getCachedProfile();
    if (mounted) setState(() => _profile = profile);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _downloadPDF() async {
    final doc = pw.Document();
    final purple = PdfColor.fromHex('#5B21B6');
    final darkPurple = PdfColor.fromHex('#3B0764');
    final lightPurple = PdfColor.fromHex('#EDE9FE');
    final grey = PdfColor.fromHex('#6B7280');
    final white = PdfColors.white;

    final studentName = _profile?['name'] ?? 'Student';
    final studentDept = _profile?['department'] ?? '';
    final studentYear = _profile?['year'] ?? '';
    final studentMobile = _profile?['mobile'] ?? '';
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 40, vertical: 32),
                color: darkPurple,
                child: pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment:
                              pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('UniPath',
                                style: pw.TextStyle(
                                    color: white,
                                    fontSize: 28,
                                    fontWeight:
                                        pw.FontWeight.bold)),
                            pw.Text(
                                'Nehru Arts and Science College',
                                style: pw.TextStyle(
                                    color: PdfColor.fromHex(
                                        '#D8B4FE'),
                                    fontSize: 11)),
                          ],
                        ),
                        pw.Container(
                          padding:
                              const pw.EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: purple,
                            borderRadius:
                                pw.BorderRadius.circular(20),
                          ),
                          child: pw.Text('NASC',
                              style: pw.TextStyle(
                                  color: white,
                                  fontSize: 12,
                                  fontWeight:
                                      pw.FontWeight.bold,
                                  letterSpacing: 2)),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    pw.Divider(
                        color:
                            PdfColor.fromHex('#7C3AED'),
                        thickness: 1),
                    pw.SizedBox(height: 12),
                    pw.Text(
                        'Learning Style Assessment Report',
                        style: pw.TextStyle(
                            color: white,
                            fontSize: 18,
                            fontWeight:
                                pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('Generated on $dateStr',
                        style: pw.TextStyle(
                            color: PdfColor.fromHex(
                                '#D8B4FE'),
                            fontSize: 10)),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  color: PdfColors.white,
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 40, vertical: 28),
                  child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Container(
                        padding:
                            const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          color: lightPurple,
                          borderRadius:
                              pw.BorderRadius.circular(12),
                        ),
                        child: pw.Column(
                          crossAxisAlignment:
                              pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Student Information',
                                style: pw.TextStyle(
                                    color: darkPurple,
                                    fontSize: 13,
                                    fontWeight:
                                        pw.FontWeight.bold)),
                            pw.SizedBox(height: 10),
                            pw.Row(children: [
                              _pdfInfoItem('Name',
                                  studentName, darkPurple),
                              pw.SizedBox(width: 40),
                              _pdfInfoItem('Department',
                                  studentDept, darkPurple),
                              pw.SizedBox(width: 40),
                              _pdfInfoItem('Year',
                                  studentYear, darkPurple),
                            ]),
                            pw.SizedBox(height: 8),
                            _pdfInfoItem('Mobile',
                                studentMobile, darkPurple),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      pw.Row(children: [
                        pw.Expanded(
                          child: pw.Container(
                            padding:
                                const pw.EdgeInsets.all(20),
                            decoration: pw.BoxDecoration(
                              color: purple,
                              borderRadius:
                                  pw.BorderRadius.circular(
                                      12),
                            ),
                            child: pw.Column(children: [
                              pw.Text('${widget.score}%',
                                  style: pw.TextStyle(
                                      color: white,
                                      fontSize: 40,
                                      fontWeight:
                                          pw.FontWeight
                                              .bold)),
                              pw.Text(_label,
                                  style: pw.TextStyle(
                                      color:
                                          PdfColor.fromHex(
                                              '#D8B4FE'),
                                      fontSize: 14,
                                      fontWeight:
                                          pw.FontWeight
                                              .bold)),
                              pw.SizedBox(height: 4),
                              pw.Text('Overall Score',
                                  style: pw.TextStyle(
                                      color:
                                          PdfColor.fromHex(
                                              '#D8B4FE'),
                                      fontSize: 10)),
                            ]),
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: pw.Container(
                            padding:
                                const pw.EdgeInsets.all(20),
                            decoration: pw.BoxDecoration(
                              color: lightPurple,
                              borderRadius:
                                  pw.BorderRadius.circular(
                                      12),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw
                                  .CrossAxisAlignment.start,
                              children: [
                                pw.Text('Learning Style',
                                    style: pw.TextStyle(
                                        color: grey,
                                        fontSize: 10)),
                                pw.SizedBox(height: 6),
                                pw.Text(
                                    '${widget.dominantStyle} Learner',
                                    style: pw.TextStyle(
                                        color: darkPurple,
                                        fontSize: 18,
                                        fontWeight:
                                            pw.FontWeight
                                                .bold)),
                                pw.SizedBox(height: 8),
                                pw.Text(_styleDescription,
                                    style: pw.TextStyle(
                                        color: grey,
                                        fontSize: 10,
                                        lineSpacing: 3)),
                              ],
                            ),
                          ),
                        ),
                      ]),
                      pw.SizedBox(height: 20),
                      pw.Text('Score Breakdown',
                          style: pw.TextStyle(
                              color: darkPurple,
                              fontSize: 13,
                              fontWeight:
                                  pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      _pdfScoreBar('Visual',
                          widget.visualScore, purple),
                      pw.SizedBox(height: 8),
                      _pdfScoreBar(
                          'Auditory',
                          widget.auditoryScore,
                          PdfColor.fromHex('#2563EB')),
                      pw.SizedBox(height: 8),
                      _pdfScoreBar(
                          'Kinesthetic',
                          widget.kinestheticScore,
                          PdfColor.fromHex('#16A34A')),
                      pw.SizedBox(height: 20),
                      pw.Container(
                        padding:
                            const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: purple, width: 1.5),
                          borderRadius:
                              pw.BorderRadius.circular(12),
                        ),
                        child: pw.Column(
                          crossAxisAlignment:
                              pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                                'Study Tips for ${widget.dominantStyle} Learners',
                                style: pw.TextStyle(
                                    color: purple,
                                    fontSize: 13,
                                    fontWeight:
                                        pw.FontWeight.bold)),
                            pw.SizedBox(height: 8),
                            pw.Text(_studyTips,
                                style: pw.TextStyle(
                                    color: grey,
                                    fontSize: 11,
                                    lineSpacing: 4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 40, vertical: 16),
                color: lightPurple,
                child: pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                        'UniPath - NASC Counselling and Wellness Platform',
                        style: pw.TextStyle(
                            color: grey, fontSize: 9)),
                    pw.Text('unipath-nasc.web.app',
                        style: pw.TextStyle(
                            color: purple, fontSize: 9)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await doc.save();
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'UniPath_Result_$studentName.pdf',
    );
  }

  pw.Widget _pdfInfoItem(
      String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                color: PdfColor.fromHex('#6B7280'),
                fontSize: 9)),
        pw.SizedBox(height: 2),
        pw.Text(value,
            style: pw.TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _pdfScoreBar(
      String label, int score, PdfColor color) {
    return pw.Row(
      children: [
        pw.SizedBox(
            width: 80,
            child: pw.Text(label,
                style: pw.TextStyle(
                    color: PdfColor.fromHex('#3B0764'),
                    fontSize: 11))),
        pw.Expanded(
          child: pw.Stack(
            children: [
              pw.Container(
                  height: 10,
                  decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#EDE9FE'),
                      borderRadius:
                          pw.BorderRadius.circular(5))),
              pw.Container(
                  height: 10,
                  width: (score / 30) * 300,
                  decoration: pw.BoxDecoration(
                      color: color,
                      borderRadius:
                          pw.BorderRadius.circular(5))),
            ],
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text('$score/30',
            style: pw.TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primaryDark),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 12),
              const Text('Your Result',
                  style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 30),

              // ── Circular progress ──
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (context, child) {
                  return SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
  SizedBox(
    width: 180,
    height: 180,
    child: CircularProgressIndicator(
      value: 1.0,
      strokeWidth: 14,
      valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.primaryLight),  // ✅ fixed
    ),
  ),
  SizedBox(
    width: 180,
    height: 180,
    child: CircularProgressIndicator(
      value: _progressAnim.value,
      strokeWidth: 14,
      strokeCap: StrokeCap.round,
      valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.primary),  // ✅ fixed
    ),
  ),
  // ... rest of Stack

                        Text(
                          '${(widget.score * _progressAnim.value).round()}%',
                          style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 36,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              Text(_label,
                  style: TextStyle(
                      color: _labelColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.dominantStyle} Learner',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              // ── Score breakdown ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text('Score Breakdown',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildScoreBar('Visual',
                        widget.visualScore,
                        AppColors.primary),
                    const SizedBox(height: 8),
                    _buildScoreBar('Auditory',
                        widget.auditoryScore,
                        AppColors.blue),
                    const SizedBox(height: 8),
                    _buildScoreBar('Kinesthetic',
                        widget.kinestheticScore,
                        AppColors.green),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Style description ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_rounded,
                            color: AppColors.white,
                            size: 20),
                        SizedBox(width: 8),
                        Text('Counselling Suggestion',
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _styleDescription,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          height: 1.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'You are recommended to book a counselling session with our expert.',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Download PDF button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _downloadPDF,
                  icon: const Icon(
                      Icons.download_rounded,
                      color: AppColors.white),
                  label: const Text('Download Result PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF16A34A),
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Book Session button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const BookCounsellingScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Book Session'),
                ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DashboardScreen(
                            quizJustCompleted:
                                widget.quizJustCompleted)),
                    (route) => false,
                  );
                },
                child: const Text('Go to Dashboard',
                    style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 14)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBar(
      String label, int score, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 30,
              backgroundColor:
                  color.withValues(alpha: 0.15),
              valueColor:
                  AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$score/30',
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}