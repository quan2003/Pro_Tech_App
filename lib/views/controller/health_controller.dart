// health_controller.dart
import 'package:get/get.dart';

import 'health_service.dart';

class HealthController extends GetxController {
  final HealthService _healthService = HealthService();
  final RxInt steps = 0.obs;
  final RxMap<String, dynamic> sleepData = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHealthData();
  }

  Future<void> fetchHealthData() async {
    isLoading.value = true;
    try {
      // Khởi tạo HealthService nếu cần
      final healthData = await _healthService.fetchAllHealthData();

      // Cập nhật số bước
      final todaySteps = await _healthService.getTodaySteps();
      steps.value = todaySteps ?? 0;

      // Cập nhật dữ liệu giấc ngủ
      if (healthData.containsKey('sleep')) {
        sleepData.value = healthData['sleep'];
      }
    } catch (e) {
      print("Error fetching health data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String get stepCountString {
    if (isLoading.value) return "Đang tải...";
    return "${steps.value} bước";
  }

  String get sleepDurationString {
    if (isLoading.value) return "Đang tải...";
    if (sleepData.isEmpty) return "Chưa có dữ liệu";

    final value = double.tryParse(sleepData['value']?.toString() ?? '0') ?? 0;
    final hours = value.floor();
    final minutes = ((value - hours) * 60).round();

    return "${hours}h ${minutes}m";
  }

  String get sleepQualityString {
    if (sleepData.isEmpty) return '';
    final startTime = DateTime.tryParse(sleepData['start_time'] ?? '');
    final endTime = DateTime.tryParse(sleepData['end_time'] ?? '');

    if (startTime == null || endTime == null) return '';

    return 'Từ ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} đến ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
  }
}
