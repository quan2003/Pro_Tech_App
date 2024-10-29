import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:io';

class HealthService {
  final Health _health = Health();

  Future<void> initialize() async {
    await requestAuthorization();
  }

  Future<void> openHealthConnectSettings() async {
    if (Platform.isAndroid) {
      try {
        // Thử mở trực tiếp Health Connect
        final intent = AndroidIntent(
          action: 'android.health.connect.action.HEALTH_CONNECT_SETTINGS',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } catch (e) {
        try {
          final fallbackIntent = AndroidIntent(
            action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
            data: 'package:com.google.android.apps.healthdata',
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          );
          await fallbackIntent.launch();
        } catch (e) {
          print("Error opening Health Connect settings: $e");
          final playStoreIntent = AndroidIntent(
            action: 'android.intent.action.VIEW',
            data: 'market://details?id=com.google.android.apps.healthdata',
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          );
          await playStoreIntent.launch();
        }
      }
    } else {
      print("Health Connect chỉ có sẵn trên Android.");
    }
  }

  Future<bool> requestAuthorization() async {
    var activityRecognitionStatus =
        await Permission.activityRecognition.request();
    if (!activityRecognitionStatus.isGranted) {
      print("Quyền activityRecognition chưa được cấp.");
      return false;
    }

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
    ];

    try {
      bool authorized = await _health.requestAuthorization(types);
      print("Health Connect authorization result: $authorized");
      return authorized;
    } catch (e) {
      print("Error requesting authorization: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchAllHealthData() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));
    Map<String, dynamic> result = {};

    try {
      // Lấy số bước chân
      result['steps'] = await getTodaySteps();
      print("Steps data: ${result['steps']}");

      // Lấy nhịp tim
      try {
        List<HealthDataPoint> heartData = await _health.getHealthDataFromTypes(
          startTime: yesterday,
          endTime: now,
          types: [HealthDataType.HEART_RATE],
        );

        if (heartData.isNotEmpty) {
          heartData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
          var latestHeartRate = heartData.first;
          String value = latestHeartRate.value.toString();
          // Xử lý trường hợp "NumericHealthValue - numericValue: 70"
          if (value.contains("numericValue:")) {
            value = value.split("numericValue:")[1].trim();
          }

          result['heart_rate'] = {
            'value': value,
            'unit': 'bpm',
            'timestamp': latestHeartRate.dateTo.toString(),
          };
          print("Heart rate data: ${result['heart_rate']}");
        }
      } catch (e) {
        print("Error getting heart rate: $e");
      }

      // Lấy huyết áp
      try {
        var systolicData = await _health.getHealthDataFromTypes(
          startTime: yesterday,
          endTime: now,
          types: [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
        );
        var diastolicData = await _health.getHealthDataFromTypes(
          startTime: yesterday,
          endTime: now,
          types: [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
        );

        if (systolicData.isNotEmpty && diastolicData.isNotEmpty) {
          String systolicValue = systolicData.first.value.toString();
          String diastolicValue = diastolicData.first.value.toString();

          if (systolicValue.contains("numericValue:")) {
            systolicValue = systolicValue.split("numericValue:")[1].trim();
          }
          if (diastolicValue.contains("numericValue:")) {
            diastolicValue = diastolicValue.split("numericValue:")[1].trim();
          }

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

      // Lấy các dữ liệu khác
      for (var entry in {
        HealthDataType.BLOOD_GLUCOSE: ['blood_glucose', 'mg/dL'],
        HealthDataType.BLOOD_OXYGEN: ['blood_oxygen', '%'],
        HealthDataType.WEIGHT: ['weight', 'kg'],
        HealthDataType.HEIGHT: ['height', 'cm'],
        HealthDataType.BODY_TEMPERATURE: ['temperature', '°C'],
      }.entries) {
        try {
          var data = await _health.getHealthDataFromTypes(
            startTime: yesterday,
            endTime: now,
            types: [entry.key],
          );

          if (data.isNotEmpty) {
            data.sort((a, b) => b.dateTo.compareTo(a.dateTo));
            var latest = data.first;
            String value = latest.value.toString();

            if (value.contains("numericValue:")) {
              value = value.split("numericValue:")[1].trim();
            }

            result[entry.value[0]] = {
              'value': value,
              'unit': entry.value[1],
              'timestamp': latest.dateTo.toString(),
            };
            print("${entry.value[0]} data: ${result[entry.value[0]]}");
          }
        } catch (e) {
          print("Error getting data for ${entry.key}: $e");
        }
      }

      print("Final health data result: $result");
      return result;
    } catch (e) {
      print("Error in fetchAllHealthData: $e");
      return result;
    }
  }

  Future<int?> getTodaySteps() async {
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
      print("Lỗi khi ghi dữ liệu sức khỏe: $e");
      return false;
    }
  }
}
