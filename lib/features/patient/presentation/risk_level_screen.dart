import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../features/risk_assessment/domain/risk_engine.dart';
import '../../../features/risk_assessment/domain/risk_model.dart';
import '../../../providers/session_provider.dart';
import '../widgets/scaffold.dart';

class RiskLevelScreen extends StatelessWidget {
  const RiskLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final patientId = session.currentPatientId;

    return MainScaffold(
      title: 'Risk Level',
      currentIndex: 3,
      body: patientId == null
          ? const _NoSessionView()
          : _RiskView(patientId: patientId),
    );
  }
}

// ── No-session placeholder ────────────────────────────────────────────────────

class _NoSessionView extends StatelessWidget {
  const _NoSessionView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No active session.\nPlease log in first.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

// ── Real risk view ────────────────────────────────────────────────────────────

class _RiskView extends StatefulWidget {
  final int patientId;
  const _RiskView({required this.patientId});

  @override
  State<_RiskView> createState() => _RiskViewState();
}

class _RiskViewState extends State<_RiskView> {
  late Future<RiskResult> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<RiskEngine>().calculate(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RiskResult>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final result = snapshot.data!;
        return _RiskContent(result: result, onRefresh: _refresh);
      },
    );
  }

  void _refresh() {
    setState(() {
      _future = context.read<RiskEngine>().calculate(widget.patientId);
    });
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _RiskContent extends StatelessWidget {
  final RiskResult result;
  final VoidCallback onRefresh;

  const _RiskContent({required this.result, required this.onRefresh});

  static const _levelColors = {
    RiskLevel.low: Color(0xFF2ED39E),
    RiskLevel.medium: Color(0xFFFF9800),
    RiskLevel.high: Color(0xFFD32F2F),
  };

  static const _levelIcons = {
    RiskLevel.low: Icons.verified_rounded,
    RiskLevel.medium: Icons.warning_amber_rounded,
    RiskLevel.high: Icons.dangerous_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final color = _levelColors[result.level]!;

    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Risk Level',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Risk icon
            Icon(
              _levelIcons[result.level],
              size: 96,
              color: color,
            ),
            const SizedBox(height: 12),

            // Level label
            Text(
              result.level.label,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),

            // Numeric score
            Text(
              'Score: ${result.riskScore}/100',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Adherence stat row
            _StatRow(
              label: '30-day adherence',
              value: result.adherencePercent,
              color: color,
            ),
            _StatRow(
              label: 'Current streak',
              value: '${result.currentStreak} day(s)',
              color: color,
            ),
            _StatRow(
              label: 'Missed (last 7 days)',
              value: '${result.missedLast7Days}',
              color: result.missedLast7Days > 0 ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 24),

            // Why this rating card
            _InfoCard(
              title: 'Why this rating?',
              bullets: result.reasons,
              color: color,
            ),
            const SizedBox(height: 16),

            // What should I do card
            _InfoCard(
              title: 'What should I do?',
              bullets: [result.recommendation],
              color: color,
            ),
            const SizedBox(height: 24),

            // Refresh button
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Recalculate'),
            ),

            Text(
              'Last calculated: ${_formatTime(result.calculatedAt)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> bullets;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.bullets,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
                decoration: TextDecoration.underline,
                decorationColor: color,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $b',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
