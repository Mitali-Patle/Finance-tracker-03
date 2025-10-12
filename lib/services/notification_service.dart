import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        print('Notification tapped: ${details.payload}');
      },
    );

    // Request permissions for Android 13+
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'finance_tracker_channel',
      'Finance Tracker',
      channelDescription: 'Notifications for expense tracking',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule daily budget reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      0, // notification id
      '💰 Budget Check',
      'Don\'t forget to track your expenses today!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription: 'Daily expense tracking reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Budget exceeded notification
  Future<void> showBudgetExceededNotification(double spent, double budget) async {
    await showNotification(
      id: 1,
      title: '⚠️ Budget Exceeded!',
      body: 'You\'ve spent ₹${spent.toStringAsFixed(0)} out of ₹${budget.toStringAsFixed(0)}',
      payload: 'budget_exceeded',
    );
  }

  // Budget warning (80% spent)
  Future<void> showBudgetWarningNotification(double spent, double budget) async {
    final percentage = (spent / budget * 100).toInt();
    await showNotification(
      id: 2,
      title: '⚡ Budget Alert',
      body: 'You\'ve used $percentage% of your monthly budget',
      payload: 'budget_warning',
    );
  }

  // Expense added confirmation
  Future<void> showExpenseAddedNotification(String title, double amount) async {
    await showNotification(
      id: 3,
      title: '✅ Expense Added',
      body: '$title - ₹${amount.toStringAsFixed(0)}',
      payload: 'expense_added',
    );
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
}