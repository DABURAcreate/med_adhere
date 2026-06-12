import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/constants.dart';
import '../../patient/data/adherence_repository.dart';
import '../data/patient_mgmt_repository.dart';

// ── Colour palette (mirrors patient_list_screen) ──────────────────────────────
const kP1 = Color(0xFF6AA9CB);
const kP2 = Color(0xFF114C90);
const kP3 = Color(0xFF165B9E);
const kP4 = Color(0xFF1A7E95);
const kP5 = Color(0xFF238F9C);
const kBg = Color(0xFFF0F5FB);
const kCard = Color(0xFFFFFFFF);

// ── Screen ────────────────────────────────────────────────────────────────────
class PatientDetailScreen extends StatefulWidget {
  final String patientId; // registration code from the route

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  bool _loading = true;
  String? _error;

  Patient? _patient;
  List<Medication> _medications = [];
  List<Reminder> _reminders = [];
  List<AdherenceLog> _last14DayLogs = [];

  bool _riskExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repo = context.read<PatientMgmtRepository>();
      final adherenceRepo = context.read<AdherenceRepository>();

      final patient =
          await repo.getPatientByRegistrationCode(widget.patientId);

      if (patient == null) {
        setState(() {
          _error = AppLocalizations.of(context)!.patientNotFoundError;
          _loading = false;
        });
        return;
      }

