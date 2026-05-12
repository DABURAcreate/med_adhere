import 'package:flutter/material.dart';
import '../widgets/scaffold.dart';

class AdherenceCalendarScreen extends StatefulWidget {
  const AdherenceCalendarScreen({super.key});

  @override
  State<AdherenceCalendarScreen> createState() =>
      _AdherenceCalendarScreenState();
}

class _AdherenceCalendarScreenState extends State<AdherenceCalendarScreen> {
  // The month currently being viewed (day is always set to the 1st).
  late DateTime _visibleMonth;

  // The day the user has tapped (if any) in the visible month.
  int? _selectedDay;

  // Mock adherence data keyed by `YYYY-MM-DD`.
  // In production this comes from a repository / bloc.
  late final Map<String, _DayAdherence> _adherence;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _adherence = _buildMockData(_visibleMonth);
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month - 1);
      _selectedDay = null;
    });
  }

  void _goToNextMonth() {
    final now = DateTime.now();
    final nextMonth =
    DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    // Don't allow navigating into the future.
    if (nextMonth.isAfter(DateTime(now.year, now.month))) return;
    setState(() {
      _visibleMonth = nextMonth;
      _selectedDay = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final summary = _monthSummary();

    return MainScaffold(
      title: 'My Progress',
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
                  Row(
                    children: [
                      _StreakBadge(streakDays: summary.currentStreak),
                      const Spacer(),

                      const _LegendItem(
                        color: _AdherenceColors.taken,
                        label: 'Taken',
                      ),

                      const SizedBox(width: 12),

                      const _LegendItem(
                        color: _AdherenceColors.partial,
                        label: 'Partial',
                      ),

                      const SizedBox(width: 12),

                      const _LegendItem(
                        color: _AdherenceColors.missed,
                        label: 'Missed',
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
                      onClose: () =>
                          setState(() => _selectedDay = null),
                    ),

                  if (_selectedDay != null)
                    const SizedBox(height: 20),

                  _MonthlySummary(summary: summary),

                  const SizedBox(height: 24),

                  _PreviousMonthButton(
                    onTap: _goToPreviousMonth,
                  ),
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
  // Summary calculation
  // ---------------------------------------------------------------------------

  _MonthSummaryData _monthSummary() {
    final today = DateTime.now();
    int taken = 0;
    int scheduled = 0;
    int streak = 0;

    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;

    for (var d = 1; d <= daysInMonth; d++) {
      final key = _keyFor(_visibleMonth.year, _visibleMonth.month, d);
      final entry = _adherence[key];
      if (entry == null) continue;
      taken += entry.takenCount;
      scheduled += entry.scheduledCount;
    }

    // Walk backward from today computing the current streak.
    var cursor = DateTime(today.year, today.month, today.day);
    while (true) {
      final key = _keyFor(cursor.year, cursor.month, cursor.day);
      final entry = _adherence[key];
      if (entry == null || entry.status != _DayStatus.taken) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final pct = scheduled == 0 ? 0.0 : (taken / scheduled) * 100.0;
    return _MonthSummaryData(
      takenDoses: taken,
      scheduledDoses: scheduled,
      percent: pct,
      currentStreak: streak,
    );
  }

  // ---------------------------------------------------------------------------
  // Mock data
  // ---------------------------------------------------------------------------

  Map<String, _DayAdherence> _buildMockData(DateTime month) {
    // Mirrors the design: days 1 & 2 green, 3 green, 4 amber, 5 red, rest grey.
    // In a real app, this comes from the patient's records repository.
    return {
      _keyFor(month.year, month.month, 1): const _DayAdherence(
        status: _DayStatus.taken,
        scheduledCount: 2,
        takenCount: 2,
        meds: [
          _MedDose(name: 'Tenofovir / FTC', scheduledAt: '08:00', takenAt: '08:05'),
          _MedDose(name: 'Dolutegravir', scheduledAt: '20:00', takenAt: '20:12'),
        ],
      ),
      _keyFor(month.year, month.month, 2): const _DayAdherence(
        status: _DayStatus.taken,
        scheduledCount: 2,
        takenCount: 2,
        meds: [
          _MedDose(name: 'Tenofovir / FTC', scheduledAt: '08:00', takenAt: '07:58'),
          _MedDose(name: 'Dolutegravir', scheduledAt: '20:00', takenAt: '20:03'),
        ],
      ),
      _keyFor(month.year, month.month, 3): const _DayAdherence(
        status: _DayStatus.taken,
        scheduledCount: 2,
        takenCount: 2,
        meds: [
          _MedDose(name: 'Tenofovir / FTC', scheduledAt: '08:00', takenAt: '08:11'),
          _MedDose(name: 'Dolutegravir', scheduledAt: '20:00', takenAt: '19:47'),
        ],
      ),
      _keyFor(month.year, month.month, 4): const _DayAdherence(
        status: _DayStatus.partial,
        scheduledCount: 2,
        takenCount: 1,
        meds: [
          _MedDose(name: 'Tenofovir / FTC', scheduledAt: '08:00', takenAt: '08:20'),
          _MedDose(name: 'Dolutegravir', scheduledAt: '20:00', takenAt: null),
        ],
      ),
      _keyFor(month.year, month.month, 5): const _DayAdherence(
        status: _DayStatus.missed,
        scheduledCount: 2,
        takenCount: 0,
        meds: [
          _MedDose(name: 'Tenofovir / FTC', scheduledAt: '08:00', takenAt: null),
          _MedDose(name: 'Dolutegravir', scheduledAt: '20:00', takenAt: null),
        ],
      ),
    };
  }

  static String _keyFor(int y, int m, int d) =>
      '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
}

// =============================================================================
// Colours & status enum
// =============================================================================

class _AdherenceColors {
  static const taken = Color(0xFF22C55E);   // green
  static const partial = Color(0xFFF59E0B); // amber
  static const missed = Color(0xFFEF4444);  // red
  static const none = Color(0xFFD9D9D9);    // grey (no doses scheduled / past)
  static const future = Color(0xFF1F1F1F);  // future days (invisible on black)
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
            hasStreak ? '$streakDays-day streak' : 'No Streak',
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
  const _LegendItem({
    required this.color,
    required this.label,
  });

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
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;
    // Monday-first like the screenshot: 1 = Mon ... 7 = Sun.
    final leadingBlanks = firstOfMonth.weekday - 1;

    final cells = <Widget>[];

    // Leading blanks.
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }

    final today = DateTime.now();
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final key = _AdherenceCalendarScreenState._keyFor(
        month.year,
        month.month,
        d,
      );
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
          border: selected
              ? Border.all(color: Colors.white, width: 2)
              : null,
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
                child: const Icon(Icons.close, color: Colors.white54, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (adherence == null || adherence!.meds.isEmpty)
            const Text(
              'No doses scheduled.',
              style: TextStyle(color: Colors.white70),
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
            color: taken
                ? _AdherenceColors.taken
                : _AdherenceColors.missed,
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
                ? 'Taken ${dose.takenAt}'
                : 'Missed (${dose.scheduledAt})',
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
          const Text(
            'This month',
            style: TextStyle(color: Colors.white54, fontSize: 13),
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
            'You took ${summary.takenDoses} of ${summary.scheduledDoses} scheduled doses.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Previous-month pill button (matches design)
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, size: 14, color: Colors.black),
              SizedBox(width: 6),
              Text(
                'Previous Month',
                style: TextStyle(
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
// Data models (private to this file — replace with real ones from your domain)
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
  final String? takenAt; // null = missed
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