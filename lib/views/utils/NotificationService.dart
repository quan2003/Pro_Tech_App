import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:workmanager/workmanager.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> initNotification() async {
    print("Initializing NotificationService");
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    await _initializeWorkManager();
    await _rescheduleNotificationsOnAppStart();
    await setupFirebaseMessaging();
    print("NotificationService initialization completed");
  }

  Future<void> showImmediateNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Thông báo tức thì',
      'Đây là một thông báo test',
      platformChannelSpecifics,
    );
  }

  Future<void> _initializeLocalNotifications() async {
    print("Initializing local notifications");
    try {
      tz.initializeTimeZones();
      String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          print(
              "Received iOS local notification: id=$id, title=$title, body=$body, payload=$payload");
        },
      );
      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
          print('Notification tapped: ${response.payload}');
          // Handle notification tap here
        },
      );

      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          final bool? granted =
              await androidImplementation.requestNotificationsPermission();
          print('Android notification permission granted: $granted');
        } else {
          print('Unable to resolve Android implementation');
        }
      }
      print("Local notifications initialized successfully");
    } catch (e) {
      print('Error initializing local notifications: $e');
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    print("Initializing Firebase Messaging");
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.notification?.title}');
      if (message.notification != null) {
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.notification?.title}');
      if (message.notification != null) {
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("Handling initial message: ${initialMessage.messageId}");
      _handleMessage(initialMessage);
    }

    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
    print("Firebase Messaging initialized successfully");
  }

  Future<void> showNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    print("Attempting to schedule notification:");
    print("ID: $id");
    print("Title: $title");
    print("Body: $body");
    print("Scheduled Date: $scheduledDate");
    try {
      final tz.TZDateTime scheduledTZDate =
          tz.TZDateTime.from(scheduledDate, tz.local);
      print("Scheduled TZ Date: $scheduledTZDate");
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel',
            'Medication Reminders',
            channelDescription: 'Reminders for taking medication',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableLights: true,
            enableVibration: true,
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print("Notification scheduled successfully");
      print('Notification scheduled for $scheduledDate');
      await _saveNotification(id, title, body, scheduledDate);
    } catch (e) {
      print('Error scheduling notification: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _printSavedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];
    print("Saved notifications:");
    for (var notification in notifications) {
      print(notification);
    }
  }

  Future<void> _saveNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    print(
        "Saving notification: id=$id, title=$title, body=$body, scheduledDate=$scheduledDate");
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];
    notifications.add(jsonEncode({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toIso8601String(),
    }));
    await prefs.setStringList('notifications', notifications);
    print("Notification saved successfully");
  }

  Future<void> rescheduleNotifications() async {
    print("Rescheduling notifications");
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];
    for (final notificationJson in notifications) {
      final notification = jsonDecode(notificationJson);
      final scheduledDate = DateTime.parse(notification['scheduledDate']);
      if (scheduledDate.isAfter(DateTime.now())) {
        await showNotification(
          notification['id'],
          notification['title'],
          notification['body'],
          scheduledDate,
        );
      }
    }
    print("Notifications rescheduled successfully");
  }

  Future<void> _rescheduleNotificationsOnAppStart() async {
    print("Rescheduling notifications on app start");
    await rescheduleNotifications();
    await rescheduleMedicationReminders();
  }

  void _handleMessage(RemoteMessage message) {
    print("Received message: ${message.messageId}");
    print(
        "Notification: ${message.notification?.title}, ${message.notification?.body}");
    print("Data: ${message.data}");

    if (message.notification != null) {
      if (message.data.containsKey('scheduledDate')) {
        DateTime scheduledDate = DateTime.parse(message.data['scheduledDate']);
        showNotification(
          message.hashCode,
          message.notification!.title ?? '',
          message.notification!.body ?? '',
          scheduledDate,
        );
      } else {
        showNotification(
          message.hashCode,
          message.notification!.title ?? '',
          message.notification!.body ?? '',
          DateTime.now(),
        );
      }
    }
  }

  Future<void> _initializeWorkManager() async {
    print("Initializing WorkManager");
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    await Workmanager().registerPeriodicTask(
      "rescheduleNotifications",
      "rescheduleNotifications",
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
    print("WorkManager initialized successfully");
  }

  Future<void> setupFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a foreground message: ${message.notification?.title}");
      handleBackgroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("App opened from notification: ${message.notification?.title}");
      handleBackgroundMessage(message);
    });

    // Handle when the app is launched from a terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleBackgroundMessage(initialMessage);
    }
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
    if (message.notification != null &&
        message.data.containsKey('scheduledDate')) {
      DateTime scheduledDate = DateTime.parse(message.data['scheduledDate']);
      await showNotification(
        message.hashCode,
        message.notification!.title ?? '',
        message.notification!.body ?? '',
        scheduledDate,
      );
    }
  }

  // Methods for medication reminders
  Future<void> scheduleMedicationReminder(
      int id, String medicineName, DateTime scheduledDate) async {
    print(
        "Scheduling medication reminder: id=$id, medicine=$medicineName, scheduledDate=$scheduledDate");
    try {
      await showNotification(
        id,
        "Nhắc nhở uống thuốc",
        "Đã đến giờ uống $medicineName!",
        scheduledDate,
      );
      print('Medication reminder scheduled for $scheduledDate');
      await _saveMedicationReminder(id, medicineName, scheduledDate);
    } catch (e) {
      print('Error scheduling medication reminder: $e');
    }
  }

  Future<void> _saveMedicationReminder(
      int id, String medicineName, DateTime scheduledDate) async {
    print(
        "Saving medication reminder: id=$id, medicine=$medicineName, scheduledDate=$scheduledDate");
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList('medicationReminders') ?? [];
    reminders.add(jsonEncode({
      'id': id,
      'medicineName': medicineName,
      'scheduledDate': scheduledDate.toIso8601String(),
    }));
    await prefs.setStringList('medicationReminders', reminders);
    print("Medication reminder saved successfully");
  }

  Future<void> rescheduleMedicationReminders() async {
    print("Rescheduling medication reminders");
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList('medicationReminders') ?? [];
    for (final reminderJson in reminders) {
      final reminder = jsonDecode(reminderJson);
      final scheduledDate = DateTime.parse(reminder['scheduledDate']);
      if (scheduledDate.isAfter(DateTime.now())) {
        await scheduleMedicationReminder(
          reminder['id'],
          reminder['medicineName'],
          scheduledDate,
        );
      }
    }
    print("Medication reminders rescheduled successfully");
  }

  Future<void> cancelMedicationReminder(int id) async {
    print("Cancelling medication reminder with id: $id");
    await flutterLocalNotificationsPlugin.cancel(id);
    await _removeMedicationReminder(id);
    print("Medication reminder cancelled successfully");
  }

  Future<void> _removeMedicationReminder(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList('medicationReminders') ?? [];
    reminders.removeWhere((reminderJson) {
      final reminder = jsonDecode(reminderJson);
      return reminder['id'] == id;
    });
    await prefs.setStringList('medicationReminders', reminders);
    print("Medication reminder removed from storage");
  }

  Future<List<Map<String, dynamic>>> getScheduledMedicationReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList('medicationReminders') ?? [];
    return reminders
        .map((reminderJson) => jsonDecode(reminderJson) as Map<String, dynamic>)
        .toList();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  final notificationService = NotificationService();
  await notificationService.handleBackgroundMessage(message);
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background task started: $task at ${DateTime.now()}");
    if (task == "rescheduleNotifications") {
      print("Rescheduling notifications");
      final notificationService = NotificationService();
      await notificationService.rescheduleNotifications();
      await notificationService.rescheduleMedicationReminders();
    }
    return Future.value(true);
  });
}
