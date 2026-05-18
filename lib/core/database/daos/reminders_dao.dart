import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/medications_table.dart';
import '../tables/patients_table.dart';
import '../tables/reminders_table.dart';

part 'reminders_dao.g.dart';

/// Data Access Object for the reminders table.
/// All reminder reads and writes go through here.
/// Injected into reminder_repository.dart and notification_service.dart.
@DriftAccessor(tables: [Reminders, Patients, Medications])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  // ─── CREATE ───────────────────────────────────────────────────────────────

  /// Insert a single reminder. Returns the auto-generated id.
  /// Called by reminder_settings_screen.dart when a new time slot is added.
  Future<int> insertReminder(RemindersCompanion entry) =>
      into(reminders).insert(entry);

  /// Insert multiple reminders in one transaction.
  /// Called when a medication with custom times is first created —
  /// each HH:mm entry in customTimes becomes its own reminder row.
  Future<void> insertReminders(List<RemindersCompanion> entries) =>
      batch((b) => b.insertAll(reminders, entries));

  // ─── READ ─────────────────────────────────────────────────────────────────

  /// Fetch a single reminder by id.
  Future<Reminder?> getReminderById(int id) =>
      (select(reminders)..where((r) => r.id.equals(id))).getSingleOrNull();

  /// Fetch all reminders for a patient.
  /// Used by reminder_settings_screen.dart to display the full schedule.
  Future<List<Reminder>> getRemindersForPatient(int patientId) =>
      (select(reminders)
        ..where((r) => r.patientId.equals(patientId))
        ..orderBy([(r) => OrderingTerm.asc(r.scheduledTime)]))
          .get();

  /// Watch all reminders for a patient — reactive stream for
  /// reminder_settings_screen.dart so UI updates when schedule changes.
  Stream<List<Reminder>> watchRemindersForPatient(int patientId) =>
      (select(reminders)
        ..where((r) => r.patientId.equals(patientId))
        ..orderBy([(r) => OrderingTerm.asc(r.scheduledTime)]))
          .watch();

  /// Fetch all active reminders for a patient.
  /// Called by notification_service.dart on app launch and after any
  /// schedule change to rebuild the system notification queue.
  Future<List<Reminder>> getActiveRemindersForPatient(int patientId) =>
      (select(reminders)
        ..where(
              (r) =>
          r.patientId.equals(patientId) & r.isActive.equals(true),
        )
        ..orderBy([(r) => OrderingTerm.asc(r.scheduledTime)]))
          .get();

  /// Fetch all active reminders for a specific medication.
  /// Used when a medication is deactivated — its reminders need cancelling
  /// in notification_service.dart before being paused here.
  Future<List<Reminder>> getActiveRemindersForMedication(int medicationId) =>
      (select(reminders)
        ..where(
              (r) =>
          r.medicationId.equals(medicationId) &
          r.isActive.equals(true),
        ))
          .get();

  /// Fetch reminders by delivery channel — used by sms_fallback_service.dart
  /// to find patients that need SMS reminders ('sms' | 'both').
  Future<List<Reminder>> getRemindersByChannel(String channel) =>
      (select(reminders)
        ..where(
              (r) =>
          r.deliveryChannel.equals(channel) & r.isActive.equals(true),
        ))
          .get();

  /// Fetch all reminders that have a scheduled notification ID.
  /// Used by notification_service.dart on app restart to cancel stale
  /// system notifications before rescheduling fresh ones.
  Future<List<Reminder>> getRemindersWithNotificationId(int patientId) =>
      (select(reminders)
        ..where(
              (r) =>
          r.patientId.equals(patientId) &
          r.notificationId.isNotNull(),
        ))
          .get();

  /// Fetch all unsynced reminders — called by sync_service.dart.
  Future<List<Reminder>> getUnsyncedReminders() =>
      (select(reminders)..where((r) => r.isSynced.equals(false))).get();

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  /// Replace all fields on a reminder row.
  Future<bool> updateReminder(Reminder reminder) =>
      update(reminders).replace(reminder);

  /// Partial update — only touches provided columns.
  Future<int> updateReminderFields(int id, RemindersCompanion fields) =>
      (update(reminders)..where((r) => r.id.equals(id))).write(fields);

  /// Store the system notification ID after notification_service.dart
  /// schedules the alarm — needed to cancel or reschedule it later.
  Future<int> setNotificationId(int id, int notificationId) =>
      updateReminderFields(
        id,
        RemindersCompanion(
          notificationId: Value(notificationId),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Clear the notification ID when a reminder is cancelled —
  /// signals that no system alarm is currently scheduled for this row.
  Future<int> clearNotificationId(int id) => updateReminderFields(
    id,
    RemindersCompanion(
      notificationId: const Value(null),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Activate or deactivate a reminder.
  /// Deactivating pauses the reminder without losing its schedule config.
  /// Always cancel the system notification first via notification_service.dart
  /// before calling this.
  Future<int> setReminderActive(int id, {required bool isActive}) =>
      updateReminderFields(
        id,
        RemindersCompanion(
          isActive: Value(isActive),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Update the delivery channel — called from reminder_settings_screen.dart
  /// when patient switches between push, SMS, or both.
  Future<int> updateDeliveryChannel(int id, String channel) =>
      updateReminderFields(
        id,
        RemindersCompanion(
          deliveryChannel: Value(channel),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Stamp lastTriggeredAt when a reminder fires.
  /// Called by notification_service.dart after each alarm fires.
  /// Used by risk_engine.dart to detect missed dose windows.
  Future<int> stampLastTriggered(int id) => updateReminderFields(
    id,
    RemindersCompanion(
      lastTriggeredAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Mark a reminder as synced after backend upload.
  Future<int> markAsSynced(int id) => updateReminderFields(
    id,
    RemindersCompanion(
      isSynced: const Value(true),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Deactivate all reminders for a medication in one call.
  /// Used when setMedicationActive(false) is called in medications_dao —
  /// both should always be called together in the same transaction.
  Future<int> deactivateRemindersForMedication(int medicationId) =>
      (update(reminders)..where((r) => r.medicationId.equals(medicationId)))
          .write(
        RemindersCompanion(
          isActive: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );

  // ─── DELETE ───────────────────────────────────────────────────────────────

  /// Hard delete a reminder by id.
  /// Always cancel the system notification via notification_service.dart
  /// before calling this — use notificationId stored on the row.
  Future<int> deleteReminder(int id) =>
      (delete(reminders)..where((r) => r.id.equals(id))).go();

  /// Delete all reminders for a medication — called when a medication
  /// is hard-deleted. Cascade handles this automatically but this
  /// method is useful when you need to cancel notifications first,
  /// then delete: fetch → cancel notifications → call this.
  Future<int> deleteRemindersForMedication(int medicationId) =>
      (delete(reminders)..where((r) => r.medicationId.equals(medicationId)))
          .go();

  /// Delete all reminders for a patient — used during full local wipe
  /// before re-syncing from backend.
  Future<int> deleteRemindersForPatient(int patientId) =>
      (delete(reminders)..where((r) => r.patientId.equals(patientId))).go();
}