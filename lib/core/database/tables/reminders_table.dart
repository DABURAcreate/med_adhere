import 'package:drift/drift.dart';

import 'medications_table.dart';
import 'patients_table.dart';

/// Represents a scheduled reminder for a specific medication dose.
/// One medication can have multiple reminders (e.g. twice-daily = 2 rows).
/// Consumed by notification_service.dart and sms_fallback_service.dart.
class Reminders extends Table {
  // Primary key — auto-incremented integer
  IntColumn get id => integer().autoIncrement()();

  // Foreign key → patients.id
  // Denormalised here (medications already links to patient) for fast
  // queries like "get all reminders for patient X" without a join
  IntColumn get patientId => integer()
      .named('patient_id')
      .references(Patients, #id, onDelete: KeyAction.cascade)();

  // Foreign key → medications.id
  // Deleting a medication cascades and removes its reminders
  IntColumn get medicationId => integer()
      .named('medication_id')
      .references(Medications, #id, onDelete: KeyAction.cascade)();

  // Scheduled time as HH:mm string e.g. "08:00"
  // Stored as text — avoids timezone confusion, parsed at notification time
  // using timezone_helper.dart
  TextColumn get scheduledTime => text().named('scheduled_time')();

  // Days this reminder is active — stored as comma-separated day numbers
  // 1=Monday … 7=Sunday, e.g. "1,2,3,4,5" for weekdays, "1,2,3,4,5,6,7" for daily
  // Nullable — null means every day (most common case)
  TextColumn get activeDays => text().named('active_days').nullable()();

  // Delivery channel: 'push' | 'sms' | 'both'
  // sms_fallback_service.dart checks this before sending SMS
  TextColumn get deliveryChannel =>
      text().named('delivery_channel').withDefault(const Constant('push'))();

  // Whether this reminder is currently active
  // Used to pause reminders without deleting them (e.g. patient in hospital)
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();

  // System notification ID assigned by notification_service.dart
  // Stored so we can cancel/reschedule the exact notification later
  // Nullable — null until the notification has been scheduled
  IntColumn get notificationId =>
      integer().named('notification_id').nullable()();

  // Snooze duration in minutes — 0 means no snooze configured
  IntColumn get snoozeDurationMinutes => integer()
      .named('snooze_duration_minutes')
      .withDefault(const Constant(0))();

  // Last time this reminder was triggered — used by sync_service.dart
  // to detect missed doses and by the risk engine
  DateTimeColumn get lastTriggeredAt =>
      dateTime().named('last_triggered_at').nullable()();

  // Whether synced to the backend
  BoolColumn get isSynced =>
      boolean().named('is_synced').withDefault(const Constant(false))();

  // Timestamps
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
}