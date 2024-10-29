import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../Routes/AppRoutes.dart';

class WeightInputScreen extends StatefulWidget {
  const WeightInputScreen({super.key});

  @override
  _WeightInputScreenState createState() => _WeightInputScreenState();
}

class _WeightInputScreenState extends State<WeightInputScreen> {
  double _currentWeight = 62; // Initial weight
  String _unit = 'kg'; // Default unit

  void _onWeightChanged(double weight) {
    setState(() {
      _currentWeight = weight;
    });
  }

  void _toggleUnit(String unit) {
    setState(() {
      _unit = unit;
      if (unit == 'kg') {
        _currentWeight = (_currentWeight / 2.205)
            .clamp(30.0, 200.0)
            .roundToDouble(); // Convert lbs to kg, clamp value
      } else if (unit == 'lbs') {
        _currentWeight = (_currentWeight * 2.205)
            .clamp(66.0, 441.0)
            .roundToDouble(); // Convert kg to lbs, clamp value
      } else if (unit == 'st') {
        _currentWeight = (_currentWeight / 6.35)
            .clamp(5.0, 31.0)
            .roundToDouble(); // Convert kg to st, clamp value
      }
    });
  }

  Future<void> _saveWeightToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'weight': _currentWeight,
          'unit': _unit,
        }, SetOptions(merge: true));
        Get.snackbar('Thành công', 'Cân nặng của bạn đã được lưu.');
      } catch (e) {
        print('Lỗi khi cập nhật cân nặng: $e');
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
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.person_outline, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Cân nặng của tôi là',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thông tin rất quan trọng để tính chỉ số khối cơ thể của bạn',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.pinkAccent),
                    onPressed: () {
                      setState(() {
                        _currentWeight = (_currentWeight - 1).clamp(0, 500);
                      });
                    },
                  ),
                  Text(
                    _currentWeight.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.pinkAccent),
                    onPressed: () {
                      setState(() {
                        _currentWeight = (_currentWeight + 1).clamp(0, 500);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ToggleButtons(
                isSelected: [_unit == 'kg', _unit == 'lbs', _unit == 'st'],
                onPressed: (index) {
                  String selectedUnit = ['kg', 'lbs', 'st'][index];
                  _toggleUnit(selectedUnit);
                },
                fillColor: Colors.grey[300],
                selectedColor: Colors.black,
                borderRadius: BorderRadius.circular(20),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('kg'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('lbs'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('st'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Slider(
                value: _currentWeight.clamp(
                  _unit == 'kg' ? 30.0 : (_unit == 'lbs' ? 66.0 : 5.0),
                  _unit == 'kg' ? 200.0 : (_unit == 'lbs' ? 441.0 : 31.0),
                ), // Clamp value within min and max for the current unit
                min: _unit == 'kg'
                    ? 30
                    : (_unit == 'lbs' ? 66 : 5), // Min values for each unit
                max: _unit == 'kg'
                    ? 200
                    : (_unit == 'lbs' ? 441 : 31), // Max values for each unit
                divisions: _unit == 'kg' ? 170 : (_unit == 'lbs' ? 375 : 260),
                label: _currentWeight.toStringAsFixed(0),
                activeColor: Colors.pinkAccent,
                onChanged: _onWeightChanged,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await _saveWeightToFirestore();
                  Get.toNamed(AppRoutes.WELCOME_SCREEN);
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
