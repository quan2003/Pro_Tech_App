import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../Routes/AppRoutes.dart';

class HealthGoalsScreen extends StatefulWidget {
  const HealthGoalsScreen({super.key});

  @override
  _HealthGoalsScreenState createState() => _HealthGoalsScreenState();
}

class _HealthGoalsScreenState extends State<HealthGoalsScreen> {
  // Define the state for each goal's switch
  bool isWeightGoalSelected = false;
  bool isQuitSmokingSelected = false;
  bool isSleepManagementSelected = false;
  bool isExerciseSelected = true;

  // Function to save goals to Firebase Firestore
  Future<void> _saveGoalsToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'healthGoals': {
            'weightGoal': isWeightGoalSelected,
            'quitSmoking': isQuitSmokingSelected,
            'sleepManagement': isSleepManagementSelected,
            'exercise': isExerciseSelected,
          },
        }, SetOptions(merge: true));
        Get.snackbar('Thông báo', 'Mục tiêu của bạn đã được lưu.');
      } catch (e) {
        print('Lỗi khi lưu mục tiêu: $e');
        Get.snackbar('Lỗi', 'Không thể lưu mục tiêu. Vui lòng thử lại.');
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
                'Mục tiêu sức khỏe của bạn?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chọn tất cả lựa chọn phù hợp',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              _buildGoalItem(
                icon: Icons.monitor_weight_outlined,
                title: 'Cân nặng',
                subtitle: 'Giảm / tăng cân',
                isSelected: isWeightGoalSelected,
                onChanged: (value) {
                  setState(() {
                    isWeightGoalSelected = value;
                  });
                },
              ),
              _buildGoalItem(
                icon: Icons.smoke_free,
                title: 'Hút thuốc',
                subtitle: 'Bỏ / giảm hút thuốc',
                isSelected: isQuitSmokingSelected,
                onChanged: (value) {
                  setState(() {
                    isQuitSmokingSelected = value;
                  });
                },
              ),
              _buildGoalItem(
                icon: Icons.bedtime_outlined,
                title: 'Quản lý giấc ngủ',
                subtitle: 'Ghi lại thói quen giấc ngủ',
                isSelected: isSleepManagementSelected,
                onChanged: (value) {
                  setState(() {
                    isSleepManagementSelected = value;
                  });
                },
              ),
              _buildGoalItem(
                icon: Icons.directions_run,
                title: 'Vận động',
                subtitle: 'Tăng cường hoạt động thể chất',
                isSelected: isExerciseSelected,
                onChanged: (value) {
                  setState(() {
                    isExerciseSelected = value;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await _saveGoalsToFirestore();
                  Get.toNamed(AppRoutes.WEIGHT_GOALS_SCREEN);
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

  Widget _buildGoalItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
        ),
        child: ListTile(
          leading: Icon(icon, size: 40, color: Colors.blue),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          trailing: Switch(
            value: isSelected,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ),
      ),
    );
  }
}