      final meds = await repo.getMedicationsForPatient(patient.id);
      final reminders = await repo.getRemindersForPatient(patient.id);

      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 13));
      final logs = await adherenceRepo.getLogsInRange(
        patientId: patient.id,
        from: DateTime(from.year, from.month, from.day),
        to: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );

      debugPrint('[PatientDetail] Loaded patient ${patient.fullName} (id=${patient.id}) from repository.');

      if (mounted) {
        setState(() {
          _patient = patient;
          _medications = meds;
          _reminders = reminders;
          _last14DayLogs = logs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context)!.couldNotLoadPatient(e.toString());
          _loading = false;
        });
      }
    }
  }

  // ── Risk helpers ─────────────────────────────────────────────────────────────
  Color _riskColor(String riskLevel) => switch (riskLevel) {
        kRiskHigh => const Color(0xFFB91C1C),
        kRiskMedium => const Color(0xFFD97706),
        _ => const Color(0xFF16A34A),
      };

  String _riskLabel(String riskLevel) {
    final l10n = AppLocalizations.of(context)!;
    return switch (riskLevel) {
      kRiskHigh => l10n.highRisk,
      kRiskMedium => l10n.medRisk,
      _ => l10n.lowRisk,
    };
  }

  Color _adherenceColor(double v) => v >= 80
      ? const Color(0xFF16A34A)
      : v >= 60
          ? const Color(0xFFD97706)
          : const Color(0xFFB91C1C);

  // ── Calendar helpers ─────────────────────────────────────────────────────────

  /// For each of the last 14 days, returns true=taken, false=missed, null=no data.
  List<({DateTime date, bool? taken})> _get14DayStrip() {
    final today = DateTime.now();
    final result = <({DateTime date, bool? taken})>[];

    for (int i = 13; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayLogs = _last14DayLogs.where((l) =>
          l.scheduledAt.isAfter(dayStart) &&
          l.scheduledAt.isBefore(dayEnd)).toList();

      if (dayLogs.isEmpty) {
        result.add((date: dayStart, taken: null));
      } else {
        final hasTaken = dayLogs
            .any((l) => l.status == kStatusTaken || l.status == kStatusLate);
        result.add((date: dayStart, taken: hasTaken));
      }
    }
    return result;
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: kBg,
        appBar: _buildSimpleAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _patient == null) {
      return Scaffold(
        backgroundColor: kBg,
        appBar: _buildSimpleAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error ?? AppLocalizations.of(context)!.patientNotFoundError,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
        ),
      );
    }

    final p = _patient!;
    final rc = _riskColor(p.riskLevel);

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(p),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientHeader(p, rc),
            const SizedBox(height: 12),
            _buildAdherenceSummary(p),
            const SizedBox(height: 12),
            _buildMedicationsSection(),
            const SizedBox(height: 12),
            _buildRiskExplanation(p, rc),
            const SizedBox(height: 12),
            _buildActions(context),
            const SizedBox(height: 12),
            _buildFollowUpLog(),
          ],
        ),
      ),
    );
  }

  // ── Simple app bar (loading/error states) ────────────────────────────────────
  PreferredSizeWidget _buildSimpleAppBar() => AppBar(
    backgroundColor: kP2,
    foregroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      onPressed: () => context.pop(),
    ),
    title: Text(
      widget.patientId,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
    ),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [kP2, kP3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
    ),
  );

  // ── App bar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(Patient p) {
    return AppBar(
      backgroundColor: kP2,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.fullName,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          Text(
            p.registrationCode,
            style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _riskColor(p.riskLevel).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _riskColor(p.riskLevel).withValues(alpha: 0.5)),
          ),
          child: Text(
            _riskLabel(p.riskLevel),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _riskColor(p.riskLevel)),
          ),
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [kP2, kP3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: Container(
          height: 4,
          decoration:
              const BoxDecoration(gradient: LinearGradient(colors: [kP4, kP5])),
        ),
      ),
    );
  }

  // ── Patient header card ──────────────────────────────────────────────────────
  Widget _buildPatientHeader(Patient p, Color rc) {
    final names = p.fullName.split(' ');
    final initials = names.take(2).map((n) => n.isNotEmpty ? n[0] : '').join();
    final conditions = (p.conditions ?? '').split(',').where((c) => c.trim().isNotEmpty).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kP1.withValues(alpha: 0.4), kP3.withValues(alpha: 0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800, color: kP2),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.fullName,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.badge_rounded,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          p.registrationCode,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    if ((p.clinicName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.local_hospital_rounded,
                              size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            p.clinicName!,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kP4.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kP4.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 10, color: kP4),
                    const SizedBox(width: 3),
                    Text(
                      AppLocalizations.of(context)!.workerBadge,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: kP4,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (conditions.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 0.8),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.summaryConditions,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.3),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: conditions.map((c) => _conditionChip(c.trim())).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _conditionChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: kP3.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kP3.withValues(alpha: 0.25)),
    ),
    child: Text(label,
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: kP2)),
  );

  // ── Adherence summary ─────────────────────────────────────────────────────────
  Widget _buildAdherenceSummary(Patient p) {
    final adherence = p.adherencePercentage30Days ?? 0.0;
    final missed = p.missedDoses30Days ?? 0;
    final ac = _adherenceColor(adherence);
    final strip = _get14DayStrip();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(AppLocalizations.of(context)!.adherenceSummary, Icons.insights_rounded),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${adherence.toStringAsFixed(0)}%',
                      style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: ac,
                          height: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(AppLocalizations.of(context)!.thirtyDayAdherenceRate,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (adherence / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(ac),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFB91C1C).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFB91C1C).withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      '$missed',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB91C1C),
                          height: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.missedDosesLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context)!.last14Days,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
                letterSpacing: 0.3),
          ),
          const SizedBox(height: 10),
          _buildCalendarStrip(strip),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(const Color(0xFF16A34A), AppLocalizations.of(context)!.taken),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFB91C1C), AppLocalizations.of(context)!.missed),
              const SizedBox(width: 16),
              _legendDot(Colors.grey.shade300, AppLocalizations.of(context)!.noData),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip(List<({DateTime date, bool? taken})> days) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) {
        Color color;
        if (d.taken == null) {
          color = Colors.grey.shade300;
        } else if (d.taken!) {
          color = const Color(0xFF16A34A);
        } else {
          color = const Color(0xFFB91C1C);
        }
        final label = dayLabels[d.date.weekday - 1];
        final isToday = d.date.day == DateTime.now().day &&
            d.date.month == DateTime.now().month;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Column(
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400)),
                const SizedBox(height: 4),
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    border: isToday
                        ? Border.all(color: kP3, width: 2)
                        : null,
                  ),
                  child: isToday
                      ? Center(
                          child: Text(
                            '${d.date.day}',
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(3)),
      ),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
    ],
  );

  // ── Medications section ───────────────────────────────────────────────────────
  Widget _buildMedicationsSection() {
    if (_medications.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(AppLocalizations.of(context)!.medications, Icons.medication_rounded),
            const SizedBox(height: 14),
            Center(
              child: Text(
                AppLocalizations.of(context)!.noMedicationsScheduled,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade400),
              ),
            ),
          ],
        ),
      );
    }

    // Build reminder lookup by medicationId
    final remindersByMed = <int, List<String>>{};
    for (final r in _reminders) {
      remindersByMed.putIfAbsent(r.medicationId, () => []).add(r.scheduledTime);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(AppLocalizations.of(context)!.medications, Icons.medication_rounded),
          const SizedBox(height: 14),
          ..._medications.where((m) => m.isActive).toList().asMap().entries.map((e) {
            final isLast = e.key == _medications.where((m) => m.isActive).length - 1;
            final med = e.value;
            final times = remindersByMed[med.id] ?? [];
            return Column(
              children: [
                _buildMedCard(med, times),
                if (!isLast) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, thickness: 0.8),
                  const SizedBox(height: 10),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMedCard(Medication med, List<String> times) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: kP4.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.medication_liquid_rounded, color: kP4, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                med.name,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 2),
              Text(med.dosage,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
              if (times.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: times
                      .map((t) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kP2.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 10, color: kP3),
                        const SizedBox(width: 3),
                        Text(t,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: kP3)),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Risk explanation ──────────────────────────────────────────────────────────
  Widget _buildRiskExplanation(Patient p, Color rc) {
    final adherenceRate = (p.adherencePercentage30Days ?? 0) / 100;
    final missed30 = p.missedDoses30Days ?? 0;
    final total = (p.takenDoses30Days ?? 0) + missed30;
    final score = p.riskScore ?? 0;

    final reasons = <String>[];
    if (adherenceRate < 0.5) {
      reasons.add(
          'Only ${adherenceRate * 100 ~/ 1}% of doses taken in the last 30 days');
    } else if (adherenceRate < 0.8) {
      reasons.add(
          '${adherenceRate * 100 ~/ 1}% of doses taken — aim for above 80%');
    }
    if (missed30 > 0) reasons.add('$missed30 missed doses in the last 30 days');
    if (total == 0) reasons.add('No dose history recorded yet');
    if (reasons.isEmpty) {
      reasons.add('${adherenceRate * 100 ~/ 1}% of doses taken in the last 30 days');
    }

    final riskExplanation = reasons.map((r) => '• $r').join('\n');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rc.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rc.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(Icons.info_outline_rounded, color: rc, size: 20),
          ),
          title: Text(
            AppLocalizations.of(context)!.whyThisRiskLevel,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: kP2),
          ),
          subtitle: Text(
            '${_riskLabel(p.riskLevel)} — Score: $score/100',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: rc),
          ),
          trailing: Icon(
            _riskExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: kP3,
          ),
          initiallyExpanded: _riskExpanded,
          onExpansionChanged: (v) => setState(() => _riskExpanded = v),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: rc.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: rc.withValues(alpha: 0.15)),
              ),
              child: Text(
                riskExplanation,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions section ───────────────────────────────────────────────────────────
  Widget _buildActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.actionsTitle, Icons.touch_app_rounded),
        const SizedBox(height: 14),
        _actionButton(
          icon: Icons.calendar_month_rounded,
          label: l10n.scheduleFollowUp,
          color: kP3,
          onTap: () => context.push(
              '/worker/patients/${widget.patientId}/follow-up'),
        ),
        const SizedBox(height: 10),
        _actionButton(
          icon: Icons.sms_rounded,
          label: l10n.sendSmsReminder,
          color: kP4,
          onTap: () => _showSmsDialog(context),
        ),
        const SizedBox(height: 10),
        _actionButton(
          icon: Icons.edit_calendar_rounded,
          label: l10n.editMedicationSchedule,
          color: const Color(0xFF6D28D9),
          onTap: () => context.push(
              '/worker/patients/${widget.patientId}/schedule'),
        ),
        const SizedBox(height: 10),
        _actionButton(
          icon: Icons.people_rounded,
          label: l10n.manageCaregiver,
          color: kP4,
          onTap: () => context.push(AppRoutes.caregiverLink),
        ),
      ],
    ),
  );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.6), width: 1.5),
          padding:
              const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700),
          minimumSize: const Size(double.infinity, 48),
        ),
      );

  void _showSmsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = _patient?.fullName.split(' ').first ?? 'Patient';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.sendSmsReminder,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: kP2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sendSmsDialogContent(name),
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kP4.withValues(alpha: 0.2)),
              ),
              child: Text(
                '"Hi $name, this is a reminder to take your medication today. Please contact your clinic if you have any questions."',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                    height: 1.5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.smsSent(name)),
                backgroundColor: const Color(0xFF16A34A),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kP4,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.send,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Follow-up log ─────────────────────────────────────────────────────────────
  Widget _buildFollowUpLog() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.followUpLog, Icons.history_rounded),
        const SizedBox(height: 14),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              l10n.noFollowUpNotes,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    ),
  );
  }

  // ── Section title helper ──────────────────────────────────────────────────────
  Widget _sectionTitle(String label, IconData icon) => Row(
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: kP3.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: kP3),
      ),
      const SizedBox(width: 10),
      Text(label,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kP2)),
    ],
  );
}
