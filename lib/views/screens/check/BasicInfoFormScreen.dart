import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_tech_app/views/screens/check/BasicHealthFormScreen.dart';
import 'package:pro_tech_app/views/screens/check/DetailedHealthFormScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class BasicInfoFormController extends GetxController {
  var selectedGender = ''.obs;
  var age = 18.0.obs;
  var showGenderError = false.obs;
  var showAgeError = false.obs;

  final double minAge = 18.0;
  final double maxAge = 80.0;

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter age';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Age must be a number';
    }
    if (age < 18 || age > 80) {
      return 'Age must be between 18 and 80';
    }
    return null;
  }

  void validateAndShowDialog(BuildContext context) {
    showGenderError.value = selectedGender.isEmpty;
    showAgeError.value = age.value < minAge || age.value > maxAge;

    if (showGenderError.value || showAgeError.value) {
      // Show warning dialog
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.red[900],
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Thông tin chưa đầy đủ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Error Messages
                if (showGenderError.value)
                  const Text(
                    'Vui lòng chọn giới tính',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                if (showAgeError.value)
                  const Text(
                    'Vui lòng chọn tuổi từ 18-80',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 20),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Đã hiểu',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void showTestResultsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[900],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.medical_information,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Thông tin xét nghiệm',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bạn có biết kết quả những xét nghiệm sau không?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTestItem(
                        'Cholesterol',
                        'Chỉ số mỡ máu',
                        'https://www.vinmec.com/vie/bai-viet/cholesterol-la-gi-co-may-loai-cholesterol-vi',
                      ),
                      _buildTestItem(
                        'Huyết áp khi nghỉ',
                        'Áp lực máu trong mạch máu khi nghỉ ngơi',
                        'https://www.vinmec.com/vie/bai-viet/huyet-ap-la-gi-vi',
                      ),
                      _buildTestItem(
                        'Điện tâm đồ khi nghỉ',
                        'Đo hoạt động điện của tim',
                        'https://www.vinmec.com/vie/bai-viet/cac-chi-so-dien-tam-do-binh-thuong-vi',
                      ),
                      _buildTestItem(
                        'Nhịp tim tối đa',
                        'Số nhịp đập của tim trong 1 phút',
                        'https://www.vinmec.com/vie/bai-viet/nhip-tim-ly-tuong-khi-chay-la-bao-nhieu-vi',
                      ),
                      _buildTestItem(
                        'ST Depression (Oldpeak)',
                        'Sự thay đổi trong đoạn ST của điện tâm đồ',
                        'https://www.vinmec.com/vie/bai-viet/doan-st-trong-ket-qua-dien-tam-do-la-gi-vi',
                      ),
                      _buildTestItem(
                        'ST Slope',
                        'Độ dốc của đoạn ST trên điện tâm đồ',
                        'https://www.vinmec.com/vie/bai-viet/doan-st-trong-ket-qua-dien-tam-do-la-gi-vi',
                      ),
                    ],
                  ),
                ),

                // Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Chuyển sang BasicHealthFormScreen với age và gender
                          Get.to(
                            () => BasicHealthFormScreen(),
                            arguments: {
                              'age': age.value.toInt(),
                              'gender': selectedGender.value,
                            },
                          );
                        },
                        child: Text(
                          'Không',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[900],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // Update this line to pass arguments
                          Get.to(
                            () => DetailedHealthFormScreen(),
                            arguments: {
                              'age': age.value.toInt(),
                              'gender': selectedGender.value,
                            },
                          );
                        },
                        child: const Text(
                          'Có, tôi biết',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestItem(String title, String description, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fiber_manual_record, size: 16, color: Colors.red[900]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _launchURL(url),
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class BasicInfoFormScreen extends StatelessWidget {
  final controller = Get.put(BasicInfoFormController());
  final _formKey = GlobalKey<FormState>();

  BasicInfoFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('SCORE2'),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title and Progress Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Personal risk profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStepIndicator(),
                    // Progress bar
                  ],
                ),
              ),

              // Gender Selection with validation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Choose gender',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Obx(() => _buildGenderCard(
                                  'Male',
                                  Icons.male,
                                  controller.selectedGender.value == 'Male',
                                  () {
                                    controller.selectedGender.value = 'Male';
                                    controller.showGenderError.value = false;
                                  },
                                )),
                            const SizedBox(width: 20),
                            Obx(() => _buildGenderCard(
                                  'Female',
                                  Icons.female,
                                  controller.selectedGender.value == 'Female',
                                  () {
                                    controller.selectedGender.value = 'Female';
                                    controller.showGenderError.value = false;
                                  },
                                )),
                          ],
                        ),
                        Obx(() => controller.showGenderError.value
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Vui lòng chọn giới tính',
                                  style: TextStyle(
                                    color: Colors.red[900],
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()),
                      ],
                    ),
                  ),
                ],
              ),

              // Age Section
              Obx(() => Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.showAgeError.value
                            ? Colors.red[900]!
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Age ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '(years)',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Min-Max labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Min',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Max',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        // Slider
                        Slider(
                          value: controller.age.value,
                          min: controller.minAge,
                          max: controller.maxAge,
                          divisions:
                              (controller.maxAge - controller.minAge).toInt(),
                          label: controller.age.value.toInt().toString(),
                          onChanged: (value) {
                            controller.age.value = value;
                            controller.showAgeError.value = false;
                          },
                          activeColor: Colors.green,
                          inactiveColor: Colors.grey[300],
                        ),
                        // Min-Max values
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${controller.minAge.toInt()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${controller.maxAge.toInt()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Age input field
                        Center(
                          child: SizedBox(
                            width: 80,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              initialValue:
                                  controller.age.value.toInt().toString(),
                              onChanged: (value) {
                                final age = int.tryParse(value);
                                if (age != null &&
                                    age >= controller.minAge &&
                                    age <= controller.maxAge) {
                                  controller.age.value = age.toDouble();
                                  controller.showAgeError.value = false;
                                }
                              },
                              validator: controller.validateAge,
                            ),
                          ),
                        ),
                        if (controller.showAgeError.value)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Center(
                              child: Text(
                                'Vui lòng chọn tuổi từ ${controller.minAge.toInt()} đến ${controller.maxAge.toInt()}',
                                style: TextStyle(
                                  color: Colors.red[900],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),

              // Next Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    // Kiểm tra validation
                    controller.showGenderError.value =
                        controller.selectedGender.isEmpty;
                    controller.showAgeError.value =
                        controller.age.value < controller.minAge ||
                            controller.age.value > controller.maxAge;

                    // Nếu thông tin hợp lệ
                    if (!controller.showGenderError.value &&
                        !controller.showAgeError.value) {
                      // Hiển thị dialog xét nghiệm
                      controller.showTestResultsDialog(context);
                    } else {
                      // Hiển thị cảnh báo nếu thông tin không hợp lệ
                      controller.validateAndShowDialog(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(
    String gender,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                gender,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return SizedBox(
      height: 10,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.red[900],
              ),
            ),
          ),
          const SizedBox(width: 5), // Khoảng trắng
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(width: 5), // Khoảng trắng
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
