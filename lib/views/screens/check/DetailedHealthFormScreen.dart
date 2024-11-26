import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/DetailedHealthFormController.dart';

class DetailedHealthFormScreen extends StatelessWidget {
  final controller = Get.put(DetailedHealthFormController());
  final _formKey = GlobalKey<FormState>();

  DetailedHealthFormScreen({super.key});

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
                      'Detailed health information',
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

              // Chest Pain Type
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
                      'Loại đau ngực',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => Column(
                          children: [
                            _buildChestPainOption('ASY', 'Không triệu chứng'),
                            _buildChestPainOption(
                                'ATA', 'Đau thắt ngực không điển hình'),
                            _buildChestPainOption(
                                'NAP', 'Đau ngực không do tim'),
                            _buildChestPainOption(
                                'TA', 'Đau thắt ngực điển hình'),
                          ],
                        )),
                  ],
                ),
              ),

              // Resting Blood Pressure
              Obx(() => _buildNumericInput(
                    title: 'Huyết áp khi nghỉ',
                    unit: 'mmHg',
                    value: controller.restingBP,
                    minValue: controller.restingBPRange.$1,
                    maxValue: controller.restingBPRange.$2,
                    showError: controller.showRestingBPError,
                    onChanged: (value) {
                      controller.restingBP.value = value;
                      controller.showRestingBPError.value = false;
                    },
                  )),

              // Cholesterol
              Obx(() => _buildNumericInput(
                    title: 'Cholesterol',
                    unit: 'mg/dL',
                    value: controller.cholesterol,
                    minValue: controller.cholesterolRange.$1,
                    maxValue: controller.cholesterolRange.$2,
                    showError: controller.showCholesterolError,
                    onChanged: (value) {
                      controller.cholesterol.value = value;
                      controller.showCholesterolError.value = false;
                    },
                  )),

              // // Fasting Blood Sugar
              // Container(
              //   margin: const EdgeInsets.all(16),
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(color: Colors.grey[300]!),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       const Text(
              //         'Đường huyết lúc đói > 120 mg/dl',
              //         style: TextStyle(
              //           fontSize: 16,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       Obx(() => Switch(
              //             value: controller.fastingBS.value,
              //             onChanged: (value) =>
              //                 controller.fastingBS.value = value,
              //             activeColor: Colors.white,
              //             activeTrackColor: Colors.green,
              //             inactiveThumbColor: Colors.white,
              //             inactiveTrackColor: Colors.grey[300],
              //           )),
              //     ],
              //   ),
              // ),

              // Resting ECG
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
                      'Điện tâm đồ khi nghỉ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => Column(
                          children: [
                            _buildECGOption('Normal', 'Bình thường'),
                            _buildECGOption('ST', 'Bất thường ST-T'),
                            _buildECGOption('LVH', 'Phì đại thất trái'),
                          ],
                        )),
                  ],
                ),
              ),

              // Max Heart Rate
              Obx(() => _buildNumericInput(
                    title: 'Nhịp tim tối đa',
                    unit: 'bpm',
                    value: controller.maxHeartRate,
                    minValue: controller.maxHeartRateRange.$1,
                    maxValue: controller.maxHeartRateRange.$2,
                    showError: controller.showMaxHeartRateError,
                    onChanged: (value) {
                      controller.maxHeartRate.value = value;
                      controller.showMaxHeartRateError.value = false;
                    },
                  )),

              // Exercise Angina
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Đau thắt ngực khi gắng sức',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(() => Switch(
                          value: controller.exerciseAngina.value,
                          onChanged: (value) =>
                              controller.exerciseAngina.value = value,
                          activeColor: Colors.white,
                          activeTrackColor: Colors.green,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey[300],
                        )),
                  ],
                ),
              ),

              // Oldpeak
              Obx(() => _buildNumericInput(
                    title: 'ST Depression (Oldpeak)',
                    unit: 'mm',
                    value: controller.oldpeak,
                    minValue: controller.oldpeakRange.$1,
                    maxValue: controller.oldpeakRange.$2,
                    showError: controller.showOldpeakError,
                    onChanged: (value) {
                      controller.oldpeak.value = value;
                      controller.showOldpeakError.value = false;
                    },
                    isDecimal: true,
                  )),

              // ST Slope
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
                      'ST Slope',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => Column(
                          children: [
                            _buildSlopeOption('Up', 'Đi lên'),
                            _buildSlopeOption('Flat', 'Phẳng'),
                            _buildSlopeOption('Down', 'Đi xuống'),
                          ],
                        )),
                  ],
                ),
              ),

              // Submit Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Call the existing submitForm method to perform the prediction
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
                        icon: const Icon(Icons.info_outline),
                        color: Colors.grey[600],
                        onPressed: () => controller.showWarningDialog(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericInput({
    required String title,
    required String unit,
    required RxDouble value,
    required double minValue,
    required double maxValue,
    required RxBool showError,
    required Function(double) onChanged,
    bool isDecimal = false,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showError.value ? Colors.red[900]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '($unit)',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
          Slider(
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isDecimal
                    ? minValue.toStringAsFixed(1)
                    : minValue.toInt().toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isDecimal
                    ? maxValue.toStringAsFixed(1)
                    : maxValue.toInt().toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
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
          if (showError.value)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  'Vui lòng chọn giá trị từ $minValue đến $maxValue',
                  style: TextStyle(
                    color: Colors.red[900],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChestPainOption(String value, String label) {
    return GestureDetector(
      onTap: () => controller.chestPainType.value = value,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: controller.chestPainType.value == value
              ? Colors.green
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: controller.chestPainType.value == value
                ? Colors.green
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              controller.chestPainType.value == value
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: controller.chestPainType.value == value
                  ? Colors.white
                  : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: controller.chestPainType.value == value
                    ? Colors.white
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildECGOption(String value, String label) {
    return GestureDetector(
      onTap: () => controller.restingECG.value = value,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: controller.restingECG.value == value
              ? Colors.green
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: controller.restingECG.value == value
                ? Colors.green
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              controller.restingECG.value == value
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: controller.restingECG.value == value
                  ? Colors.white
                  : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: controller.restingECG.value == value
                    ? Colors.white
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlopeOption(String value, String label) {
    return GestureDetector(
      onTap: () => controller.stSlope.value = value,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              controller.stSlope.value == value ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: controller.stSlope.value == value
                ? Colors.green
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              controller.stSlope.value == value
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: controller.stSlope.value == value
                  ? Colors.white
                  : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: controller.stSlope.value == value
                    ? Colors.white
                    : Colors.grey[600],
              ),
            ),
          ],
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
        ],
      ),
    );
  }
}
