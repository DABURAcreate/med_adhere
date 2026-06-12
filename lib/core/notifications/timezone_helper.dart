import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Initialises the timezone database and sets tz.local to the device's
/// best-guess local timezone.
///
/// Called once from NotificationService.initialize() before any
/// zonedSchedule calls — must run before notifications are scheduled.
class TimezoneHelper {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    try {
      final offset = DateTime.now().timeZoneOffset;
      final location = _locationFromOffset(offset);
      tz.setLocalLocation(location);
    } catch (e) {
      debugPrint('[Timezone] Could not detect timezone, falling back to Africa/Johannesburg: $e');
      try {
        tz.setLocalLocation(tz.getLocation('Africa/Johannesburg'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }

    _initialized = true;
    debugPrint('[Timezone] Initialized. Local: ${tz.local.name}');
  }

  /// Returns the next TZDateTime that falls at [hour]:[minute] local time.
  /// If that moment is less than 60 seconds away it is pushed to tomorrow,
  /// so notifications always schedule at least 1 minute in the future.
  static tz.TZDateTime nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now.add(const Duration(minutes: 1)))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // Best-effort map from UTC offset → IANA timezone name.
  // Covers the Southern African market (UTC+2) and nearby zones.
  static tz.Location _locationFromOffset(Duration offset) {
    final hours = offset.inHours;
    try {
      switch (hours) {
        case 2:
          return tz.getLocation('Africa/Johannesburg');
        case 1:
          return tz.getLocation('Africa/Lagos');
        case 3:
          return tz.getLocation('Africa/Nairobi');
        case 0:
          return tz.getLocation('Africa/Accra');
        case -5:
          return tz.getLocation('America/New_York');
        case -8:
          return tz.getLocation('America/Los_Angeles');
        default:
          return tz.getLocation('Africa/Johannesburg');
      }
    } catch (_) {
      return tz.UTC;
    }
  }
}
