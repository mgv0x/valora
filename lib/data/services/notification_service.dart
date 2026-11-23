import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/food_item.dart';

/// Abstract service managing local food expiry reminder notifications.
///
/// ### Known Platform Limitations:
///
/// **Android (API 26+)**:
/// - **Runtime Permission**: Starting from Android 13 (API 33), the `POST_NOTIFICATIONS`
///   runtime permission must be granted. If rejected, notifications are quietly withheld.
/// - **Doze Mode & Battery Savers**: Manufacturer-specific power managers (e.g. Samsung,
///   MIUI, ColorOS) may defer background alarms. Alarms fire during scheduled maintenance windows.
/// - **Device Reboots**: System alarms registered with AlarmManager are wiped on restart.
///   A `RECEIVE_BOOT_COMPLETED` receiver or app launch is required to reschedule pending items.
/// - **Notification Channels**: Required since Android 8.0. Notification importance set at
///   channel creation governs sound, vibration, and banner presentation.
///
/// **iOS (Darwin)**:
/// - **64 Notification System Cap**: iOS enforces a strict limit of 64 scheduled notifications
///   per application. Any scheduling beyond this limit is silently dropped by the OS.
/// - **Past Timestamps**: If the scheduled date/time is already in the past, iOS discards the
///   notification request immediately without error.
/// - **Focus Modes / Do Not Disturb**: Notifications adhere strictly to user Focus settings,
///   appearing silently in Notification Center unless explicit time-sensitive entitlements exist.
/// - **Timezone Adjustments**: Scheduled alerts follow device system time adjustments.
abstract class NotificationService {
  Future<void> init();
  Future<bool> requestPermission();
  Future<void> scheduleExpiryWarning({
    required FoodItem item,
    required int warningDays,
    required String title,
    required String body,
  });
  Future<void> cancelForFood(String foodId);
  Future<void> cancelAll();
}

class LocalNotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    // Local notifications are primarily designed for iOS/Android
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _plugin.initialize(settings: initializationSettings);

      if (Platform.isAndroid) {
        final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.createNotificationChannel(
          const AndroidNotificationChannel(
            'valora_expiry_channel',
            'Food Expiry Reminders',
            description:
                'Alerts before food items in your pantry reach their expiration date.',
            importance: Importance.high,
          ),
        );
      }
    }
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    if (Platform.isIOS) {
      final iosImplementation = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    } else if (Platform.isAndroid) {
      final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  int _notificationIdFromUuid(String uuid) {
    // Produce a stable 31-bit positive integer from UUID
    return uuid.hashCode & 0x7FFFFFFF;
  }

  @override
  Future<void> scheduleExpiryWarning({
    required FoodItem item,
    required int warningDays,
    required String title,
    required String body,
  }) async {
    if (item.expiryDate == null) return;
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) return;

    final targetDate = item.expiryDate!.subtract(Duration(days: warningDays));
    final scheduledTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      9, // 9:00 AM local time
      0,
    );

    if (scheduledTime.isBefore(DateTime.now())) {
      return; // Target alert moment is already in the past
    }

    final id = _notificationIdFromUuid(item.id);

    const androidDetails = AndroidNotificationDetails(
      'valora_expiry_channel',
      'Food Expiry Reminders',
      channelDescription: 'Alerts before food items in your pantry reach their expiration date.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    // Cancel any previous alert for this item first to avoid duplicates
    await cancelForFood(item.id);

    try {
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // Fallback to inexact scheduling if exact alarm permission is denied on Android 13/14+
      try {
        final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzScheduledTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) {
        // Silently handle if notification dispatch is fully disabled
      }
    }
  }

  @override
  Future<void> cancelForFood(String foodId) async {
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) return;
    final id = _notificationIdFromUuid(foodId);
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }

  @override
  Future<void> cancelAll() async {
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
