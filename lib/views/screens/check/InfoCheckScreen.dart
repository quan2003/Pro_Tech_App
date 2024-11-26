import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'BasicHealthFormScreen.dart';
import 'DetailedHealthFormScreen.dart';

class InfoCheckScreen extends StatelessWidget {
  const InfoCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth < 400;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            title: const Text('Kiểm tra thông tin'),
            backgroundColor: Colors.blue[700],
          ),
          body: Container(
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bạn có biết các chỉ số sau không?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoItem(
                              'Chỉ số Cholesterol',
                              'Chỉ số cholesterol trong máu (mg/dL)',
                              Icons.monitor_heart_outlined,
                            ),
                            _buildInfoItem(
                              'Huyết áp',
                              'Chỉ số huyết áp tâm thu/tâm trương',
                              Icons.favorite_outline,
                            ),
                            _buildInfoItem(
                              'Đường huyết lúc đói',
                              'Chỉ số đường huyết lúc đói (mg/dL)',
                              Icons.water_drop_outlined,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.to(
                                        () => DetailedHealthFormScreen(),
                                        transition: Transition.rightToLeft,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[700],
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    child: const Text('Có, tôi có thông tin'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Get.to(
                                        () => BasicHealthFormScreen(),
                                        transition: Transition.rightToLeft,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: Colors.grey[400]!, width: 1.5),
                                      foregroundColor: Colors.black54,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    child: const Text('Không, tôi không có'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue[700], size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStep(
          label: 'Thông tin\ncơ bản',
          isActive: false,
          isCompleted: true,
        ),
        _buildConnector(isCompleted: true),
        _buildStep(
          label: 'Kiểm tra\nthông tin',
          isActive: true,
          isCompleted: false,
        ),
        _buildConnector(isCompleted: false),
        _buildStep(
          label: 'Chi tiết\nsức khỏe',
          isActive: false,
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildStep({
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Colors.blue[700]
                : (isCompleted ? Colors.green : Colors.grey[400]),
            border: Border.all(
              color: isActive
                  ? Colors.blue[700]!
                  : (isCompleted ? Colors.green : Colors.grey[400]!),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    isActive ? '2' : '3',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? Colors.white
                : (isCompleted ? Colors.green : Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required bool isCompleted}) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isCompleted ? Colors.green : Colors.grey[400],
    );
  }
}
