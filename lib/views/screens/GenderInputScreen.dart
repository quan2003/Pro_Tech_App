import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Routes/AppRoutes.dart';

class GenderInputScreen extends StatefulWidget {
  const GenderInputScreen({super.key});

  @override
  _GenderInputScreenState createState() => _GenderInputScreenState();
}

class _GenderInputScreenState extends State<GenderInputScreen> {
  String? _selectedGender;

  void _onGenderSelected(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  Future<void> _updateGenderToFirestore(String gender) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'gender': gender,
        }, SetOptions(merge: true)); // Merge to update only the gender field
        Get.snackbar('Thành công', 'Giới tính của bạn đã được cập nhật.');
      } catch (e) {
        print('Lỗi khi cập nhật giới tính: $e');
        Get.snackbar('Lỗi', 'Không thể cập nhật giới tính. Vui lòng thử lại.');
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
                'Giới tính sinh học',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hãy xác định giới tính lúc mới sinh của bạn để chúng tôi đưa chỉ dẫn sức khỏe phù hợp',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _genderOption('Nam', 'assets/images/male.png'), // Replace with your image asset
                  _genderOption('Nữ', 'assets/images/female.png'), // Replace with your image asset
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selectedGender != null
                    ? () async {
                        await _updateGenderToFirestore(_selectedGender!);
                        Get.toNamed(AppRoutes.AGE_INPUT_SCREEN);
                      }
                    : null,
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

  Widget _genderOption(String gender, String assetPath) {
    return GestureDetector(
      onTap: () => _onGenderSelected(gender),
      child: Container(
        width: 120,
        height: 150,
        decoration: BoxDecoration(
          color: _selectedGender == gender ? Colors.pinkAccent : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedGender == gender ? Colors.pinkAccent : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetPath,
              width: 60,
              height: 60,
            ),
            const SizedBox(height: 10),
            Text(
              gender,
              style: TextStyle(
                fontSize: 18,
                color: _selectedGender == gender ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
