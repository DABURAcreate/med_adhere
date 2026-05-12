import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Colour palette (mirrors patient_list_screen) ──────────────────────────────
const kP1 = Color(0xFF6AA9CB);
const kP2 = Color(0xFF114C90);
const kP3 = Color(0xFF165B9E);
const kP4 = Color(0xFF1A7E95);
const kP5 = Color(0xFF238F9C);
const kBg = Color(0xFFF0F5FB);
const kCard = Color(0xFFFFFFFF);

// ── Fake data models ──────────────────────────────────────────────────────────
enum RiskLevel { high, medium, low }

class _AdherenceDay {
  final DateTime date;
  final bool? taken; // null = no data / future

  const _AdherenceDay({required this.date, required this.taken});
}

class _Medication {
  final String name;
  final String dosage;
  final List<String> times;
  final double adherence;

  const _Medication({
    required this.name,
    required this.dosage,
    required this.times,
    required this.adherence,
  });
}

class _FollowUpNote {
  final String date;
  final String note;
  final String worker;

  const _FollowUpNote({
    required this.date,
    required this.note,
    required this.worker,
  });
}

// ── Fake patient data keyed by ID ─────────────────────────────────────────────
class _PatientData {
  final String firstName;
  final String lastName;
  final String nationalId;
  final String clinicCode;
  final List<String> conditions;
  final RiskLevel risk;
  final double adherence30d;
  final int missedDoses30d;
  final List<_AdherenceDay> last14Days;
  final List<_Medication> medications;
  final String riskExplanation;
  final List<_FollowUpNote> followUpLog;

  const _PatientData({
    required this.firstName,
    required this.lastName,
    required this.nationalId,
    required this.clinicCode,
    required this.conditions,
    required this.risk,
    required this.adherence30d,
    required this.missedDoses30d,
    required this.last14Days,
    required this.medications,
    required this.riskExplanation,
    required this.followUpLog,
  });
}

_PatientData _fakePatientData(String patientId) {
  // Generate stable fake data based on id
  final today = DateTime.now();
  final days = List.generate(14, (i) {
    final d = today.subtract(Duration(days: 13 - i));
    final taken = i < 12 ? (i % 4 != 2) : null;
    return _AdherenceDay(date: d, taken: taken);
  });

  return _PatientData(
    firstName: 'Sipho',
    lastName: 'Dlamini',
    nationalId: '9203145800081',
    clinicCode: 'MBM-0041',
    conditions: ['HIV', 'Hypertension'],
    risk: RiskLevel.high,
    adherence30d: 38.0,
    missedDoses30d: 18,
    last14Days: days,
    medications: const [
      _Medication(
        name: 'Tenofovir / Lamivudine / Dolutegravir',
        dosage: '300/300/50 mg',
        times: ['08:00'],
        adherence: 40.0,
      ),
      _Medication(
        name: 'Amlodipine',
        dosage: '5 mg',
        times: ['08:00', '20:00'],
        adherence: 35.0,
      ),
    ],
    riskExplanation:
    'This patient is classified as HIGH RISK based on:\n\n'
        '• Adherence below 50% over the past 30 days\n'
        '• 18 missed doses in the last month\n'
        '• Last medication log recorded 2 days ago\n'
        '• Two concurrent chronic conditions requiring strict adherence\n\n'
        'Immediate follow-up is recommended to identify barriers and provide support.',
    followUpLog: const [
      _FollowUpNote(
        date: '12 May 2025',
        note: 'Patient reported forgetting morning doses. Discussed alarm reminder strategy.',
        worker: 'Nurse Mokoena',
      ),
      _FollowUpNote(
        date: '28 Apr 2025',
        note: 'Phone follow-up — patient confirmed pills but no phone log recorded.',
        worker: 'Nurse Mokoena',
      ),
      _FollowUpNote(
        date: '10 Apr 2025',
        note: 'Clinic visit. Medication collected. Adherence counselling provided.',
        worker: 'Dr Khumalo',
      ),
    ],
  );
}

