import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> initializeWorkmanager() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
}

Future<void> registerPeriodicTasks() async {
  await Workmanager().registerPeriodicTask(
    "running-reminder",
    "runningReminder",
    frequency: const Duration(days: 1),
    initialDelay: const Duration(minutes: 1),
    constraints: Constraints(
      networkType: NetworkType.not_required,
    ),
  );
  await Workmanager().registerPeriodicTask(
    "step-count-reminder",
    "stepCountReminder",
    frequency: const Duration(days: 1),
    initialDelay: const Duration(minutes: 2),
    constraints: Constraints(
      networkType: NetworkType.not_required,
    ),
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('Background task started: $task');
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    switch (task) {
      case 'runningReminder':
        await _showRunningReminder(flutterLocalNotificationsPlugin);
        break;
      case 'stepCountReminder':
        await _showStepCountReminder(flutterLocalNotificationsPlugin);
        break;
      default:
        print('Unknown task: $task');
    }
    print('Background task completed: $task');
    return Future.value(true);
  });
}

Future<void> _showRunningReminder(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  print('Showing running reminder notification');
  await flutterLocalNotificationsPlugin.show(
    0,
    'Nhắc nhở chạy bộ',
    'Đã đến giờ chạy bộ buổi sáng rồi!',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'running_reminder_channel',
        'Running Reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

Future<void> _showStepCountReminder(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  print('Showing step count reminder notification');
  await flutterLocalNotificationsPlugin.show(
    1,
    'Thống kê bước chạy',
    'Hãy kiểm tra số bước chạy của bạn hôm nay!',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'step_count_channel',
        'Step Count Reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}