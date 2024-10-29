import 'package:flutter/material.dart'; // To use Color class

class BMIModel {
  double? height; // Height in meters
  double? weight; // Weight in kilograms

  BMIModel({this.height, this.weight});

  double? calculateBMI() {
    if (height == null || weight == null || height! <= 0) {
      return null;
    }
    return weight! / (height! * height!);
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  Color getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}
