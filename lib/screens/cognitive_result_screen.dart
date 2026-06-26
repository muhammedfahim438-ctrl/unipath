import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

// ─────────────────────────────────────────
//  Cognitive Result Screen
//  Save to: lib/screens/cognitive_result_screen.dart
// ─────────────────────────────────────────

class CognitiveResultScreen extends StatelessWidget {
  final int totalScore;
  final int maxScore;
  final Map<String, int> domainScores;
  final Map<String, int> domainMax;
  final String studentName;

  const CognitiveResultScreen({
    super.key,
    required this.totalScore,
    required this.maxScore,
    required this.domainScores,
    required this.domainMax,
    required this.studentName,
  });

  // ── Brand colors ─────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF5B21B6);
  static const Color _dark = Color(0xFF3B0764);
  static const Color _light = Color(0xFFEDE9FE);
  static const Color _surface = Color(0xFFF8F7FF);

  // ── Level config ──────────────────────────────────────────────────────────
  _LevelConfig get _levelConfig {
    if (totalScore >= 65) {
      return _LevelConfig(
        label: 'Advanced Cognitive Level',
        emoji: '🧠',
        color: const Color(0xFF059669),
        lightColor: const Color(0xFFD1FAE5),
        description:
            'Excellent analytical thinking, strong decision-making and high learning capacity.',
        advice:
            'Your cognitive profile is exceptional! Consider leadership roles, advanced skill development and research-oriented activities.',
        strengths: ['Analytical Thinking', 'Decision Making', 'Logical Reasoning & Problem Solving'],
        barColor: const Color(0xFF059669),
      );
    } else if (totalScore >= 50) {
      return _LevelConfig(
        label: 'Strong Cognitive Level',
        emoji: '🌱',
        color: const Color(0xFF2563EB),
        lightColor: const Color(0xFFDBEAFE),
        description:
            'Good problem solving, balanced emotional control and solid learning ability.',
        advice:
            'You have good cognitive abilities! Focus on career planning, skill enhancement and personal development to reach the advanced level.',
        strengths: ['Memory & Learning', 'Emotional Intelligence', 'Creativity & Adaptability'],
        barColor: const Color(0xFF2563EB),
      );
    } else if (totalScore >= 35) {
      return _LevelConfig(
        label: 'Developing Cognitive Level',
        emoji: '📈',
        color: const Color(0xFFD97706),
        lightColor: const Color(0xFFFEF3C7),
        description:
            'Average reasoning ability with room for improvement in focus and confidence.',
        advice:
            'Try memory exercises, concentration activities and time management training to strengthen your cognitive skills.',
        strengths: ['Self-Awareness & Growth Mindset', 'Creativity & Adaptability'],
        barColor: const Color(0xFFD97706),
      );
    } else {
      return _LevelConfig(
        label: 'Support Required',
        emoji: '🤝',
        color: const Color(0xFFDC2626),
        lightColor: const Color(0xFFFEE2E2),
        description:
            'Difficulty handling stress with lower decision confidence at this time.',
        advice:
            'We recommend booking a counselling session. Stress management activities and a personalized learning plan can help you grow.',
        strengths: ['Self-Awareness & Growth Mindset'],
        barColor: const Color(0xFFDC2626),
      );
    }
  }

  // ── Domain display config ─────────────────────────────────────────────────
  static const Map<String, _DomainMeta> _domainMeta = {
    'Attention & Concentration': _DomainMeta(
        icon: Icons.center_focus_strong_rounded, color: Color(0xFF7C3AED)),
    'Memory & Learning': _DomainMeta(
        icon: Icons.psychology_rounded, color: Color(0xFF2563EB)),
    'Logical Reasoning & Problem Solving': _DomainMeta(
        icon: Icons.account_tree_rounded, color: Color(0xFF059669)),
    'Analytical Thinking': _DomainMeta(
        icon: Icons.analytics_rounded, color: Color(0xFFD97706)),
    'Decision Making': _DomainMeta(
        icon: Icons.balance_rounded, color: Color(0xFFDC2626)),
    'Emotional Intelligence': _DomainMeta(
        icon: Icons.favorite_rounded, color: Color(0xFFDB2777)),
    'Creativity & Adaptability': _DomainMeta(
        icon: Icons.lightbulb_rounded, color: Color(0xFF0891B2)),
    'Self-Awareness & Growth Mindset': _DomainMeta(
        icon: Icons.self_improvement_rounded, color: Color(0xFF65A30D)),
  };

