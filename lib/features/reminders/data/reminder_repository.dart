import '../../../core/database/app_database.dart';

/// Thin wrapper over RemindersDao for reminder-related screens.
class ReminderRepository {
  final AppDatabase _db;

  const ReminderRepository({required AppDatabase db}) : _db = db;

  Future<List<Reminder>> getRemindersForPatient(int patientId) =>
      _db.remindersDao.getRemindersForPatient(patientId);

  Stream<List<Reminder>> watchRemindersForPatient(int patientId) =>
      _db.remindersDao.watchRemindersForPatient(patientId);

  Future<List<Reminder>> getActiveRemindersForPatient(int patientId) =>
      _db.remindersDao.getActiveRemindersForPatient(patientId);

  Future<List<Reminder>> getActiveRemindersForMedication(int medicationId) =>
      _db.remindersDao.getActiveRemindersForMedication(medicationId);

  Future<int> insertReminder(RemindersCompanion entry) =>
      _db.remindersDao.insertReminder(entry);

  Future<void> insertReminders(List<RemindersCompanion> entries) =>
      _db.remindersDao.insertReminders(entries);

  Future<int> setReminderActive(int id, {required bool isActive}) =>
      _db.remindersDao.setReminderActive(id, isActive: isActive);

  Future<int> deleteReminder(int id) => _db.remindersDao.deleteReminder(id);

  Future<int> deleteRemindersForMedication(int medicationId) =>
      _db.remindersDao.deleteRemindersForMedication(medicationId);
}
