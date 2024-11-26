import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pro_tech_app/views/controller/HeartDiseaseService1.dart';
import 'package:pro_tech_app/views/screens/check/result_screen.dart';

class DetailedHealthFormController extends GetxController {
  final age = 0.0.obs;
  final selectedGender = ''.obs;
  @override
  void onInit() {
    super.onInit();
    // Get arguments from previous screen
    final args = Get.arguments as Map<String, dynamic>;
    age.value = (args['age'] ?? 18).toDouble();
    selectedGender.value = args['gender'] ?? '';
  }

  // Chest Pain Type
  var chestPainType = ''.obs;

  // Basic Health Metrics
  var restingBP = 120.0.obs;
  var cholesterol = 200.0.obs;

  // Advanced Metrics
  var maxHeartRate = 150.0.obs;
  var oldpeak = 0.0.obs;

  // Checkboxes
  var fastingBS = false.obs;
  var exerciseAngina = false.obs;

  // Dropdowns
  var restingECG = ''.obs;
  var stSlope = ''.obs;

  // Validation flags
  var showRestingBPError = false.obs;
  var showCholesterolError = false.obs;
  var showMaxHeartRateError = false.obs;
  var showOldpeakError = false.obs;

  // Range limits
  final restingBPRange = (80.0, 200.0);
  final cholesterolRange = (100.0, 500.0);
  final maxHeartRateRange = (50.0, 220.0);
  final oldpeakRange = (0.0, 6.0);

  // Validation methods
  String? validateRestingBP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập huyết áp';
    }
    final bp = int.tryParse(value);
    if (bp == null || bp < restingBPRange.$1 || bp > restingBPRange.$2) {
      return 'Huyết áp phải từ ${restingBPRange.$1.toInt()} đến ${restingBPRange.$2.toInt()}';
    }
    return null;
  }

  String? validateCholesterol(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập chỉ số cholesterol';
    }
    final chol = int.tryParse(value);
    if (chol == null ||
        chol < cholesterolRange.$1 ||
        chol > cholesterolRange.$2) {
      return 'Cholesterol phải từ ${cholesterolRange.$1.toInt()} đến ${cholesterolRange.$2.toInt()}';
    }
    return null;
  }

  String? validateMaxHeartRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập nhịp tim';
    }
    final hr = int.tryParse(value);
    if (hr == null || hr < maxHeartRateRange.$1 || hr > maxHeartRateRange.$2) {
      return 'Nhịp tim phải từ ${maxHeartRateRange.$1.toInt()} đến ${maxHeartRateRange.$2.toInt()}';
    }
    return null;
  }

  String? validateOldpeak(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập ST Depression';
    }
    final peak = double.tryParse(value);
    if (peak == null || peak < oldpeakRange.$1 || peak > oldpeakRange.$2) {
      return 'ST Depression phải từ ${oldpeakRange.$1} đến ${oldpeakRange.$2}';
    }
    return null;
  }

  void showWarningDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Warning',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Close button
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Pro-Tech is based on the SCORE2 and SCORE2-OP Risk Charts, '
                'which evaluate CVD risk for patients between 40 and 89 years of age, '
                'with a systolic blood pressure between 100 - 200 mmHg and a '
                'non-HDL cholesterol between 3 and 6.9 mmol/L (115 - 266 mg/dL). '
                'Please note that patients with examination data over these value '
                'range are automatically at higher risk.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            ),
            // Cancel button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool validateAndSubmit() {
    bool isValid = true;

    // Validate RestingBP
    if (restingBP.value < restingBPRange.$1 ||
        restingBP.value > restingBPRange.$2) {
      showRestingBPError.value = true;
      isValid = false;
    } else {
      showRestingBPError.value = false;
    }

    // Validate Cholesterol
    if (cholesterol.value < cholesterolRange.$1 ||
        cholesterol.value > cholesterolRange.$2) {
      showCholesterolError.value = true;
      isValid = false;
    } else {
      showCholesterolError.value = false;
    }

    // Validate Max Heart Rate
    if (maxHeartRate.value < maxHeartRateRange.$1 ||
        maxHeartRate.value > maxHeartRateRange.$2) {
      showMaxHeartRateError.value = true;
      isValid = false;
    } else {
      showMaxHeartRateError.value = false;
    }

    // Validate Oldpeak
    if (oldpeak.value < oldpeakRange.$1 || oldpeak.value > oldpeakRange.$2) {
      showOldpeakError.value = true;
      isValid = false;
    } else {
      showOldpeakError.value = false;
    }

    // Validate required fields (restingECG, chestPainType, stSlope)
    if (restingECG.value.isEmpty ||
        chestPainType.value.isEmpty ||
        stSlope.value.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng điền đầy đủ thông tin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isValid = false;
    }

    return isValid;
  }

  Future<void> submitForm() async {
    if (!validateAndSubmit()) return;

    try {
      // Show loading dialog with custom UI
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false, // Prevent closing by back button
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpinKitFadingCircle(
                      color: Colors.red[900],
                      size: 50.0,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Đang phân tích dữ liệu...',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Vui lòng đợi trong giây lát',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final heartDiseaseService = HeartDiseaseService1();
      final result = await heartDiseaseService.predictHeartDisease(
        age: age.value,
        sex: selectedGender.value == 'Male' ? 1 : 0,
        chestPainType: _mapChestPainTypeToInt(chestPainType.value),
        restingBP: restingBP.value,
        cholesterol: cholesterol.value,
        restingECG: _mapRestingECGToInt(restingECG.value),
        maxHR: maxHeartRate.value,
        exerciseAngina: exerciseAngina.value ? 1 : 0,
        oldpeak: oldpeak.value,
        stSlope: _mapSTSlopeToInt(stSlope.value),
      );

      // Close loading dialog
      Get.back();

      // Navigate to result screen if valid
      if (result.containsKey('prediction') &&
          result.containsKey('probability')) {
        Get.to(() => ResultScreen1(result: result));
      } else {
        throw Exception('Kết quả phân tích không hợp lệ');
      }
    } catch (e) {
      // Close loading dialog if it's showing
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Lỗi',
        e.toString().contains('timeout')
            ? 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng và thử lại.'
            : 'Có lỗi xảy ra: ${e.toString()}',
        backgroundColor: Colors.red[300],
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  // Helper methods for mapping values
  int _mapChestPainTypeToInt(String value) {
    switch (value) {
      case 'TA':
        return 0; // typical angina
      case 'ATA':
        return 1; // atypical angina
      case 'NAP':
        return 2; // non-anginal pain
      case 'ASY':
        return 3; // asymptomatic
      default:
        return 0;
    }
  }

  int _mapRestingECGToInt(String value) {
    switch (value) {
      case 'Normal':
        return 0; // normal
      case 'ST':
        return 1; // st-t wave abnormality
      case 'LVH':
        return 2; // left ventricular hypertrophy
      default:
        return 0;
    }
  }

  int _mapSTSlopeToInt(String value) {
    switch (value) {
      case 'Up':
        return 0; // upsloping
      case 'Flat':
        return 1; // flat
      case 'Down':
        return 2; // downsloping
      default:
        return 0;
    }
  }
}