// ── Screen ────────────────────────────────────────────────────────────────────
class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  bool _riskExpanded = false;
  late _PatientData _patient;

  @override
  void initState() {
    super.initState();
    _patient = _fakePatientData(widget.patientId);
  }

  // ── Risk helpers ─────────────────────────────────────────────────────────────
  Color _riskColor(RiskLevel r) => switch (r) {
    RiskLevel.high => const Color(0xFFB91C1C),
    RiskLevel.medium => const Color(0xFFD97706),
    RiskLevel.low => const Color(0xFF16A34A),
  };

  String _riskLabel(RiskLevel r) => switch (r) {
    RiskLevel.high => 'High Risk',
    RiskLevel.medium => 'Med Risk',
    RiskLevel.low => 'Low Risk',
  };

  Color _adherenceColor(double v) =>
      v >= 80 ? const Color(0xFF16A34A) : v >= 60 ? const Color(0xFFD97706) : const Color(0xFFB91C1C);

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final p = _patient;
    final rc = _riskColor(p.risk);

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(context, p),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientHeader(p, rc),
            const SizedBox(height: 12),
            _buildAdherenceSummary(p),
            const SizedBox(height: 12),
            _buildMedicationsSection(p),
            const SizedBox(height: 12),
            _buildRiskExplanation(p, rc),
            const SizedBox(height: 12),
            _buildActions(context, p),
            const SizedBox(height: 12),
            _buildFollowUpLog(p),
          ],
        ),
      ),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, _PatientData p) => AppBar(
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
          '${p.firstName} ${p.lastName}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          p.clinicCode,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
    actions: [
      Container(
        margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _riskColor(p.risk).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _riskColor(p.risk).withOpacity(0.5)),
        ),
        child: Text(
          _riskLabel(p.risk),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _riskColor(p.risk),
          ),
        ),
      ),
    ],
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kP2, kP3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(4),
      child: Container(
        height: 4,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [kP4, kP5]),
        ),
      ),
    ),
  );

  // ── Patient header card ──────────────────────────────────────────────────────
  Widget _buildPatientHeader(_PatientData p, Color rc) => Container(
    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
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
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kP1.withOpacity(0.4), kP3.withOpacity(0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${p.firstName[0]}${p.lastName[0]}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kP2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.firstName} ${p.lastName}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.badge_rounded,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        'ID: ${p.nationalId}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.local_hospital_rounded,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        p.clinicCode,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Worker-only badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: kP4.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kP4.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_rounded, size: 10, color: kP4),
                  const SizedBox(width: 3),
                  Text(
                    'WORKER',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: kP4,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, thickness: 0.8),
        const SizedBox(height: 12),
        // Conditions
        Text(
          'Conditions',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: p.conditions
              .map((c) => _conditionChip(c))
              .toList(),
        ),
      ],
    ),
  );

  Widget _conditionChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: kP3.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kP3.withOpacity(0.25)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: kP2,
      ),
    ),
  );

  // ── Adherence summary ─────────────────────────────────────────────────────────
  Widget _buildAdherenceSummary(_PatientData p) {
    final ac = _adherenceColor(p.adherence30d);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          _sectionTitle('Adherence Summary', Icons.insights_rounded),
          const SizedBox(height: 14),

          // Big number row
          Row(
            children: [
              // Adherence %
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${p.adherence30d.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: ac,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '30-day adherence rate',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: p.adherence30d / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(ac),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Missed doses
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFB91C1C).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFB91C1C).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${p.missedDoses30d}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB91C1C),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'missed\ndoses',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: 14),

          // 14-day calendar strip
          Text(
            'Last 14 Days',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          _buildCalendarStrip(p.last14Days),

          const SizedBox(height: 10),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(const Color(0xFF16A34A), 'Taken'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFB91C1C), 'Missed'),
              const SizedBox(width: 16),
              _legendDot(Colors.grey.shade300, 'No data'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip(List<_AdherenceDay> days) {
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
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
        final isToday = d.date.day == DateTime.now().day;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                  ),
                ),
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
                        color: Colors.white,
                      ),
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
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
      ),
    ],
  );

  // ── Medications section ───────────────────────────────────────────────────────
  Widget _buildMedicationsSection(_PatientData p) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Medications', Icons.medication_rounded),
        const SizedBox(height: 14),
        ...p.medications.asMap().entries.map((e) {
          final isLast = e.key == p.medications.length - 1;
          return Column(
            children: [
              _buildMedCard(e.value),
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

  Widget _buildMedCard(_Medication med) {
    final ac = _adherenceColor(med.adherence);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: kP4.withOpacity(0.1),
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
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                med.dosage,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 6),
              // Times
              Wrap(
                spacing: 6,
                children: med.times
                    .map((t) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kP2.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 10, color: kP3),
                      const SizedBox(width: 3),
                      Text(
                        t,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: kP3,
                        ),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Per-med adherence
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${med.adherence.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: ac,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: med.adherence / 100,
                  minHeight: 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(ac),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Risk explanation ──────────────────────────────────────────────────────────
  Widget _buildRiskExplanation(_PatientData p, Color rc) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: rc.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
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
            color: rc.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.info_outline_rounded, color: rc, size: 20),
        ),
        title: Text(
          'Why this risk level?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: kP2,
          ),
        ),
        subtitle: Text(
          _riskLabel(p.risk),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: rc,
          ),
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
              color: rc.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: rc.withOpacity(0.15)),
            ),
            child: Text(
              p.riskExplanation,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ── Actions section ───────────────────────────────────────────────────────────
  Widget _buildActions(BuildContext context, _PatientData p) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Actions', Icons.touch_app_rounded),
        const SizedBox(height: 14),
        _actionButton(
          icon: Icons.calendar_month_rounded,
          label: 'Schedule Follow-up',
          color: kP3,
          onTap: () => context.push(
            '/worker/patients/${widget.patientId}/follow-up',
          ),
        ),
        const SizedBox(height: 10),
        _actionButton(
          icon: Icons.sms_rounded,
          label: 'Send SMS Reminder',
          color: kP4,
          onTap: () => _showSmsDialog(context),
        ),
        const SizedBox(height: 10),
        _actionButton(
          icon: Icons.edit_calendar_rounded,
          label: 'Edit Medication Schedule',
          color: const Color(0xFF6D28D9),
          onTap: () => context.push(
            '/worker/patients/${widget.patientId}/schedule',
          ),
        ),
      ],
    ),
  );

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
          side: BorderSide(color: color.withOpacity(0.6), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          minimumSize: const Size(double.infinity, 48),
        ),
      );

  void _showSmsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Send SMS Reminder',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: kP2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a medication reminder SMS to ${_patient.firstName}?',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kP4.withOpacity(0.2)),
              ),
              child: Text(
                '"Hi ${_patient.firstName}, this is a reminder to take your medication today. Please contact your clinic if you have any questions."',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('SMS sent to ${_patient.firstName}'),
                  backgroundColor: const Color(0xFF16A34A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kP4,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Send',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Follow-up log ─────────────────────────────────────────────────────────────
  Widget _buildFollowUpLog(_PatientData p) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Follow-up Log', Icons.history_rounded),
        const SizedBox(height: 14),
        if (p.followUpLog.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No follow-up notes yet.',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade400),
              ),
            ),
          )
        else
          ...p.followUpLog.asMap().entries.map((e) {
            final isLast = e.key == p.followUpLog.length - 1;
            return _buildFollowUpEntry(e.value, isLast: isLast);
          }),
      ],
    ),
  );

  Widget _buildFollowUpEntry(_FollowUpNote note, {required bool isLast}) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line
        SizedBox(
          width: 20,
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: kP4,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: kP4.withOpacity(0.3), blurRadius: 4),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: kP4.withOpacity(0.2),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Note content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      note.date,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: kP2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      note.worker,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(10),
                    border:
                    Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    note.note,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  // ── Section title helper ──────────────────────────────────────────────────────
  Widget _sectionTitle(String label, IconData icon) => Row(
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: kP3.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: kP3),
      ),
      const SizedBox(width: 10),
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: kP2,
        ),
      ),
    ],
  );
}