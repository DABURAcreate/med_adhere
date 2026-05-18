import 'package:drift/drift.dart';

import 'patients_table.dart';

/// Represents a medication assigned to a patient.
/// Each row is one medication prescription — a patient can have many.
class Medications extends Table {
  // Primary key — auto-incremented integer
  IntColumn get id => integer().autoIncrement()();

  // Foreign key → patients.id
  // Deleting a patient cascades and removes their medications
  IntColumn get patientId => integer()
      .named('patient_id')
      .references(Patients, #id, onDelete: KeyAction.cascade)();

  // Generic or brand name of the medication e.g. "Efavirenz", "Tenofovir"
  TextColumn get name => text().withLength(min: 1, max: 100)();

  // Dosage as a string to support flexible units e.g. "200mg", "1 tablet"
  TextColumn get dosage => text().withLength(min: 1, max: 50)();

  // Frequency: 'daily' | 'twice_daily' | 'weekly' | 'custom'
  TextColumn get frequency => text().withDefault(const Constant('daily'))();

  // For 'custom' frequency — stores scheduled times as comma-separated
  // HH:mm strings e.g. "08:00,14:00,20:00"
  // Nullable — only populated when frequency == 'custom'
  TextColumn get customTimes => text().named('custom_times').nullable()();

  // Instructions e.g. "Take with food", "Avoid alcohol"
  // Nullable — not all medications have special instructions
  TextColumn get instructions => text().nullable()();

  // Start date of prescription — ISO 8601 string (yyyy-MM-dd)
  TextColumn get startDate => text().named('start_date')();

  // End date — nullable, ongoing medications have no end date
  TextColumn get endDate => text().named('end_date').nullable()();

  // Whether this medication is currently active
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();

  // Stock count — how many pills/units the patient currently has
  // Nullable — optional feature, not all clinics track this
  IntColumn get stockCount => integer().named('stock_count').nullable()();

  // Refill reminder threshold — alert when stock drops to this number
  // Nullable — only relevant when stockCount is tracked
  IntColumn get refillReminderAt =>
      integer().named('refill_reminder_at').nullable()();

  // Whether synced to the backend
  BoolColumn get isSynced =>
      boolean().named('is_synced').withDefault(const Constant(false))();

  // Timestamps
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
}