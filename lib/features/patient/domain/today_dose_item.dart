/// UI-facing status for a single dose slot on today's home screen.
///
/// Maps from DB strings ('taken', 'missed', 'skipped', 'late') to three
/// states relevant for the home-screen card. 'skipped' and 'late' are treated
/// as taken-equivalent for progress calculations.
enum DoseStatus { pending, taken, missed }

/// One row in the home-screen dose list.
///
/// Built by [AdherenceRepository.watchTodayDoses] by joining an active
/// medication's reminder (dose time slot) with today's adherence log (if any).
/// When no log exists yet, [status] is [DoseStatus.pending] and
/// [loggedAt] / [logId] are null.
///
/// [isLocked] is true whenever a log already exists for the exact
/// (patientId, medicationId, scheduledAt) slot — derived from [status].
class TodayDoseItem {
  final int patientId;
  final int medicationId;
  final String medicationName;

  /// Scheduled dose time as HH:mm string, e.g. "08:00".
  /// "--:--" when the medication has no reminders configured.
  final String doseTime;

  final int? reminderId;
  final DoseStatus status;

  /// Exact datetime for this dose slot: today's date + [doseTime].
  final DateTime scheduledAt;

  /// When the dose was logged (takenAt for taken; updatedAt for missed).
  final DateTime? loggedAt;
  final int? logId;

  bool get isLocked => status != DoseStatus.pending;

  const TodayDoseItem({
    required this.patientId,
    required this.medicationId,
    required this.medicationName,
    required this.doseTime,
    this.reminderId,
    required this.status,
    required this.scheduledAt,
    this.loggedAt,
    this.logId,
  });
}
