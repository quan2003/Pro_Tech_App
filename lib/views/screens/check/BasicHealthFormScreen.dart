import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/BasicHealthFormController.dart';

class BasicHealthFormScreen extends GetView<BasicHealthFormController> {
  final _formKey = GlobalKey<FormState>();

  BasicHealthFormScreen({super.key}) {
    final args = Get.arguments as Map<String, dynamic>;
    Get.put(BasicHealthFormController()).setAge(args['age'] as int);
  }

  @override
  Widget build(BuildContext context) {
    // Nhận arguments từ màn hình trước
    final Map<String, dynamic> arguments = Get.arguments;
    controller.age.value = arguments['age'];
    controller.selectedGender.value = arguments['gender'];
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
            onPressed: () => Get.offAllNamed('/home'),
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
                      'Thông tin sức khỏe cơ bản',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStepIndicator(),
                  ],
                ),
              ),

              // Age Category Display
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin tuổi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tuổi của bạn:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${controller.age.value} tuổi',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nhóm tuổi:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              controller.ageCategory.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),

              // BMI Input
              Obx(() => Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chỉ số BMI',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNumericInput(
                          title: 'Chỉ số BMI',
                          unit: 'kg/m²',
                          value: controller.bmi,
                          minValue: controller.bmiRange.$1,
                          maxValue: controller.bmiRange.$2,
                          showError: controller.showBMIError,
                          onChanged: (value) {
                            controller.bmi.value = value;
                            controller.showBMIError.value = false;
                          },
                          isDecimal: true,
                        ),
                      ],
                    ),
                  )),

              // Lifestyle Section
              _buildLifestyleSection(),
              // Health History Section
              _buildHealthHistorySection(),
              // Physical & Mental Health
              _buildPhysicalMentalHealthSection(),
              // General Health Status
              _buildGeneralHealthStatusSectionWithRadio(),
              // Demographic Information
              _buildDemographicInformationSectionWithRadio(),
              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchOption(String label, RxBool value, {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Use Expanded to prevent text from overflowing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              // Use Flexible to constrain the Switch widget
              Obx(() => Flexible(
                    child: Switch(
                      value: value.value,
                      onChanged: (bool newValue) => value.value = newValue,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.green,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                  )),
            ],
          ),
        ],
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
          const SizedBox(width: 5),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.red[900],
              ),
            ),
          ),
          const SizedBox(width: 5),
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

  Widget _buildLifestyleSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lối sống',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchOption(
            'Hút thuốc',
            controller.smoking,
          ),
          _buildSwitchOption(
            'Uống rượu',
            controller.alcoholDrinking,
          ),
          _buildSwitchOption(
            'Thường xuyên vận động thể chất',
            controller.physicalActivity,
            subtitle: 'Tập thể dục, đi bộ, hoạt động thể chất',
          ),
        ],
      ),
    );
  }

  Widget _buildHealthHistorySection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiền sử bệnh',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchOption(
            'Đột quỵ',
            controller.stroke,
          ),
          _buildSwitchOption(
            'Khó khăn khi đi bộ',
            controller.diffWalking,
          ),
          _buildSwitchOption(
            'Hen suyễn',
            controller.asthma,
          ),
          _buildSwitchOption(
            'Bệnh thận',
            controller.kidneyDisease,
          ),
          _buildSwitchOption(
            'Ung thư da',
            controller.skinCancer,
          ),
          _buildSwitchOption(
            'Tiểu đường',
            controller.Diabetic,
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalMentalHealthSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sức khỏe thể chất và tinh thần',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => _buildNumericInput(
                title: 'Số ngày sức khỏe thể chất không tốt',
                unit: 'ngày/tháng',
                value: controller.physicalHealth,
                minValue: controller.physicalHealthRange.$1,
                maxValue: controller.physicalHealthRange.$2,
                showError: controller.showPhysicalHealthError,
                onChanged: (value) {
                  controller.physicalHealth.value = value;
                  controller.showPhysicalHealthError.value = false;
                },
              )),
          const SizedBox(height: 16),
          Obx(() => _buildNumericInput(
                title: 'Số ngày sức khỏe tinh thần không tốt',
                unit: 'ngày/tháng',
                value: controller.mentalHealth,
                minValue: controller.mentalHealthRange.$1,
                maxValue: controller.mentalHealthRange.$2,
                showError: controller.showMentalHealthError,
                onChanged: (value) {
                  controller.mentalHealth.value = value;
                  controller.showMentalHealthError.value = false;
                },
              )),
          const SizedBox(height: 16),
          Obx(() => _buildNumericInput(
                title: 'Số giờ ngủ trung bình mỗi ngày',
                unit: 'giờ',
                value: controller.sleepTime,
                minValue: controller.sleepTimeRange.$1,
                maxValue: controller.sleepTimeRange.$2,
                showError: controller.showSleepTimeError,
                onChanged: (value) {
                  controller.sleepTime.value = value;
                  controller.showSleepTimeError.value = false;
                },
              )),
        ],
      ),
    );
  }

  Widget _buildGeneralHealthStatusSectionWithRadio() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tình trạng sức khỏe chung',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomOption(
            value: 'Excellent',
            label: 'Rất tốt - Không có vấn đề sức khỏe đáng kể',
            selectedValue: controller.genHealth,
            onTap: (value) => controller.genHealth.value = value,
          ),
          _buildCustomOption(
            value: 'Good',
            label: 'Tốt - Có một số vấn đề nhỏ nhưng không ảnh hưởng nhiều',
            selectedValue: controller.genHealth,
            onTap: (value) => controller.genHealth.value = value,
          ),
          _buildCustomOption(
            value: 'Fair',
            label: 'Bình thường - Có một số vấn đề cần theo dõi',
            selectedValue: controller.genHealth,
            onTap: (value) => controller.genHealth.value = value,
          ),
          _buildCustomOption(
            value: 'Poor',
            label: 'Kém - Có nhiều vấn đề sức khỏe cần được điều trị',
            selectedValue: controller.genHealth,
            onTap: (value) => controller.genHealth.value = value,
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicInformationSectionWithRadio() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin chung',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chủng tộc',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildCustomOption(
            value: 'white',
            label: 'Người da trắng',
            selectedValue: controller.selectedRace,
            onTap: (value) => controller.selectedRace.value = value,
          ),
          _buildCustomOption(
            value: 'black',
            label: 'Người da đen',
            selectedValue: controller.selectedRace,
            onTap: (value) => controller.selectedRace.value = value,
          ),
          _buildCustomOption(
            value: 'hispanic',
            label: 'Người gốc Tây Ban Nha',
            selectedValue: controller.selectedRace,
            onTap: (value) => controller.selectedRace.value = value,
          ),
          _buildCustomOption(
            value: 'asian',
            label: 'Người châu Á',
            selectedValue: controller.selectedRace,
            onTap: (value) => controller.selectedRace.value = value,
          ),
          _buildCustomOption(
            value: 'american_indian_alaskan_native',
            label: 'Người bản địa Mỹ/Alaska',
            selectedValue: controller.selectedRace,
            onTap: (value) => controller.selectedRace.value = value,
          ),
          _buildCustomOption(
            value: 'other',
            label: 'Khác',
            selectedValue: controller.selectedRace,
            onTap: (value) => controller.selectedRace.value = value,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  controller.submitForm();
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
                'Tiếp tục',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.info_outline,
                color: Colors.grey,
              ),
              onPressed: () => Get.dialog(
                AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Warning'),
                    ],
                  ),
                  content: const Text(
                    'Vui lòng đi kiểm tra sức khỏe để đảm bảo thông tin dự báo chính xác hơn. Kết quả hiện tại chỉ mang tính tham khảo và cần có sự tư vấn của bác sĩ chuyên khoa.',
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Đã hiểu',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildCustomOption({
  required String value,
  required String label,
  required RxString selectedValue,
  required Function(String) onTap,
}) {
  return GestureDetector(
    onTap: () => onTap(value),
    child: Obx(() => Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selectedValue.value == value ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedValue.value == value
                  ? Colors.green
                  : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selectedValue.value == value
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: selectedValue.value == value
                    ? Colors.white
                    : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: selectedValue.value == value
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        )),
  );
}

