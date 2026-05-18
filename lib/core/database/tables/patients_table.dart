import 'package:drift/drift.dart';

/// Represents a patient registered in the app.
/// Referenced by medications, reminders, and adherence_logs via patient_id.
class Patients extends Table {
  // Primary key — auto-incremented integer
  IntColumn get id => integer().autoIncrement()();

  // Registration code used during onboarding (from the clinic)
  TextColumn get registrationCode => text().named('registration_code')();

  // Full name
  TextColumn get fullName => text().named('full_name')();

  // Phone number — used for SMS fallback reminders
  TextColumn get phoneNumber => text().named('phone_number')();

  // Date of birth — stored as ISO 8601 string (yyyy-MM-dd)
  TextColumn get dateOfBirth => text().named('date_of_birth')();

  // Gender: 'male' | 'female' | 'other'
  TextColumn get gender => text().withLength(min: 1, max: 10)();

  // Preferred language: 'en' | 'zu' | 'xh'
  TextColumn get language => text().withDefault(const Constant('en'))();

  // PIN stored as a bcrypt hash — never store plain text
  TextColumn get pinHash => text().named('pin_hash')();

  // Caregiver phone number — nullable, only set if caregiver is linked
  TextColumn get caregiverPhone =>
      text().named('caregiver_phone').nullable()();

  // Risk level: 'low' | 'medium' | 'high' — recalculated by risk engine
  TextColumn get riskLevel =>
      text().named('risk_level').withDefault(const Constant('low'))();

  // Whether the patient record has been synced to the backend
  BoolColumn get isSynced =>
      boolean().named('is_synced').withDefault(const Constant(false))();

  // Timestamps
  DateTimeColumn get createdAt => dateTime()
      .named('created_at')
      .withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime()
      .named('updated_at')
      .withDefault(currentDateAndTime)();
}