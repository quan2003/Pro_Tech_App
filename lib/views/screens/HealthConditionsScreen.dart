import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../Routes/AppRoutes.dart';

class HealthConditionsScreen extends StatefulWidget {
  const HealthConditionsScreen({super.key});

  @override
  _HealthConditionsScreenState createState() => _HealthConditionsScreenState();
}

class _HealthConditionsScreenState extends State<HealthConditionsScreen> {
  // Define the state for each condition's switch
  bool isHighBloodPressureSelected = false;
  bool isDiabetesSelected = false;
  bool isHighCholesterolSelected = false;
  bool isChestPainSelected = false;
  bool isHeartFailureSelected = false;
  bool isCancerSelected = false;

  // Function to save selections to Firebase Firestore
  Future<void> _saveSelectionsToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'healthConditions': {
            'isHighBloodPressureSelected': isHighBloodPressureSelected,
            'isDiabetesSelected': isDiabetesSelected,
            'isHighCholesterolSelected': isHighCholesterolSelected,
            'isChestPainSelected': isChestPainSelected,
            'isHeartFailureSelected': isHeartFailureSelected,
            'isCancerSelected': isCancerSelected,
          },
        }, SetOptions(merge: true));
        Get.snackbar('Thông báo', 'Lựa chọn của bạn đã được lưu.');
      } catch (e) {
        print('Lỗi khi lưu lựa chọn: $e');
        Get.snackbar('Lỗi', 'Không thể lưu lựa chọn. Vui lòng thử lại.');
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
                'Bạn có mắc một trong các bệnh sau không?',
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
              _buildConditionItem(
                icon: Icons.bloodtype,
                iconColor: Colors.red,
                title: 'Cao huyết áp',
                isSelected: isHighBloodPressureSelected,
                onChanged: (value) {
                  setState(() {
                    isHighBloodPressureSelected = value;
                  });
                },
              ),
              _buildConditionItem(
                icon: Icons.local_drink,
                iconColor: Colors.blue,
                title: 'Tiểu đường',
                isSelected: isDiabetesSelected,
                onChanged: (value) {
                  setState(() {
                    isDiabetesSelected = value;
                  });
                },
              ),
              _buildConditionItem(
                icon: Icons.water_drop,
                iconColor: Colors.yellow,
                title: 'Mỡ máu cao',
                isSelected: isHighCholesterolSelected,
                onChanged: (value) {
                  setState(() {
                    isHighCholesterolSelected = value;
                  });
                },
              ),
              _buildConditionItem(
                icon: Icons.local_fire_department,
                iconColor: Colors.red,
                title: 'Đau thắt ngực',
                isSelected: isChestPainSelected,
                onChanged: (value) {
                  setState(() {
                    isChestPainSelected = value;
                  });
                },
              ),
              _buildConditionItem(
                icon: Icons.favorite,
                iconColor: Colors.pink,
                title: 'Suy tim',
                isSelected: isHeartFailureSelected,
                onChanged: (value) {
                  setState(() {
                    isHeartFailureSelected = value;
                  });
                },
              ),
              _buildConditionItem(
                icon: Icons.local_hospital,
                iconColor: Colors.orange,
                title: 'Ung thư',
                isSelected: isCancerSelected,
                onChanged: (value) {
                  setState(() {
                    isCancerSelected = value;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await _saveSelectionsToFirestore();
                  Get.toNamed(AppRoutes.HEALTH_GOALS_SCREEN);
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

  Widget _buildConditionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
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
          leading: Icon(icon, size: 40, color: iconColor),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
