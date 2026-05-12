import 'package:flutter/material.dart';

/// Screen 08 — Patient · Reminder Settings
///
/// Lets the patient customise reminder times and frequency for each
/// medication. Each medication is an expandable card; reminder times
/// can be added, edited (via Material 3 TimePicker) and individually
/// toggled on/off.
///
/// File: features/reminders/presentation/reminder_settings_screen.dart
class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  // Brand teal used for the save button + accents.
  static const Color _teal = Color(0xFF009688);

  late List<_MedicationReminders> _medications;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Mock data — in production this comes from reminders_table.dart
    // through a repository / bloc.
    _medications = [
      _MedicationReminders(
        id: 'med_1',
        name: 'Tenofovir / FTC',
        dosage: '300 mg / 200 mg · once daily',
        expanded: true,
        reminders: [
          _Reminder(id: 'r1', time: const TimeOfDay(hour: 8, minute: 0), enabled: true),
        ],
      ),
      _MedicationReminders(
        id: 'med_2',
        name: 'Dolutegravir',
        dosage: '50 mg · once daily',
        expanded: false,
        reminders: [
          _Reminder(id: 'r2', time: const TimeOfDay(hour: 20, minute: 0), enabled: true),
        ],
      ),
      _MedicationReminders(
        id: 'med_3',
        name: 'Cotrimoxazole',
        dosage: '960 mg · once daily',
        expanded: false,
        reminders: [
          _Reminder(id: 'r3', time: const TimeOfDay(hour: 12, minute: 30), enabled: false),
        ],
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _toggleExpanded(int medIndex) {
    setState(() {
      _medications[medIndex].expanded = !_medications[medIndex].expanded;
    });
  }

  Future<void> _editTime(int medIndex, int reminderIndex) async {
    final current = _medications[medIndex].reminders[reminderIndex].time;
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) {
        // Force 24h or honour locale — leaving as locale default.
        return child ?? const SizedBox.shrink();
      },
    );
    if (picked != null && picked != current) {
      setState(() {
        _medications[medIndex].reminders[reminderIndex].time = picked;
        _dirty = true;
      });
    }
  }

  void _toggleReminder(int medIndex, int reminderIndex, bool value) {
    setState(() {
      _medications[medIndex].reminders[reminderIndex].enabled = value;
      _dirty = true;
    });
  }

  void _addReminder(int medIndex) {
    setState(() {
      _medications[medIndex].reminders.add(
        _Reminder(
          id: 'r_${DateTime.now().microsecondsSinceEpoch}',
          time: const TimeOfDay(hour: 9, minute: 0),
          enabled: true,
        ),
      );
      _medications[medIndex].expanded = true;
      _dirty = true;
    });
  }

  void _deleteReminder(int medIndex, int reminderIndex) {
    setState(() {
      _medications[medIndex].reminders.removeAt(reminderIndex);
      _dirty = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    // TODO: write to reminders_table.dart + reschedule
    // flutter_local_notifications. For now we just simulate.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _saving = false;
      _dirty = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminders saved')),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Reminder Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  for (var i = 0; i < _medications.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MedicationCard(
                        med: _medications[i],
                        teal: _teal,
                        onToggleExpanded: () => _toggleExpanded(i),
                        onEditTime: (rIdx) => _editTime(i, rIdx),
                        onToggleReminder: (rIdx, v) =>
                            _toggleReminder(i, rIdx, v),
                        onDeleteReminder: (rIdx) => _deleteReminder(i, rIdx),
                        onAddReminder: () => _addReminder(i),
                      ),
                    ),
                  const SizedBox(height: 8),
                  _FrequencyNote(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // Sticky save button.
            _SaveBar(
              teal: _teal,
              enabled: _dirty && !_saving,
              saving: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Medication card (expandable)
// =============================================================================

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({
    required this.med,
    required this.teal,
    required this.onToggleExpanded,
    required this.onEditTime,
    required this.onToggleReminder,
    required this.onDeleteReminder,
    required this.onAddReminder,
  });

  final _MedicationReminders med;
  final Color teal;
  final VoidCallback onToggleExpanded;
  final ValueChanged<int> onEditTime;
  final void Function(int reminderIndex, bool value) onToggleReminder;
  final ValueChanged<int> onDeleteReminder;
  final VoidCallback onAddReminder;

  @override
  Widget build(BuildContext context) {
    final activeCount = med.reminders.where((r) => r.enabled).length;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Header row — tap to expand/collapse.
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onToggleExpanded,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: teal.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.medication_outlined,
                        color: teal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$activeCount of ${med.reminders.length} reminder${med.reminders.length == 1 ? '' : 's'} on',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 180),
                    turns: med.expanded ? 0.5 : 0,
                    child: const Icon(Icons.expand_more,
                        color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ),
          // Expanded body.
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: med.expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                const Divider(height: 1, color: Color(0xFFF0F1F3)),
                if (med.dosage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        med.dosage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                for (var i = 0; i < med.reminders.length; i++)
                  _ReminderRow(
                    reminder: med.reminders[i],
                    teal: teal,
                    onTapTime: () => onEditTime(i),
                    onToggle: (v) => onToggleReminder(i, v),
                    onDelete: med.reminders.length > 1
                        ? () => onDeleteReminder(i)
                        : null,
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onAddReminder,
                      style: TextButton.styleFrom(
                        foregroundColor: teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Add reminder time',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// One reminder row (time + toggle + delete)
// =============================================================================

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.reminder,
    required this.teal,
    required this.onTapTime,
    required this.onToggle,
    required this.onDelete,
  });

  final _Reminder reminder;
  final Color teal;
  final VoidCallback onTapTime;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTime(context, reminder.time);
    final muted = !reminder.enabled;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        children: [
          // Time pill — tap opens TimePicker.
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTapTime,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: muted ? const Color(0xFF9CA3AF) : teal,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: muted
                            ? const Color(0xFF9CA3AF)
                            : Colors.black,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline,
                  color: Color(0xFF9CA3AF), size: 20),
              tooltip: 'Remove reminder',
              visualDensity: VisualDensity.compact,
            ),
          Switch(
            value: reminder.enabled,
            onChanged: onToggle,
            activeColor: Colors.white,
            activeTrackColor: teal,
          ),
        ],
      ),
    );
  }

  String _formatTime(BuildContext context, TimeOfDay t) {
    // Honours device 12/24-hour preference via MaterialLocalizations.
    return MaterialLocalizations.of(context).formatTimeOfDay(
      t,
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }
}

// =============================================================================
// Frequency note
// =============================================================================

class _FrequencyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline,
            size: 16, color: Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Your healthcare worker may increase your reminder frequency '
                'based on your adherence.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Sticky save bar
// =============================================================================

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.teal,
    required this.enabled,
    required this.saving,
    required this.onPressed,
  });

  final Color teal;
  final bool enabled;
  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: teal,
            disabledBackgroundColor: teal.withValues(alpha: 0.4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: saving
              ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : const Text('Save'),
        ),
      ),
    );
  }
}

// =============================================================================
// Data models — replace with your domain models when wiring up the repo.
// =============================================================================

class _MedicationReminders {
  _MedicationReminders({
    required this.id,
    required this.name,
    this.dosage,
    required this.reminders,
    this.expanded = false,
  });

  final String id;
  final String name;
  final String? dosage;
  bool expanded;
  final List<_Reminder> reminders;
}

class _Reminder {
  _Reminder({
    required this.id,
    required this.time,
    required this.enabled,
  });

  final String id;
  TimeOfDay time;
  bool enabled;
}