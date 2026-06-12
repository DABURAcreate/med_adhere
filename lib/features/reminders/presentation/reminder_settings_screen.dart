import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../providers/session_provider.dart';
import '../../patient/data/patient_repository.dart';
import '../data/reminder_repository.dart';

/// Screen 08 — Patient · Reminder Settings
///
/// Loads the patient's active medications and their reminder times from the
/// local database, lets the patient adjust times / toggle individual reminders,
/// and persists changes back to the DB + reschedules push notifications on save.
class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  static const Color _teal = Color(0xFF009688);

  List<_MedicationReminders> _medications = [];
  bool _loading = true;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Data loading ─────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    final patientId =
        context.read<SessionProvider>().currentPatientId;
    if (patientId == null) {
      setState(() => _loading = false);
      return;
    }

    final patientRepo = context.read<PatientRepository>();
    final meds = await patientRepo.getMedications(patientId);
    final reminders = await patientRepo.getRemindersForPatient(patientId);

    // Group reminders by medicationId.
    final remindersByMed = <int, List<Reminder>>{};
    for (final r in reminders) {
      remindersByMed.putIfAbsent(r.medicationId, () => []).add(r);
    }

    final items = meds
        .where((m) => m.isActive)
        .map((m) {
          final medReminders = remindersByMed[m.id] ?? [];
          return _MedicationReminders(
            dbId: m.id,
            name: m.name,
            dosage: '${m.dosage} · ${m.frequency}',
            reminders: medReminders.isEmpty
                ? [
                    _Reminder(
                      dbId: null,
                      time: const TimeOfDay(hour: 8, minute: 0),
                      enabled: true,
                    )
                  ]
                : medReminders.map((r) {
                    final parts = r.scheduledTime.split(':');
                    final h = int.tryParse(parts[0]) ?? 8;
                    final min = parts.length > 1
                        ? (int.tryParse(parts[1]) ?? 0)
                        : 0;
                    return _Reminder(
                      dbId: r.id,
                      time: TimeOfDay(hour: h, minute: min),
                      enabled: r.isActive,
                    );
                  }).toList(),
          );
        })
        .toList();

    if (mounted) {
      setState(() {
        _medications = items;
        _loading = false;
      });
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

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
          dbId: null,
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
    final patientId =
        context.read<SessionProvider>().currentPatientId;
    if (patientId == null) return;

    setState(() => _saving = true);

    final reminderRepo = context.read<ReminderRepository>();
    final db = context.read<AppDatabase>();

    for (final med in _medications) {
      // Replace all reminders for this medication with what's in the UI.
      await reminderRepo.deleteRemindersForMedication(med.dbId);

      for (final r in med.reminders) {
        final timeStr =
            '${r.time.hour.toString().padLeft(2, '0')}:'
            '${r.time.minute.toString().padLeft(2, '0')}';
        await reminderRepo.insertReminder(
          RemindersCompanion(
            patientId: Value(patientId),
            medicationId: Value(med.dbId),
            scheduledTime: Value(timeStr),
            isActive: Value(r.enabled),
            isSynced: const Value(false),
          ),
        );
      }
    }

    // Reschedule all push notifications to reflect the updated schedule.
    await NotificationService.scheduleAllForPatient(
      db: db,
      patientId: patientId,
    );

    // Reload DB state into local models so dbIds are updated.
    await _loadData();

    if (!mounted) return;
    setState(() {
      _saving = false;
      _dirty = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.remindersSaved),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

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
        title: Text(
          AppLocalizations.of(context)!.reminderSettingsTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _medications.isEmpty
                ? _emptyState()
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          children: [
                            for (var i = 0;
                                i < _medications.length;
                                i++)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: _MedicationCard(
                                  med: _medications[i],
                                  teal: _teal,
                                  onToggleExpanded: () =>
                                      _toggleExpanded(i),
                                  onEditTime: (rIdx) =>
                                      _editTime(i, rIdx),
                                  onToggleReminder: (rIdx, v) =>
                                      _toggleReminder(i, rIdx, v),
                                  onDeleteReminder: (rIdx) =>
                                      _deleteReminder(i, rIdx),
                                  onAddReminder: () =>
                                      _addReminder(i),
                                ),
                              ),
                            const SizedBox(height: 8),
                            _FrequencyNote(),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
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

  Widget _emptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              l10n.noActiveMedicationsTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noActiveMedicationsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
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
                          AppLocalizations.of(context)!.remindersOn(activeCount, med.reminders.length),
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
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                  padding:
                      const EdgeInsets.fromLTRB(8, 4, 8, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onAddReminder,
                      style: TextButton.styleFrom(
                        foregroundColor: teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        AppLocalizations.of(context)!.addReminderTime,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
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
// One reminder row
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
    final timeStr = MaterialLocalizations.of(context).formatTimeOfDay(
      reminder.time,
      alwaysUse24HourFormat:
          MediaQuery.of(context).alwaysUse24HourFormat,
    );
    final muted = !reminder.enabled;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        children: [
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
                      color: muted
                          ? const Color(0xFF9CA3AF)
                          : teal,
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
                        fontFeatures: const [
                          FontFeature.tabularFigures()
                        ],
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
              tooltip: AppLocalizations.of(context)!.removeReminderTooltip,
              visualDensity: VisualDensity.compact,
            ),
          Switch(
            value: reminder.enabled,
            onChanged: onToggle,
            activeThumbColor: Colors.white,
            activeTrackColor: teal,
          ),
        ],
      ),
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
        const Icon(Icons.info_outline, size: 16, color: Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.reminderFrequencyNote,
            style: const TextStyle(
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
              : Text(AppLocalizations.of(context)!.save),
        ),
      ),
    );
  }
}

// =============================================================================
// Local UI models
// =============================================================================

class _MedicationReminders {
  _MedicationReminders({
    required this.dbId,
    required this.name,
    this.dosage,
    required this.reminders,
  });

  final int dbId;
  final String name;
  final String? dosage;
  bool expanded = false;
  final List<_Reminder> reminders;
}

class _Reminder {
  _Reminder({
    required this.dbId,
    required this.time,
    required this.enabled,
  });

  final int? dbId;
  TimeOfDay time;
  bool enabled;
}
