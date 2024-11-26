// lib/controllers/heart_disease_form_controller.dart

import 'package:get/get.dart';

class HeartDiseaseFormController extends GetxController {
  // Basic Info
  final age = ''.obs;
  final gender = ''.obs;
  final occupation = ''.obs;

  // For heart.csv model
  final chestPainType = ''.obs;
  final restingBP = ''.obs;
  final cholesterol = ''.obs;
  final fastingBS = false.obs;
  final restingECG = ''.obs;
  final maxHR = ''.obs;
  final exerciseAngina = false.obs;
  final oldpeak = 0.0.obs;
  final stSlope = ''.obs;

  // For heart_2020_cleaned model
  final bmi = 0.0.obs;
  final smoking = false.obs;
  final alcoholDrinking = false.obs;
  final stroke = false.obs;
  final physicalHealth = 0.obs;
  final mentalHealth = 0.obs;
  final diffWalking = false.obs;
  final ageCategory = ''.obs;
  final race = ''.obs;
  final diabetic = ''.obs;
  final physicalActivity = false.obs;
  final genHealth = ''.obs;
  final sleepTime = 0.obs;
  final asthma = false.obs;
  final kidneyDisease = false.obs;
  final skinCancer = false.obs;

  // Form state
  final currentStep = 0.obs;
  final hasDetailedInfo = false.obs;

  void nextStep() {
    currentStep.value++;
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> submitDetailedForm() async {
    // TODO: Call API with heart.csv model
  }

  Future<void> submitBasicForm() async {
    // TODO: Call API with heart_2020_cleaned model
  }
}
