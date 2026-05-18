import 'package:drift/drift.dart';

import 'medications_table.dart';
import 'patients_table.dart';
import 'reminders_table.dart';

/// Records every dose event — taken, missed, or skipped.
/// This is the most-queried table in the app:
///   - adherence_calendar_screen.dart  → range queries by date
///   - risk_engine.dart                → streak + miss-rate calculations
///   - report_screen.dart              → aggregations for PDF export
///   - dashboard_screen.dart           → clinic-wide adherence stats
class AdherenceLogs extends Table {
  // Primary key — auto-incremented integer
  IntColumn get id => integer().autoIncrement()();

  // Foreign key → patients.id
  // Direct link keeps calendar and report queries fast (no chained joins)
  IntColumn get patientId => integer()
      .named('patient_id')
      .references(Patients, #id, onDelete: KeyAction.cascade)();

  // Foreign key → medications.id
  // Cascade so logs don't orphan when a medication is removed
  IntColumn get medicationId => integer()
      .named('medication_id')
      .references(Medications, #id, onDelete: KeyAction.cascade)();

  // Foreign key → reminders.id — nullable
  // Links the log back to the reminder that triggered it.
  // Null when the patient logged a dose manually (no reminder involved)
  IntColumn get reminderId => integer()
      .named('reminder_id')
      .references(Reminders, #id, onDelete: KeyAction.setNull)
      .nullable()();

  // Dose status — the core field driving all adherence calculations
  // 'taken'   — patient confirmed they took the dose
  // 'missed'  — reminder fired, no confirmation received before cutoff
  // 'skipped' — patient explicitly marked as skipped (e.g. feeling sick)
  // 'late'    — taken after the scheduled window but before cutoff
  TextColumn get status => text().withLength(min: 4, max: 7)();

  // Exact datetime the dose was scheduled for
  // Derived from reminders.scheduled_time + the calendar date
  // Stored here so reports stay accurate even if the reminder is later changed
  DateTimeColumn get scheduledAt => dateTime().named('scheduled_at')();

  // Datetime the patient actually took/confirmed the dose
  // Null for 'missed' and 'skipped' statuses
  DateTimeColumn get takenAt => dateTime().named('taken_at').nullable()();

  // How many minutes late the dose was taken — 0 if on time
  // Pre-calculated and stored to avoid recomputing on every report query
  // Null for missed/skipped doses
  IntColumn get minutesLate => integer().named('minutes_late').nullable()();

  // Optional note from the patient e.g. "Felt nauseous", "Forgot at work"
  // Surfaced in patient_detail_screen.dart for healthcare workers
  TextColumn get note => text().nullable()();

  // Whether this log was created automatically by the system (reminder fired)
  // or manually entered by the patient
  // Used by risk_engine.dart to weight adherence scores differently
  BoolColumn get isManualEntry =>
      boolean().named('is_manual_entry').withDefault(const Constant(false))();

  // Whether this log has been synced to the backend API
  // sync_service.dart filters on isSynced == false to build its upload queue
  BoolColumn get isSynced =>
      boolean().named('is_synced').withDefault(const Constant(false))();

  // Timestamps
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  // Composite unique constraint — prevents duplicate logs for the same
  // patient + medication + scheduled slot. Guards against double-taps
  // and sync replays creating duplicate entries.
  @override
  List<Set<Column>> get uniqueKeys => [
    {patientId, medicationId, scheduledAt},
  ];
}