  @override
  Widget build(BuildContext context) {
    final level = _levelConfig;
    final percent = (totalScore / maxScore * 100).round();

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            _buildHeader(context),

            // ── Scrollable content ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ── Trophy + Score ───────────────────────────────────
                    _buildScoreHero(level, percent),

                    const SizedBox(height: 24),

                    // ── Score range bar ──────────────────────────────────
                    _buildScoreRangeBar(),

                    const SizedBox(height: 20),

                    // ── Advice card ──────────────────────────────────────
                    _buildAdviceCard(level),

                    const SizedBox(height: 20),

                    // ── Domain breakdown ─────────────────────────────────
                    _buildDomainBreakdown(level),

                    const SizedBox(height: 28),

                    // ── Back to dashboard button ──────────────────────────
                    _buildDashboardButton(context),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      const DashboardScreen(quizJustCompleted: true)),
              (route) => false,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _light,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.home_rounded, color: _dark, size: 20),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Your Results',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 36), // balance the back button
        ],
      ),
    );
  }

  // ── Score hero ────────────────────────────────────────────────────────────
  Widget _buildScoreHero(_LevelConfig level, int percent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: level.color.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          // Confetti emoji row
          const Text('🎉  ✨  🎊', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 16),

          // Trophy icon
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: level.lightColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(level.emoji, style: const TextStyle(fontSize: 44)),
            ),
          ),

          const SizedBox(height: 16),

          // Level label
          Text(
            level.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: level.color,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Hello, $studentName!',
            style: TextStyle(
              fontSize: 14,
              color: _dark.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // Score circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: level.color, width: 6),
              color: level.lightColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$totalScore',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: level.color,
                    height: 1,
                  ),
                ),
                Text(
                  '/ $maxScore',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: level.color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            '$percent% Score',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _dark.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Score range bar ───────────────────────────────────────────────────────
  Widget _buildScoreRangeBar() {
    final ranges = [
      _RangeItem('Below 35', 'Support\nRequired', const Color(0xFFDC2626),
          const Color(0xFFFEE2E2), totalScore < 35),
      _RangeItem('35 – 49', 'Developing\nLevel', const Color(0xFFD97706),
          const Color(0xFFFEF3C7), totalScore >= 35 && totalScore < 50),
      _RangeItem('50 – 64', 'Strong\nLevel', const Color(0xFF2563EB),
          const Color(0xFFDBEAFE), totalScore >= 50 && totalScore < 65),
      _RangeItem('65 – 80', 'Advanced\nLevel', const Color(0xFF059669),
          const Color(0xFFD1FAE5), totalScore >= 65),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: ranges.map((r) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color: r.isActive ? r.lightColor : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: r.isActive ? r.color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  if (r.isActive)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: r.color, shape: BoxShape.circle),
                    ),
                  if (r.isActive) const SizedBox(height: 4),
                  Text(
                    r.scoreRange,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: r.isActive ? r.color : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          r.isActive ? FontWeight.w700 : FontWeight.w400,
                      color: r.isActive ? r.color : const Color(0xFF9CA3AF),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Advice card ───────────────────────────────────────────────────────────
  Widget _buildAdviceCard(_LevelConfig level) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: level.lightColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: level.color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: level.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.tips_and_updates_rounded,
                    color: level.color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Your Cognitive Profile',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: level.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            level.description,
            style: TextStyle(
              fontSize: 13,
              color: _dark.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level.advice,
              style: TextStyle(
                fontSize: 13,
                color: _dark.withValues(alpha: 0.8),
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Domain breakdown ──────────────────────────────────────────────────────
  Widget _buildDomainBreakdown(_LevelConfig level) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Domain Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Performance across all 8 cognitive areas',
            style: TextStyle(
              fontSize: 12,
              color: _dark.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 18),
          ...domainScores.entries.map((entry) {
            final domain = entry.key;
            final score = entry.value;
            final max = domainMax[domain] ?? 1;
            final meta = _domainMeta[domain] ??
                const _DomainMeta(
                    icon: Icons.circle, color: Color(0xFF5B21B6));
            final pct = score / max;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: meta.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            Icon(meta.icon, color: meta.color, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          domain,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _dark,
                          ),
                        ),
                      ),
                      Text(
                        '$score / $max',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: meta.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(meta.color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Dashboard button ──────────────────────────────────────────────────────
  Widget _buildDashboardButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  const DashboardScreen(quizJustCompleted: true)),
          (route) => false,
        ),
        icon: const Icon(Icons.home_rounded, size: 20),
        label: const Text('Back to Dashboard'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}

// ── Helper classes ────────────────────────────────────────────────────────────

class _LevelConfig {
  final String label;
  final String emoji;
  final Color color;
  final Color lightColor;
  final Color barColor;
  final String description;
  final String advice;
  final List<String> strengths;

  const _LevelConfig({
    required this.label,
    required this.emoji,
    required this.color,
    required this.lightColor,
    required this.barColor,
    required this.description,
    required this.advice,
    required this.strengths,
  });
}

class _DomainMeta {
  final IconData icon;
  final Color color;
  const _DomainMeta({required this.icon, required this.color});
}

class _RangeItem {
  final String scoreRange;
  final String label;
  final Color color;
  final Color lightColor;
  final bool isActive;

  const _RangeItem(
      this.scoreRange, this.label, this.color, this.lightColor, this.isActive);
}