import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_tech_app/views/controller/HeartDiseaseService2.dart';
import 'package:pro_tech_app/views/screens/check/ResultScreen2.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BasicHealthFormController extends GetxController {
  final selectedGender = ''.obs;
  final isLoading = false.obs;
  // Age
  final age = 0.obs;
  final ageCategory = ''.obs;

  // BMI
  final Rx<double> bmi = 25.0.obs;
  final bmiRange = (15.0, 50.0);
  final RxBool showBMIError = false.obs;

  // Lifestyle
  final smoking = false.obs;
  final alcoholDrinking = false.obs;

  // Medical History
  final stroke = false.obs;
  final diffWalking = false.obs;
  final asthma = false.obs;
  final kidneyDisease = false.obs;
  final skinCancer = false.obs;
  final Diabetic = false.obs;

  // Physical & Mental Health
  final Rx<double> physicalHealth = 0.0.obs;
  final physicalHealthRange = (0.0, 30.0);
  final RxBool showPhysicalHealthError = false.obs;

  final Rx<double> mentalHealth = 0.0.obs;
  final mentalHealthRange = (0.0, 30.0);
  final RxBool showMentalHealthError = false.obs;

  final Rx<double> sleepTime = 7.0.obs;
  final sleepTimeRange = (0.0, 24.0);
  final RxBool showSleepTimeError = false.obs;

  // Demographics
  final selectedRace = ''.obs;

  final physicalActivity = false.obs;
  final genHealth = ''.obs;

  // Options for dropdowns
  static Map<String, String> get healthStatusOptions => {
        'Excellent': 'Rất tốt',
        'Very good': 'Tốt',
        'Good': 'Khá',
        'Fair': 'Trung bình',
        'Poor': 'Yếu',
      };

  static Map<String, String> get diabeticOptions => {
        'No': 'Không',
        'Yes': 'Có',
        'No, borderline diabetes': 'Tiền tiểu đường',
        'Yes (during pregnancy)': 'Khi mang thai',
      };

  static Map<String, String> get raceOptions => {
        'White': 'Da trắng',
        'Black': 'Da đen',
        'Asian': 'Châu Á',
        'American Indian/Alaskan Native': 'Thổ dân Mỹ/Alaska',
        'Other': 'Khác',
      };

  // Xác định nhóm tuổi từ giá trị `age`
  void setAge(int value) {
    age.value = value;
    setAgeCategory(value);
  }

  void setAgeCategory(int age) {
    if (age >= 18 && age <= 24) {
      ageCategory.value = '18-24';
    } else if (age >= 25 && age <= 29) {
      ageCategory.value = '25-29';
    } else if (age >= 30 && age <= 34) {
      ageCategory.value = '30-34';
    } else if (age >= 35 && age <= 39) {
      ageCategory.value = '35-39';
    } else if (age >= 40 && age <= 44) {
      ageCategory.value = '40-44';
    } else if (age >= 45 && age <= 49) {
      ageCategory.value = '45-49';
    } else if (age >= 50 && age <= 54) {
      ageCategory.value = '50-54';
    } else if (age >= 55 && age <= 59) {
      ageCategory.value = '55-59';
    } else if (age >= 60 && age <= 64) {
      ageCategory.value = '60-64';
    } else if (age >= 65 && age <= 69) {
      ageCategory.value = '65-69';
    } else if (age >= 70 && age <= 74) {
      ageCategory.value = '70-74';
    } else if (age >= 75 && age <= 79) {
      ageCategory.value = '75-79';
    } else if (age >= 80) {
      ageCategory.value = '80 or older';
    }
  }

  // Validate numeric inputs
  bool validateNumericInput(double value, double min, double max) {
    return value >= min && value <= max;
  }

  // Prepare data for ML model
  Map<String, dynamic> prepareDataForModel() {
    return {
      'BMI': bmi.value,
      'Smoking': smoking.value ? 1 : 0,
      'AlcoholDrinking': alcoholDrinking.value ? 1 : 0,
      'Stroke': stroke.value ? 1 : 0,
      'PhysicalHealth': physicalHealth.value,
      'MentalHealth': mentalHealth.value,
      'DiffWalking': diffWalking.value ? 1 : 0,
      'Sex': age.value >= 18 ? 1 : 0, // Update logic for sex if needed
      'AgeCategory': ageCategory.value,
      'Race': selectedRace.value,
      'Diabetic': Diabetic.value ? 1 : 0,
      'PhysicalActivity': physicalActivity.value ? 1 : 0,
      'GenHealth': _mapGenHealthToInt(genHealth.value),
      'SleepTime': sleepTime.value,
      'Asthma': asthma.value ? 1 : 0,
      'KidneyDisease': kidneyDisease.value ? 1 : 0,
      'SkinCancer': skinCancer.value ? 1 : 0,
    };
  }

  // Validation and submission
  bool validateAndSubmit() {
    bool isValid = true;

    // Validate BMI
    if (!validateNumericInput(bmi.value, bmiRange.$1, bmiRange.$2)) {
      showBMIError.value = true;
      isValid = false;
    }

    // Validate Physical Health
    if (!validateNumericInput(
        physicalHealth.value, physicalHealthRange.$1, physicalHealthRange.$2)) {
      showPhysicalHealthError.value = true;
      isValid = false;
    }

    // Validate Mental Health
    if (!validateNumericInput(
        mentalHealth.value, mentalHealthRange.$1, mentalHealthRange.$2)) {
      showMentalHealthError.value = true;
      isValid = false;
    }

    // Validate Sleep Time
    if (!validateNumericInput(
        sleepTime.value, sleepTimeRange.$1, sleepTimeRange.$2)) {
      showSleepTimeError.value = true;
      isValid = false;
    }

    // Validate required fields
    if (selectedRace.value.isEmpty || genHealth.value.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng điền đầy đủ thông tin',
        backgroundColor: Colors.red[300],
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      isValid = false;
    }

    return isValid;
  }

  // Reset form
  void resetForm() {
    bmi.value = 25.0;
    smoking.value = false;
    alcoholDrinking.value = false;
    stroke.value = false;
    physicalHealth.value = 0.0;
    mentalHealth.value = 0.0;
    diffWalking.value = false;
    physicalActivity.value = false;
    genHealth.value = '';
    sleepTime.value = 7.0;
    asthma.value = false;
    kidneyDisease.value = false;
    skinCancer.value = false;
    selectedRace.value = '';
    Diabetic.value = false;
    showBMIError.value = false;
    showPhysicalHealthError.value = false;
    showMentalHealthError.value = false;
    showSleepTimeError.value = false;
  }

  Future<void> submitForm() async {
    if (!validateAndSubmit()) return;
    if (_mapGenHealthToInt(genHealth.value) == -1) {
      Get.snackbar(
        'Lỗi',
        'Tình trạng sức khỏe không hợp lệ',
        backgroundColor: Colors.red[300],
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_mapAgeCategoryToInt(ageCategory.value) == -1) {
      Get.snackbar(
        'Lỗi',
        'Nhóm tuổi không hợp lệ',
        backgroundColor: Colors.red[300],
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final heartDiseaseService = HeartDiseaseService2();

    try {
      // Hiển thị dialog loading thay vì chuyển màn hình
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

      final result = await heartDiseaseService.predictHeartDisease(
        bmi: bmi.value,
        smoking: smoking.value ? 1 : 0,
        alcoholDrinking: alcoholDrinking.value ? 1 : 0,
        stroke: stroke.value ? 1 : 0,
        physicalHealth: physicalHealth.value,
        mentalHealth: mentalHealth.value,
        diffWalking: diffWalking.value ? 1 : 0,
        sex: selectedGender.value == 'Male' ? 1 : 0,
        ageCategory: _mapAgeCategoryToInt(ageCategory.value),
        race: _mapRaceToInt(selectedRace.value),
        diabetic: Diabetic.value ? 1 : 0,
        physicalActivity: physicalActivity.value ? 1 : 0,
        genHealth: _mapGenHealthToInt(genHealth.value),
        sleepTime: sleepTime.value,
        asthma: asthma.value ? 1 : 0,
        kidneyDisease: kidneyDisease.value ? 1 : 0,
        skinCancer: skinCancer.value ? 1 : 0,
      );

      // Đóng dialog loading
      Get.back();

      // Nếu có kết quả hợp lệ, chuyển đến màn hình kết quả
      if (result.containsKey('risk_level') &&
          result.containsKey('risk_probability')) {
        Get.to(() => ResultScreen2(result: result));
      } else {
        throw Exception('Kết quả phân tích không hợp lệ');
      }
    } catch (e) {
      // Đóng dialog loading nếu đang hiển thị
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Hiển thị thông báo lỗi
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

  int _mapAgeCategoryToInt(String ageCategory) {
    const mapping = {
      '18-24': 0,
      '25-29': 1,
      '30-34': 2,
      '35-39': 3,
      '40-44': 4,
      '45-49': 5,
      '50-54': 6,
      '55-59': 7,
      '60-64': 8,
      '65-69': 9,
      '70-74': 10,
      '75-79': 11,
      '80 or older': 12
    };

    return mapping[ageCategory] ?? -1; // -1 cho các giá trị không xác định
  }

  int _mapRaceToInt(String race) {
    switch (race) {
      case 'White':
        return 0;
      case 'Black':
        return 1;
      case 'Asian':
        return 2;
      case 'American Indian/Alaskan Native':
        return 3;
      case 'Other':
        return 4;
      default:
        return 5;
    }
  }

  int _mapGenHealthToInt(String genHealth) {
    switch (genHealth) {
      case 'Excellent':
        return 4;
      case 'Very good':
        return 3;
      case 'Good':
        return 2;
      case 'Fair':
        return 1;
      case 'Poor':
        return 0;
      default:
        return -1;
    }
  }

  @override
  void onInit() {
    super.onInit();
    resetForm();

    // Lấy arguments từ màn hình trước
    final arguments = Get.arguments;
    if (arguments != null) {
      age.value = arguments['age'] ?? 0;
      ageCategory.value = arguments['ageCategory'] ?? '';
      // Nếu 'selectedGender' được truyền từ màn hình trước
      if (arguments.containsKey('selectedGender')) {
        selectedGender.value = arguments['selectedGender'];
      }
    }
  }
}
