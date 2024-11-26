// lib/views/screens/heart_disease_check_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pro_tech_app/views/screens/check/BasicInfoFormScreen.dart';

class HeartDiseaseCheckScreen extends StatelessWidget {
  const HeartDiseaseCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Sàng lọc nguy cơ mắc bệnh tim mạch',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blue[700],
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue[700]!,
            Colors.blue[50]!,
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    _buildHeader()
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 500))
                        .slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 24),
                    _buildDoctorImage()
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 800))
                        .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1)),
                    const SizedBox(height: 24),
                    _buildDescription()
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 1000))
                        .slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
          ),
          _buildCheckButton()
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 1200))
              .slideY(begin: 0.5, end: 0),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildHeaderIcon(),
        const SizedBox(width: 12),
        _buildHeaderText(),
      ],
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/clipboard.png',
        width: 32,
        height: 32,
      ),
    );
  }

  Widget _buildHeaderText() {
    return const Expanded(
      child: Text(
        'Kiểm tra nguy cơ tim mạch của\nbạn',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorImage() {
    return Hero(
      tag: 'doctor_illustration',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/doctor_illustration.png',
            height: 300,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'Càng lớn tuổi khả năng mắc phải bệnh tim mạch càng tăng cao. Hãy kiểm tra ngay qua các câu hỏi sau nhằm đánh giá nguy cơ mắc bệnh tim mạch 10 năm tới của bạn để có hướng phòng ngừa phù hợp?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCheckButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => Get.to(
            () => BasicInfoFormScreen(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 500),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            elevation: 3,
            shadowColor: Colors.blue[700]?.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white.withOpacity(0.1);
                }
                return null;
              },
            ),
          ),
          child: const Text(
            'Kiểm tra ngay',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
