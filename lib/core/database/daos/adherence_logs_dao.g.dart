// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adherence_logs_dao.dart';

// ignore_for_file: type=lint
mixin _$AdherenceLogsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PatientsTable get patients => attachedDatabase.patients;
  $MedicationsTable get medications => attachedDatabase.medications;
  $RemindersTable get reminders => attachedDatabase.reminders;
  $AdherenceLogsTable get adherenceLogs => attachedDatabase.adherenceLogs;
  AdherenceLogsDaoManager get managers => AdherenceLogsDaoManager(this);
}

class AdherenceLogsDaoManager {
  final _$AdherenceLogsDaoMixin _db;
  AdherenceLogsDaoManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db.attachedDatabase, _db.patients);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db.attachedDatabase, _db.medications);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db.attachedDatabase, _db.reminders);
  $$AdherenceLogsTableTableManager get adherenceLogs =>
      $$AdherenceLogsTableTableManager(_db.attachedDatabase, _db.adherenceLogs);
}
