import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../Routes/AppRoutes.dart';

class WeightGoalScreen extends StatefulWidget {
  const WeightGoalScreen({super.key});

  @override
  _WeightGoalScreenState createState() => _WeightGoalScreenState();
}

class _WeightGoalScreenState extends State<WeightGoalScreen> {
  // Variables for weight and unit
  double _currentWeight = 62;
  String _selectedUnit = 'kg';

  // Method to save weight goal to Firebase Firestore
  Future<void> _saveWeightGoalToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'weightGoal': {
            'targetWeight': _currentWeight,
            'unit': _selectedUnit,
          },
        }, SetOptions(merge: true));
        Get.snackbar('Thông báo', 'Cân nặng của bạn đã được lưu.');
      } catch (e) {
        print('Lỗi khi lưu cân nặng: $e');
        Get.snackbar('Lỗi', 'Không thể lưu cân nặng. Vui lòng thử lại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Mục tiêu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chọn cân nặng mong muốn',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Minus button
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.pinkAccent),
                    onPressed: () {
                      setState(() {
                        if (_currentWeight > 1) _currentWeight--;
                      });
                    },
                    iconSize: 40,
                  ),
                  const SizedBox(width: 20),
                  // Display current weight
                  Text(
                    _currentWeight.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Plus button
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.pinkAccent),
                    onPressed: () {
                      setState(() {
                        if (_currentWeight < 200) _currentWeight++;
                      });
                    },
                    iconSize: 40,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Unit selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['kg', 'lbs', 'st'].map((unit) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: ChoiceChip(
                      label: Text(unit),
                      selected: _selectedUnit == unit,
                      onSelected: (selected) {
                        setState(() {
                          _selectedUnit = unit;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Weight slider
              Slider(
                value: _currentWeight,
                min: 1,
                max: 200,
                divisions: 199,
                onChanged: (value) {
                  setState(() {
                    _currentWeight = value;
                  });
                },
                activeColor: Colors.pinkAccent,
                inactiveColor: Colors.grey[300],
              ),
              const SizedBox(height: 20),
              // Ideal weight information
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/doctor.png'), // Replace with your asset image
                    radius: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cân nặng lý tưởng của bạn là từ 50.4 đến 67.8 kg.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Continue button
              ElevatedButton(
                onPressed: () async {
                  await _saveWeightGoalToFirestore();
                   Get.toNamed(AppRoutes.WEIGHT_FREQUENCY_SCREEN);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
