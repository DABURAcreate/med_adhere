import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/database/app_database.dart';
import '../../../providers/session_provider.dart';
import '../data/adherence_repository.dart';
import '../data/patient_repository.dart';
import '../widgets/scaffold.dart';

class AdherenceCalendarScreen extends StatefulWidget {
  const AdherenceCalendarScreen({super.key});

  @override
  State<AdherenceCalendarScreen> createState() =>
      _AdherenceCalendarScreenState();
}

class _AdherenceCalendarScreenState extends State<AdherenceCalendarScreen> {
  late DateTime _visibleMonth;
  int? _selectedDay;

  // Adherence data keyed by 'YYYY-MM-DD', built from real logs.
  Map<String, _DayAdherence> _adherence = {};

  // Medication id → name, loaded once per session.
  Map<int, String> _medNames = {};

  int _streak = 0;

  StreamSubscription<List<AdherenceLog>>? _logSub;
  bool _medsLoaded = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_medsLoaded) {
      _medsLoaded = true;
      _loadMedNames();
    }
    _subscribeToLogs();
  }

  @override
  void dispose() {
    _logSub?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  void _subscribeToLogs() {
    _logSub?.cancel();
    final patientId = context.read<SessionProvider>().currentPatientId;
    if (patientId == null) return;

    final from = DateTime(_visibleMonth.year, _visibleMonth.month);
    final to = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0, 23, 59, 59);

    _logSub = context
        .read<AdherenceRepository>()
        .watchLogsInRange(patientId: patientId, from: from, to: to)
        .listen(_onLogsUpdated);
  }

  Future<void> _loadMedNames() async {
    final patientId = context.read<SessionProvider>().currentPatientId;
    if (patientId == null) return;
    final meds = await context.read<PatientRepository>().getMedications(patientId);
    if (mounted) {
      setState(() {
        _medNames = {for (final m in meds) m.id: m.name};
      });
    }
  }

  Future<void> _loadStreak() async {
    final patientId = context.read<SessionProvider>().currentPatientId;
    if (patientId == null) return;
    final s = await context.read<AdherenceRepository>().getCurrentStreak(patientId);
    if (mounted) setState(() => _streak = s);
  }

  void _onLogsUpdated(List<AdherenceLog> logs) {
    final byDay = <String, List<AdherenceLog>>{};
    for (final log in logs) {
      final key = _keyFor(log.scheduledAt.year, log.scheduledAt.month, log.scheduledAt.day);
      byDay.putIfAbsent(key, () => []).add(log);
    }

    final result = <String, _DayAdherence>{};
    for (final entry in byDay.entries) {
      final dayLogs = entry.value;
      final taken = dayLogs
          .where((l) => l.status == 'taken' || l.status == 'late')
          .length;
      final total = dayLogs.length;

      _DayStatus status;
      if (total == 0) {
        status = _DayStatus.none;
      } else if (taken == total) {
        status = _DayStatus.taken;
      } else if (taken > 0) {
        status = _DayStatus.partial;
      } else {
        status = _DayStatus.missed;
      }

      final meds = dayLogs.map((l) {
        final scheduledStr = DateFormat('HH:mm').format(l.scheduledAt);
        final takenStr = l.takenAt != null
            ? DateFormat('HH:mm').format(l.takenAt!)
            : null;
        return _MedDose(
          name: _medNames[l.medicationId] ?? 'Medication',
          scheduledAt: scheduledStr,
          takenAt: takenStr,
        );
      }).toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      result[entry.key] = _DayAdherence(
        status: status,
        scheduledCount: total,
        takenCount: taken,
        meds: meds,
      );
    }

    if (mounted) {
      setState(() => _adherence = result);
      _loadStreak();
    }
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
      _selectedDay = null;
    });
    _subscribeToLogs();
  }

  void _goToNextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    if (nextMonth.isAfter(DateTime(now.year, now.month))) return;
    setState(() {
      _visibleMonth = nextMonth;
      _selectedDay = null;
    });
    _subscribeToLogs();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final summary = _monthSummary();

    return MainScaffold(
      title: AppLocalizations.of(context)!.myProgress,
      currentIndex: 1,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              final v = details.primaryVelocity ?? 0;
              if (v > 200) _goToPreviousMonth();
              if (v < -200) _goToNextMonth();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 8,
                    children: [
                      _StreakBadge(streakDays: _streak),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LegendItem(
                            color: _AdherenceColors.taken,
                            label: AppLocalizations.of(context)!.taken,
                          ),
                          const SizedBox(width: 8),
                          _LegendItem(
                            color: _AdherenceColors.partial,
                            label: AppLocalizations.of(context)!.legendPartial,
                          ),
                          const SizedBox(width: 8),
                          _LegendItem(
                            color: _AdherenceColors.missed,
                            label: AppLocalizations.of(context)!.missed,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _MonthHeader(
                    month: _visibleMonth,
                    onPrev: _goToPreviousMonth,
                    onNext: _canGoNext() ? _goToNextMonth : null,
                  ),
                  const SizedBox(height: 12),

                  _CalendarGrid(
                    month: _visibleMonth,
                    adherence: _adherence,
                    selectedDay: _selectedDay,
                    onDayTap: (day) {
                      setState(() {
                        _selectedDay = (_selectedDay == day) ? null : day;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  if (_selectedDay != null)
                    _DayDetailPanel(
                      date: DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month,
                        _selectedDay!,
                      ),
                      adherence: _adherence[_keyFor(
                        _visibleMonth.year,
                        _visibleMonth.month,
                        _selectedDay!,
                      )],
                      onClose: () => setState(() => _selectedDay = null),
                    ),

                  if (_selectedDay != null) const SizedBox(height: 20),

                  _MonthlySummary(summary: summary),
                  const SizedBox(height: 24),

                  _PreviousMonthButton(onTap: _goToPreviousMonth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _canGoNext() {
    final now = DateTime.now();
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    return !next.isAfter(DateTime(now.year, now.month));
  }

  // ---------------------------------------------------------------------------
  // Summary calculation (reads from _adherence — now backed by real data)
  // ---------------------------------------------------------------------------

  _MonthSummaryData _monthSummary() {
    final today = DateTime.now();
    int taken = 0;
    int scheduled = 0;
    int streak = _streak;

    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;

    for (var d = 1; d <= daysInMonth; d++) {
      final key = _keyFor(_visibleMonth.year, _visibleMonth.month, d);
      final entry = _adherence[key];
      if (entry == null) continue;
      taken += entry.takenCount;
      scheduled += entry.scheduledCount;
    }

    // Streak from current month data (full streak computed via DB in _loadStreak)
    var cursor = DateTime(today.year, today.month, today.day);
    int localStreak = 0;
    while (true) {
      final key = _keyFor(cursor.year, cursor.month, cursor.day);
      final entry = _adherence[key];
      if (entry == null || entry.status != _DayStatus.taken) break;
      localStreak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    // Use the better of DB streak and local calculation
    if (localStreak > streak) streak = localStreak;

    final pct = scheduled == 0 ? 0.0 : (taken / scheduled) * 100.0;
    return _MonthSummaryData(
      takenDoses: taken,
      scheduledDoses: scheduled,
      percent: pct,
      currentStreak: streak,
    );
  }

  static String _keyFor(int y, int m, int d) =>
      '${y.toString().padLeft(4, '0')}-'
      '${m.toString().padLeft(2, '0')}-'
      '${d.toString().padLeft(2, '0')}';
}

// =============================================================================
// Colours & status enum
// =============================================================================

class _AdherenceColors {
  static const taken = Color(0xFF22C55E);
  static const partial = Color(0xFFF59E0B);
  static const missed = Color(0xFFEF4444);
  static const none = Color(0xFFD9D9D9);
  static const future = Color(0xFF1F1F1F);
}

enum _DayStatus { taken, partial, missed, none, future }

// =============================================================================
// Streak badge
// =============================================================================

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streakDays});
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final hasStreak = streakDays > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            hasStreak
                ? AppLocalizations.of(context)!.streakDays(streakDays)
                : AppLocalizations.of(context)!.noStreak,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Legend swatch
// =============================================================================

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Month header
// =============================================================================

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    this.onNext,
  });
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  static const _names = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        const SizedBox(width: 4),
        Text(
          '${_names[month.month - 1]} ${month.year}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onNext,
          icon: Icon(
            Icons.chevron_right,
            color: onNext == null ? Colors.white24 : Colors.black,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

// =============================================================================
// Calendar grid
// =============================================================================

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.adherence,
    required this.selectedDay,
    required this.onDayTap,
  });

  final DateTime month;
  final Map<String, _DayAdherence> adherence;
  final int? selectedDay;
  final ValueChanged<int> onDayTap;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday - 1;

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }

    final today = DateTime.now();
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final key = _AdherenceCalendarScreenState._keyFor(month.year, month.month, d);
      final entry = adherence[key];

      _DayStatus status;
      if (date.isAfter(DateTime(today.year, today.month, today.day))) {
        status = _DayStatus.future;
      } else {
        status = entry?.status ?? _DayStatus.none;
      }

      cells.add(_DayCell(
        day: d,
        status: status,
        selected: selectedDay == d,
        onTap: () => onDayTap(d),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final int day;
  final _DayStatus status;
  final bool selected;
  final VoidCallback onTap;

  Color get _bg {
    switch (status) {
      case _DayStatus.taken:
        return _AdherenceColors.taken;
      case _DayStatus.partial:
        return _AdherenceColors.partial;
      case _DayStatus.missed:
        return _AdherenceColors.missed;
      case _DayStatus.none:
        return _AdherenceColors.none;
      case _DayStatus.future:
        return _AdherenceColors.future;
    }
  }

  Color get _fg {
    switch (status) {
      case _DayStatus.missed:
      case _DayStatus.taken:
        return Colors.white;
      case _DayStatus.partial:
      case _DayStatus.none:
        return Colors.black;
      case _DayStatus.future:
        return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: status == _DayStatus.future ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(6),
          border:
              selected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            color: _fg,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Day detail panel
// =============================================================================

class _DayDetailPanel extends StatelessWidget {
  const _DayDetailPanel({
    required this.date,
    required this.adherence,
    required this.onClose,
  });

  final DateTime date;
  final _DayAdherence? adherence;
  final VoidCallback onClose;

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${date.day} ${_months[date.month - 1]} ${date.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child:
                    const Icon(Icons.close, color: Colors.white54, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (adherence == null || adherence!.meds.isEmpty)
            Text(
              AppLocalizations.of(context)!.noDosesLogged,
              style: const TextStyle(color: Colors.white70),
            )
          else
            ...adherence!.meds.map((m) => _MedRow(dose: m)),
        ],
      ),
    );
  }
}

class _MedRow extends StatelessWidget {
  const _MedRow({required this.dose});
  final _MedDose dose;

  @override
  Widget build(BuildContext context) {
    final taken = dose.takenAt != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            taken ? Icons.check_circle : Icons.cancel,
            color: taken ? _AdherenceColors.taken : _AdherenceColors.missed,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              dose.name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            taken
                ? AppLocalizations.of(context)!.doseLoggedAt(dose.takenAt!)
                : AppLocalizations.of(context)!.doseMissedAt(dose.scheduledAt),
            style: TextStyle(
              color: taken ? Colors.white70 : _AdherenceColors.missed,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Monthly summary
// =============================================================================

class _MonthlySummary extends StatelessWidget {
  const _MonthlySummary({required this.summary});
  final _MonthSummaryData summary;

  Color _pctColor() {
    if (summary.percent >= 90) return _AdherenceColors.taken;
    if (summary.percent >= 70) return _AdherenceColors.partial;
    return _AdherenceColors.missed;
  }

  @override
  Widget build(BuildContext context) {
    final pctStr = summary.scheduledDoses == 0
        ? '—'
        : '${summary.percent.toStringAsFixed(0)}%';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.thisMonth,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            pctStr,
            style: TextStyle(
              color: _pctColor(),
              fontSize: 44,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.monthlyDosesSummary(summary.takenDoses, summary.scheduledDoses),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Previous-month pill button
// =============================================================================

class _PreviousMonthButton extends StatelessWidget {
  const _PreviousMonthButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F2FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1E88E5), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back, size: 14, color: Colors.black),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.previousMonth,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Private data models (populated from real logs in _onLogsUpdated)
// =============================================================================

class _DayAdherence {
  const _DayAdherence({
    required this.status,
    required this.scheduledCount,
    required this.takenCount,
    required this.meds,
  });
  final _DayStatus status;
  final int scheduledCount;
  final int takenCount;
  final List<_MedDose> meds;
}

class _MedDose {
  const _MedDose({
    required this.name,
    required this.scheduledAt,
    required this.takenAt,
  });
  final String name;
  final String scheduledAt;
  final String? takenAt;
}

class _MonthSummaryData {
  const _MonthSummaryData({
    required this.takenDoses,
    required this.scheduledDoses,
    required this.percent,
    required this.currentStreak,
  });
  final int takenDoses;
  final int scheduledDoses;
  final double percent;
  final int currentStreak;
}
