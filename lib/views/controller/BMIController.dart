import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BMIController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  RxDouble bmiValue = 0.0.obs;
  RxString bmiCategory = ''.obs;
  Rx<Color> bmiColor = Colors.grey.obs;
  
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    isLoading.value = true;
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          double? height = _parseDouble(userData['height']);
          double? weight = _parseDouble(userData['weight']);
          String? heightUnit = userData['heightUnit'] as String?;
          String? weightUnit = userData['weightUnit'] as String?;
          
          if (height != null && weight != null && height > 0 && weight > 0) {
            updateBMI(height, weight, heightUnit ?? 'cm', weightUnit ?? 'kg');
          } else {
            bmiCategory.value = 'Dữ liệu không hợp lệ';
            bmiColor.value = Colors.grey;
          }
        } else {
          bmiCategory.value = 'Không tìm thấy dữ liệu người dùng';
          bmiColor.value = Colors.grey;
        }
      } else {
        bmiCategory.value = 'Chưa đăng nhập';
        bmiColor.value = Colors.grey;
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu: $e');
      bmiCategory.value = 'Lỗi khi lấy dữ liệu';
      bmiColor.value = Colors.grey;
    } finally {
      isLoading.value = false;
    }
  }

  double? _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value);
    } else if (value is double) {
      return value;
    }
    return null;
  }

  void updateBMI(double height, double weight, String heightUnit, String weightUnit) {
    double heightInMeters = convertHeight(height, heightUnit);
    double weightInKg = convertWeight(weight, weightUnit);
    
    double bmi = weightInKg / (heightInMeters * heightInMeters);
    bmiValue.value = double.parse(bmi.toStringAsFixed(1));
    updateCategory(bmi);
  }

  double convertHeight(double height, String unit) {
    switch (unit) {
      case 'cm':
        return height / 100; // Convert cm to meters
      case 'ft':
        return height * 0.3048; // Convert feet to meters
      default:
        return height / 100; // Default to cm
    }
  }

  double convertWeight(double weight, String unit) {
    switch (unit) {
      case 'kg':
        return weight;
      case 'lbs':
        return weight * 0.45359237; // Convert pounds to kg
      case 'st':
        return weight * 6.35029318; // Convert stone to kg
      default:
        return weight; // Default to kg
    }
  }

  void updateCategory(double bmi) {
    if (bmi < 18.5) {
      bmiCategory.value = 'Thiếu cân';
      bmiColor.value = Colors.blue;
    } else if (bmi < 25) {
      bmiCategory.value = 'Bình thường';
      bmiColor.value = Colors.green;
    } else if (bmi < 30) {
      bmiCategory.value = 'Thừa cân';
      bmiColor.value = Colors.orange;
    } else {
      bmiCategory.value = 'Béo phì';
      bmiColor.value = Colors.red;
    }
  }
}