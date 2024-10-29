import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../Routes/AppRoutes.dart';

class HeightInputScreen extends StatefulWidget {
  const HeightInputScreen({super.key});

  @override
  _HeightInputScreenState createState() => _HeightInputScreenState();
}

class _HeightInputScreenState extends State<HeightInputScreen> {
  double _currentHeight = 165; // Initial height in cm
  bool _isCm = true; // Flag to check the unit

  void _onHeightChanged(double height) {
    setState(() {
      _currentHeight = height;
    });
  }

  void _toggleUnit() {
    setState(() {
      _isCm = !_isCm;
      if (_isCm) {
        // Convert feet to cm when toggling back to cm
        _currentHeight = (_currentHeight * 30.48).roundToDouble();
      } else {
        // Convert cm to feet when toggling to feet
        _currentHeight = (_currentHeight / 30.48).roundToDouble();
      }
    });
  }

  Future<void> _saveHeightToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'height': _currentHeight,
          'unit': _isCm ? 'cm' : 'ft',
        }, SetOptions(merge: true));
        Get.snackbar('Thành công', 'Chiều cao của bạn đã được lưu.');
      } catch (e) {
        print('Lỗi khi cập nhật chiều cao: $e');
        Get.snackbar('Lỗi', 'Không thể lưu chiều cao. Vui lòng thử lại.');
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
                'Chiều cao của tôi là',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thông tin rất quan trọng để tính toán sự trao đổi chất cơ bản của bạn',
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
                        _currentHeight = (_currentHeight - 1).clamp(0, 300);
                      });
                    },
                  ),
                  Text(
                    _currentHeight.toStringAsFixed(0),
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
                        _currentHeight = (_currentHeight + 1).clamp(0, 300);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ToggleButtons(
                isSelected: [_isCm, !_isCm],
                onPressed: (index) {
                  _toggleUnit();
                },
                fillColor: Colors.grey[300],
                selectedColor: Colors.black,
                borderRadius: BorderRadius.circular(20),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('cm'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('ft'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Slider(
                value: _currentHeight,
                min: _isCm ? 50 : 1.6, // Minimum value in cm or feet
                max: _isCm ? 250 : 8.2, // Maximum value in cm or feet
                divisions: _isCm ? 200 : 130,
                label: _currentHeight.toStringAsFixed(0),
                activeColor: Colors.pinkAccent,
                onChanged: _onHeightChanged,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await _saveHeightToFirestore();
                  Get.toNamed(AppRoutes.WEIGHT_INPUT_SCREEN);
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