Widget _buildNumericInput({
  required String title,
  required String unit,
  required Rx<double> value,
  required double minValue,
  required double maxValue,
  required RxBool showError,
  required Function(double) onChanged,
  bool isDecimal = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8), // Thêm padding dọc
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title với unit nhỏ
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '($unit)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Min-Max labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Min',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Max',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        // Slider
        Obx(() => Slider(
              value: value.value,
              min: minValue,
              max: maxValue,
              divisions: isDecimal
                  ? ((maxValue - minValue) * 10).toInt()
                  : (maxValue - minValue).toInt(),
              label: isDecimal
                  ? value.value.toStringAsFixed(1)
                  : value.value.toInt().toString(),
              onChanged: onChanged,
              activeColor: Colors.green,
              inactiveColor: Colors.grey[300],
            )),
        // Min-Max values
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isDecimal
                  ? minValue.toStringAsFixed(1)
                  : minValue.toInt().toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              isDecimal
                  ? maxValue.toStringAsFixed(1)
                  : maxValue.toInt().toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Input field
        Center(
          child: Container(
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                border: InputBorder.none, // Bỏ border
                fillColor: Colors.transparent,
                filled: true,
              ),
              initialValue: isDecimal
                  ? value.value.toStringAsFixed(1)
                  : value.value.toInt().toString(),
              onChanged: (string) {
                final number = isDecimal
                    ? double.tryParse(string)
                    : double.tryParse(string);
                if (number != null &&
                    number >= minValue &&
                    number <= maxValue) {
                  onChanged(number);
                }
              },
            ),
          ),
        ),
        // Error message
        Obx(() => showError.value
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Vui lòng chọn giá trị từ $minValue đến $maxValue',
                    style: TextStyle(
                      color: Colors.red[900],
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink()),
      ],
    ),
  );
}
