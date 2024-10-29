import 'package:workmanager/workmanager.dart';
// import 'package:your_app_name/utils/NotificationService.dart';

import 'NotificationService.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'rescheduleNotifications':
        await NotificationService().rescheduleNotifications();
        break;
    }
    return Future.value(true);
  });
}

Future<void> initializeBackgroundService() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  await Workmanager().registerPeriodicTask(
    'rescheduleNotifications',
    'rescheduleNotifications',
    frequency: const Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.not_required,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
  );
}
