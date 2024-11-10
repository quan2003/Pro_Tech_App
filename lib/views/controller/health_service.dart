import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:io';
import 'dart:async';

class HealthService {
  final Health _health = Health();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    try {
      await _requestBasicPermissions();
      bool authorized = await requestAuthorization();
      _isInitialized = authorized;
      return authorized;
    } catch (e) {
      print("Error during initialization: $e");
      return false;
    }
  }

  Future<void> _requestBasicPermissions() async {
    if (Platform.isAndroid) {
      await Permission.activityRecognition.request();
      await Permission.sensors.request();

      if (await Permission.sensors.isGranted) {
        print("Sensors permission granted");
      }
    }
  }

  Future<void> openHealthConnectSettings() async {
    if (!Platform.isAndroid) {
      print("Health Connect is only available on Android");
      return;
    }

    try {
      const intent = AndroidIntent(
        action: 'android.health.connect.action.HEALTH_CONNECT_SETTINGS',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      try {
        await intent.launch();
        return;
      } catch (e) {
        print("Failed to open Health Connect directly: $e");
      }

      const fallbackIntent = AndroidIntent(
        action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
        data: 'package:com.google.android.apps.healthdata',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      try {
        await fallbackIntent.launch();
        return;
      } catch (e) {
        print("Failed to open app settings: $e");
      }

      const playStoreIntent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: 'market://details?id=com.google.android.apps.healthdata',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await playStoreIntent.launch();
    } catch (e) {
      print("Failed to open any settings: $e");
    }
  }

  Future<bool> requestAuthorization() async {
    try {
      final types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.BLOOD_GLUCOSE,
        HealthDataType.WEIGHT,
        HealthDataType.HEIGHT,
        HealthDataType.BLOOD_OXYGEN,
        HealthDataType.BODY_TEMPERATURE,
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_AWAKE,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_REM,
        HealthDataType.SLEEP_SESSION
      ];

      bool? hasPermissions = await _health.hasPermissions(types);

      if (hasPermissions != true) {
        try {
          bool authorized = await _health.requestAuthorization(types);
          print("Health Connect authorization result: $authorized");

          if (!authorized) {
            await openHealthConnectSettings();
            await Future.delayed(const Duration(seconds: 2));
            authorized = await _health.requestAuthorization(types);
          }

          return authorized;
        } catch (e) {
          print("Error requesting Health Connect authorization: $e");
          await openHealthConnectSettings();
          return false;
        }
      }
      return true;
    } catch (e) {
      print("Error in requestAuthorization: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchAllHealthData() async {
    if (!_isInitialized && !await initialize()) {
      print("Health Service not initialized");
      return {};
    }

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    Map<String, dynamic> result = {};

    try {
      // Get today's steps
      result['steps'] = await getTodaySteps();
      print("Today's steps: ${result['steps']}");

      // Fetch 30-day steps data
      List<int> dailySteps = [];
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

        final daySteps =
            await _health.getTotalStepsInInterval(startOfDay, endOfDay);
        if (daySteps != null) {
          dailySteps.add(daySteps);
        }
      }

      // Calculate average steps over the past 30 days
      int averageSteps = 0;
      if (dailySteps.isNotEmpty) {
        averageSteps = dailySteps.reduce((a, b) => a + b) ~/ dailySteps.length;
      }

      result['steps_average'] = averageSteps;
      result['steps_goal'] = 10000; // Make this configurable if needed
      result['daily_steps'] = dailySteps;

      // Fetch sleep data
      await _fetchSleepData(result, yesterday, now);

      // Fetch other health data (e.g., heart rate, blood pressure)
      final healthMetrics = {
        HealthDataType.HEART_RATE: ['heart_rate', 'bpm'],
        HealthDataType.BLOOD_GLUCOSE: ['blood_glucose', 'mg/dL'],
        HealthDataType.BLOOD_OXYGEN: ['blood_oxygen', '%'],
        HealthDataType.WEIGHT: ['weight', 'kg'],
        HealthDataType.HEIGHT: ['height', 'cm'],
        HealthDataType.BODY_TEMPERATURE: ['temperature', '°C'],
      };

      for (var entry in healthMetrics.entries) {
        await _fetchHealthDataPoint(
          result,
          entry.value[0],
          entry.key,
          entry.value[1],
          yesterday,
          now,
        );
      }

      print("Final health data result: $result");
      return result;
    } catch (e) {
      print("Error in fetchAllHealthData: $e");
      return result;
    }
  }

  Future<void> _fetchSleepData(
    Map<String, dynamic> result,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // Fetch sleep sessions
      List<HealthDataPoint> sleepSessions =
          await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [
          HealthDataType.SLEEP_SESSION,
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_AWAKE,
          HealthDataType.SLEEP_LIGHT,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_REM
        ],
      );

      if (sleepSessions.isNotEmpty) {
        print("Found ${sleepSessions.length} sleep sessions");

        // Sort by date to get sessions in order
        sleepSessions.sort((a, b) => b.dateTo.compareTo(a.dateTo));

        // Process each sleep session
        for (var session in sleepSessions) {
          print("Sleep session: ${session.typeString}");
          print("From: ${session.dateFrom} to: ${session.dateTo}");
          print("Value: ${session.value}");
        }

        // Calculate total sleep time and quality metrics
        var latestSession = sleepSessions.first;
        Duration sleepDuration =
            latestSession.dateTo.difference(latestSession.dateFrom);

        result['sleep'] = {
          'value': (sleepDuration.inMinutes / 60.0).toStringAsFixed(1),
          'unit': 'hours',
          'start_time': latestSession.dateFrom.toString(),
          'end_time': latestSession.dateTo.toString(),
        };
      } else {
        print("No sleep sessions found");
      }
    } catch (e) {
      print("Error getting sleep data: $e");
    }
  }

  Future<void> _fetchHealthDataPoint(
    Map<String, dynamic> result,
    String key,
    HealthDataType type,
    String unit,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [type],
      );

      if (data.isNotEmpty) {
        data.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        var latest = data.first;
        String value = _extractNumericValue(latest.value.toString());

        result[key] = {
          'value': value,
          'unit': unit,
          'timestamp': latest.dateTo.toString(),
        };
        print("$key data: ${result[key]}");
      }
    } catch (e) {
      print("Error getting data for $key: $e");
    }
  }

  Future<void> _fetchBloodPressure(
    Map<String, dynamic> result,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      var systolicData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
      );
      var diastolicData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
      );

      if (systolicData.isNotEmpty && diastolicData.isNotEmpty) {
        String systolicValue =
            _extractNumericValue(systolicData.first.value.toString());
        String diastolicValue =
            _extractNumericValue(diastolicData.first.value.toString());

        result['blood_pressure'] = {
          'systolic': systolicValue,
          'diastolic': diastolicValue,
          'unit': 'mmHg',
          'timestamp': systolicData.first.dateTo.toString(),
        };
        print("Blood pressure data: ${result['blood_pressure']}");
      }
    } catch (e) {
      print("Error getting blood pressure: $e");
    }
  }

  String _extractNumericValue(String value) {
    if (value.contains("numericValue:")) {
      return value.split("numericValue:")[1].trim();
    }
    return value;
  }

  Future<int?> getTodaySteps() async {
    if (!_isInitialized && !await initialize()) {
      print("Health Service not initialized");
      return null;
    }

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    try {
      return await _health.getTotalStepsInInterval(midnight, now);
    } catch (e) {
      print("Error getting today's steps: $e");
      return null;
    }
  }

  Future<bool> writeHealthData(HealthDataType type, double value) async {
    if (!_isInitialized && !await initialize()) {
      print("Health Service not initialized");
      return false;
    }

    final now = DateTime.now();
    final startTime = now.subtract(const Duration(seconds: 1));

    try {
      return await _health.writeHealthData(
        value: value,
        type: type,
        startTime: startTime,
        endTime: now,
      );
    } catch (e) {
      print("Error writing health data: $e");
      return false;
    }
  }

  Future<bool> writeSleepData(DateTime startTime, DateTime endTime) async {
    if (!_isInitialized && !await initialize()) {
      print("Health Service not initialized");
      return false;
    }

    try {
      // Write sleep session data
      bool success = await _health.writeHealthData(
        value: endTime.difference(startTime).inMinutes.toDouble(),
        type: HealthDataType.SLEEP_ASLEEP,
        startTime: startTime,
        endTime: endTime,
      );

      if (!success) {
        print("Failed to write sleep session data");
        return false;
      }

      print("Successfully wrote sleep data");
      return true;
    } catch (e) {
      print("Error writing sleep data: $e");
      return false;
    }
  }
}
