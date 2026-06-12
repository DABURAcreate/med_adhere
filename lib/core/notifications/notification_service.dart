import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../database/app_database.dart';
import 'timezone_helper.dart';

/// Schedules and cancels local push notifications for medication reminders.
///
/// Usage:
///   await NotificationService.initialize();           // once at app start
///   await NotificationService.requestPermissions();   // after user signs in
///   await NotificationService.scheduleAllForPatient(db: db, patientId: id);
///
/// Notifications repeat daily at the time stored on each Reminder row.
/// Uses inexactAllowWhileIdle so no special SCHEDULE_EXACT_ALARM permission
/// is required on Android 12+.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Android notification channel identifiers.
  static const _channelId = 'med_reminders';
  static const _channelName = 'Medication Reminders';
  static const _channelDesc =
      'Daily reminders to take your scheduled medications';

  // ── Initialisation ──────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;

    await TimezoneHelper.initialize();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onTapped,
    );

    _initialized = true;
    debugPrint('[Notification] Service initialized.');
  }

  // ── Permissions ─────────────────────────────────────────────────────────────

  /// Requests OS notification permission.
  /// Returns true if granted (or if the OS does not require a prompt).
  static Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      return await androidImpl.requestNotificationsPermission() ?? false;
    }
    if (iosImpl != null) {
      return await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  // ── Schedule a single reminder ───────────────────────────────────────────────

  /// Schedules a daily repeating notification at [hour]:[minute] local time.
  /// [reminderId] is used as the notification ID — must be unique per reminder.
  static Future<void> scheduleReminder({
    required int reminderId,
    required String medicationName,
    required String dosage,
    required int hour,
    required int minute,
    required int patientId,
    required int medicationId,
  }) async {
    if (!_initialized) await initialize();

    final scheduledDate = TimezoneHelper.nextInstanceOfTime(hour, minute);

    await _plugin.zonedSchedule(
      reminderId,
      'Time to take $medicationName',
      'Dosage: $dosage — tap to confirm',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '$patientId:$medicationId:$reminderId',
    );

    debugPrint(
      '[Notification] Scheduled reminder $reminderId for $medicationName'
      ' at ${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}.',
    );
  }

  // ── Cancel ───────────────────────────────────────────────────────────────────

  static Future<void> cancelReminder(int reminderId) async {
    await _plugin.cancel(reminderId);
    debugPrint('[Notification] Cancelled reminder $reminderId.');
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('[Notification] Cancelled all notifications.');
  }

  /// Cancels all currently scheduled notifications for [patientId] by
  /// reading their notification IDs from the DB.
  static Future<void> cancelAllForPatient(
    AppDatabase db,
    int patientId,
  ) async {
    final reminders =
        await db.remindersDao.getRemindersWithNotificationId(patientId);
    for (final r in reminders) {
      if (r.notificationId != null) {
        await _plugin.cancel(r.notificationId!);
      }
    }
  }

  // ── Schedule all active reminders for a patient ──────────────────────────────

  /// Cancels all existing notifications for [patientId] then reschedules
  /// every active reminder fresh.  Call this after:
  ///   - Patient signs in
  ///   - Reminder settings are saved
  ///   - A medication is activated / deactivated
  static Future<void> scheduleAllForPatient({
    required AppDatabase db,
    required int patientId,
  }) async {
    if (!_initialized) await initialize();

    await cancelAllForPatient(db, patientId);

    final reminders =
        await db.remindersDao.getActiveRemindersForPatient(patientId);

    for (final r in reminders) {
      final med = await db.medicationsDao.getMedicationById(r.medicationId);
      if (med == null || !med.isActive) continue;

      final parts = r.scheduledTime.split(':');
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute =
          parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

      final nId = r.notificationId ?? r.id;

      await scheduleReminder(
        reminderId: nId,
        medicationName: med.name,
        dosage: med.dosage,
        hour: hour,
        minute: minute,
        patientId: patientId,
        medicationId: med.id,
      );

      if (r.notificationId == null) {
        await db.remindersDao.setNotificationId(r.id, nId);
      }
    }

    debugPrint(
      '[Notification] Scheduled ${reminders.length} reminder(s)'
      ' for patient $patientId.',
    );
  }

  // ── Notification tap callback ─────────────────────────────────────────────────

  static void _onTapped(NotificationResponse response) {
    // Payload format: "patientId:medicationId:reminderId"
    debugPrint('[Notification] Tapped: ${response.payload}');
    // Deep-link navigation is wired in main.dart via a global navigator key
    // if needed.  For now logging is sufficient; the patient can confirm
    // the dose from the home screen.
  }
}
