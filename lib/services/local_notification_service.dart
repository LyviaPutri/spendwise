import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // FUNGSI INSTAN UNTUK TESTING (Cadangan)
  static Future<void> showInstantNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Notifikasi Instan',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails);
    
    await _notificationsPlugin.show(
      id: 99, 
      title: 'Tes Notifikasi! 🚀', 
      body: 'Kalau ini muncul, berarti sistem notifikasinya aman.', 
      notificationDetails: platformChannelSpecifics,
    );
  }

  static Future<void> scheduleDailyNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Pengingat Harian',
      channelDescription: 'Notifikasi pengingat mencatat pengeluaran',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id: 0,
      title: 'Waktunya Mencatat! 📝',
      body: 'Jangan lupa catat pengeluaran manualmu hari ini ya, biar keuangan tetap aman!',
      scheduledDate: _nextInstanceOf8PM(),
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    
    debugPrint("✅ Alarm pengingat harian berhasil disetel untuk jam 20:00!");
  }

  // PENGATURAN ASLI: Jam 8 Malam (20:00) setiap hari
  static tz.TZDateTime _nextInstanceOf8PM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    // Setel jadwal ke jam 20:00 hari ini
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0); 
    
    // Jika jam 20:00 hari ini sudah terlewat, lemparkan jadwal ke besoknya
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}