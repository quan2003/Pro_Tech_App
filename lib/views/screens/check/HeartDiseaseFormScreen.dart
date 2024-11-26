import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_tech_app/views/screens/check/result_screen.dart';

import '../../controller/HeartDiseaseService1.dart';

class HeartDiseaseFormScreen extends StatefulWidget {
  const HeartDiseaseFormScreen({super.key});

  @override
  State<HeartDiseaseFormScreen> createState() => _HeartDiseaseFormScreenState();
}

class _HeartDiseaseFormScreenState extends State<HeartDiseaseFormScreen> {
  int currentQuestion = 1;
  final int totalQuestions = 15;
  bool isRegistering = false;
  bool isLoading = false;
  final HeartDiseaseService1 _heartDiseaseService = HeartDiseaseService1();
  Map<String, dynamic>? _predictionResult;

  // Biến lưu trữ câu trả lời
  String? gender;
  String? chestPainFrequency;
  String? chestPainType;
  String? restingBloodPressure;
  String? cholesterol;
  String? bloodSugar;
  String? restingECG;
  String? maxHeartRate;
  String? exerciseAngina;
  String? stDepression;
  String? stSlope;
  String? heartDiseaseDiagnosis;
  String? checkupFrequency;
  String? symptoms;
  String? exerciseFrequency;

  // Registration form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? registrationGender;

// Thêm các hàm này vào class _HeartDiseaseFormScreenState

// Hàm tính tuổi từ ngày sinh
  int _calculateAge(String birthDate) {
    List<String> parts = birthDate.split('/');
    DateTime birth = DateTime(
      int.parse(parts[2]), // year
      int.parse(parts[1]), // month
      int.parse(parts[0]), // day
    );
    DateTime now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }

// Hàm chuyển đổi dữ liệu
  Map<String, dynamic> _processFormData() {
    // Chuyển đổi giới tính
    int sex = gender == 'Nam' ? 1 : 0;

    // Chuyển đổi loại đau ngực
    int chestPainTypeValue;
    switch (chestPainType) {
      case 'Đau thắt ngực điển hình':
        chestPainTypeValue = 1;
      case 'Đau thắt ngực không điển hình':
        chestPainTypeValue = 2;
      case 'Đau ngực không liên quan đến tim':
        chestPainTypeValue = 3;
      case 'Không đau ngực':
        chestPainTypeValue = 4;
      default:
        chestPainTypeValue = 4;
    }

    // Chuyển đổi huyết áp
    double restingBPValue;
    switch (restingBloodPressure) {
      case 'Bình thường':
        restingBPValue = 120.0;
      case 'Tiền cao huyết áp':
        restingBPValue = 130.0;
      case 'Cao huyết áp':
        restingBPValue = 140.0;
      default:
        restingBPValue = 120.0;
    }

    // Chuyển đổi cholesterol
    double cholesterolValue;
    switch (cholesterol) {
      case 'Bình thường':
        cholesterolValue = 180.0;
      case 'Hơi cao':
        cholesterolValue = 220.0;
      case 'Cao':
        cholesterolValue = 250.0;
      default:
        cholesterolValue = 200.0;
    }

    // Chuyển đổi đường huyết
    int fastingBSValue = bloodSugar == 'Cao' ? 1 : 0;

    // Chuyển đổi điện tâm đồ
    int restingECGValue;
    switch (restingECG) {
      case 'Bình thường':
        restingECGValue = 0;
      case 'Bất thường nhẹ':
        restingECGValue = 1;
      case 'Bất thường nghiêm trọng':
        restingECGValue = 2;
      default:
        restingECGValue = 0;
    }

    // Chuyển đổi nhịp tim tối đa
    double maxHRValue;
    switch (maxHeartRate) {
      case 'Dưới 100 bpm':
        maxHRValue = 90.0;
      case '100-130 bpm':
        maxHRValue = 115.0;
      case 'Trên 130 bpm':
        maxHRValue = 140.0;
      default:
        maxHRValue = 120.0;
    }

    // Chuyển đổi đau ngực khi vận động
    int exerciseAnginaValue = exerciseAngina == 'Có' ? 1 : 0;

    // Chuyển đổi ST depression
    double oldpeakValue;
    switch (stDepression) {
      case 'Không có suy giảm':
        oldpeakValue = 0.0;
      case 'Suy giảm nhẹ':
        oldpeakValue = 1.0;
      case 'Suy giảm vừa phải':
        oldpeakValue = 2.0;
      case 'Suy giảm đáng kể':
        oldpeakValue = 3.0;
      default:
        oldpeakValue = 0.0;
    }

    // Chuyển đổi ST slope
    int stSlopeValue;
    switch (stSlope) {
      case 'Tăng':
        stSlopeValue = 1;
      case 'Phẳng':
        stSlopeValue = 2;
      case 'Giảm':
        stSlopeValue = 3;
      default:
        stSlopeValue = 1;
    }

    return {
      'Age': _calculateAge(_birthDateController.text).toDouble(),
      'Sex': sex,
      'ChestPainType': chestPainTypeValue,
      'RestingBP': restingBPValue,
      'Cholesterol': cholesterolValue,
      'FastingBS': fastingBSValue,
      'RestingECG': restingECGValue,
      'MaxHR': maxHRValue,
      'ExerciseAngina': exerciseAnginaValue,
      'Oldpeak': oldpeakValue,
      'ST_Slope': stSlopeValue,
    };
  }

// Hàm gọi API prediction
  Future<void> _getPrediction() async {
    setState(() {
      isLoading = true; // Bắt đầu loading
    });
    try {
      final formData = _processFormData();
      final result = await _heartDiseaseService.predictHeartDisease(
        age: formData['Age'],
        sex: formData['Sex'],
        chestPainType: formData['ChestPainType'],
        restingBP: formData['RestingBP'],
        cholesterol: formData['Cholesterol'],
        restingECG: formData['RestingECG'],
        maxHR: formData['MaxHR'],
        exerciseAngina: formData['ExerciseAngina'],
        oldpeak: formData['Oldpeak'],
        stSlope: formData['ST_Slope'],
      );

      setState(() {
        _predictionResult = result;
        isLoading = false; // Kết thúc loading
      });
      // Chuyển sang màn hình kết quả
      Get.to(() => ResultScreen1(result: _predictionResult!));
    } catch (e) {
      setState(() {
        isLoading = false; // Kết thúc loading nếu có lỗi
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildLoadingOverlay() {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Đang xử lý...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  String? _getSelectedAnswer(int questionNumber) {
    switch (questionNumber) {
      case 1:
        return gender;
      case 2:
        return chestPainFrequency;
      case 3:
        return chestPainType;
      case 4:
        return restingBloodPressure;
      case 5:
        return cholesterol;
      case 6:
        return bloodSugar;
      case 7:
        return restingECG;
      case 8:
        return maxHeartRate;
      case 9:
        return exerciseAngina;
      case 10:
        return stDepression;
      case 11:
        return stSlope;
      case 12:
        return heartDiseaseDiagnosis;
      case 13:
        return checkupFrequency;
      case 14:
        return symptoms;
      case 15:
        return exerciseFrequency;
      default:
        return null;
    }
  }

  Widget _buildQuestion() {
    switch (currentQuestion) {
      case 1:
        return _buildOptionsQuestion(
          'Giới tính của bạn là gì?',
          {
            'A. Nam': 'Nam',
            'B. Nữ': 'Nữ',
          },
          gender,
          (value) => setState(() => gender = value),
        );
      case 2:
        return _buildOptionsQuestion(
          'Bạn có thường xuyên bị đau ngực không?',
          {
            'A. Có': 'Có',
            'B. Không': 'Không',
          },
          chestPainFrequency,
          (value) => setState(() => chestPainFrequency = value),
        );
      case 3:
        return _buildOptionsQuestion(
          'Loại đau ngực bạn thường trải qua là gì?',
          {
            'A. Đau thắt ngực điển hình (ép ngực, đau nhói khi vận động)':
                'Đau thắt ngực điển hình',
            'B. Đau thắt ngực không điển hình (không có dấu hiệu rõ ràng)':
                'Đau thắt ngực không điển hình',
            'C. Đau ngực không liên quan đến tim (đau do căng cơ, trào ngược dạ dày, stress)':
                'Đau ngực không liên quan đến tim',
            'D. Không đau ngực': 'Không đau ngực',
          },
          chestPainType,
          (value) => setState(() => chestPainType = value),
        );
      case 4:
        return _buildOptionsQuestion(
          'Huyết áp của bạn ở trạng thái nghỉ ngơi thường là bao nhiêu?',
          {
            'A. < 120/80 mmHg (Bình thường)': 'Bình thường',
            'B. 120-139/80-89 mmHg (Tiền cao huyết áp)': 'Tiền cao huyết áp',
            'C. ≥ 140/90 mmHg (Cao huyết áp)': 'Cao huyết áp',
            'D. Tôi không biết': 'Không biết',
          },
          restingBloodPressure,
          (value) => setState(() => restingBloodPressure = value),
        );
      case 5:
        return _buildOptionsQuestion(
          'Mức cholesterol trong máu của bạn là bao nhiêu?',
          {
            'A. < 200 mg/dL (Bình thường)': 'Bình thường',
            'B. 200-239 mg/dL (Hơi cao)': 'Hơi cao',
            'C. ≥ 240 mg/dL (Cao)': 'Cao',
            'D. Tôi không biết': 'Không biết',
          },
          cholesterol,
          (value) => setState(() => cholesterol = value),
        );
      case 6:
        return _buildOptionsQuestion(
          'Đường huyết của bạn lúc đói là bao nhiêu?',
          {
            'A. ≤ 120 mg/dL (Bình thường)': 'Bình thường',
            'B. > 120 mg/dL (Cao)': 'Cao',
            'C. Tôi không biết': 'Không biết',
          },
          bloodSugar,
          (value) => setState(() => bloodSugar = value),
        );
      case 7:
        return _buildOptionsQuestion(
          'Kết quả điện tâm đồ của bạn khi nghỉ ngơi là gì?',
          {
            'A. Bình thường': 'Bình thường',
            'B. Bất thường nhưng không nghiêm trọng': 'Bất thường nhẹ',
            'C. Có dấu hiệu bất thường nghiêm trọng': 'Bất thường nghiêm trọng',
            'D. Tôi chưa kiểm tra': 'Chưa kiểm tra',
          },
          restingECG,
          (value) => setState(() => restingECG = value),
        );
      case 8:
        return _buildOptionsQuestion(
          'Nhịp tim tối đa mà bạn đạt được trong bài kiểm tra là bao nhiêu?',
          {
            'A. Dưới 100 bpm': 'Dưới 100 bpm',
            'B. 100-130 bpm': '100-130 bpm',
            'C. Trên 130 bpm': 'Trên 130 bpm',
            'D. Tôi không biết': 'Không biết',
          },
          maxHeartRate,
          (value) => setState(() => maxHeartRate = value),
        );
      case 9:
        return _buildOptionsQuestion(
          'Bạn có cảm thấy đau ngực khi tập thể dục hoặc vận động không?',
          {
            'A. Có': 'Có',
            'B. Không': 'Không',
          },
          exerciseAngina,
          (value) => setState(() => exerciseAngina = value),
        );
      case 10:
        return _buildOptionsQuestion(
          'Mức độ suy giảm ST khi tập thể dục so với khi nghỉ ngơi của bạn là bao nhiêu?',
          {
            'A. Không có suy giảm ST': 'Không có suy giảm',
            'B. Suy giảm nhẹ (≤ 1 mm)': 'Suy giảm nhẹ',
            'C. Suy giảm vừa phải (1-2 mm)': 'Suy giảm vừa phải',
            'D. Suy giảm đáng kể (> 2 mm)': 'Suy giảm đáng kể',
            'E. Tôi không biết': 'Không biết',
          },
          stDepression,
          (value) => setState(() => stDepression = value),
        );
      case 11:
        return _buildOptionsQuestion(
          'Slope của đoạn ST trong bài tập thể dục của bạn là gì?',
          {
            'A. Tăng (Upsloping)': 'Tăng',
            'B. Phẳng (Flat)': 'Phẳng',
            'C. Giảm (Downsloping)': 'Giảm',
            'D. Tôi không biết': 'Không biết',
          },
          stSlope,
          (value) => setState(() => stSlope = value),
        );
      case 12:
        return _buildOptionsQuestion(
          'Bạn đã từng được chẩn đoán mắc bệnh tim chưa?',
          {
            'A. Có': 'Có',
            'B. Không': 'Không',
          },
          heartDiseaseDiagnosis,
          (value) => setState(() => heartDiseaseDiagnosis = value),
        );
      case 13:
        return _buildOptionsQuestion(
          'Bạn có thường xuyên kiểm tra huyết áp và cholesterol không?',
          {
            'A. Có, hàng tháng': 'Hàng tháng',
            'B. Có, 1-2 lần mỗi năm': '1-2 lần/năm',
            'C. Rất ít, không đều đặn': 'Không đều đặn',
            'D. Chưa từng kiểm tra': 'Chưa từng',
          },
          checkupFrequency,
          (value) => setState(() => checkupFrequency = value),
        );
      case 14:
        return _buildOptionsQuestion(
          'Bạn có các triệu chứng như chóng mặt, mệt mỏi khi vận động hoặc nghỉ ngơi không?',
          {
            'A. Có, rất thường xuyên': 'Thường xuyên',
            'B. Có, thỉnh thoảng': 'Thỉnh thoảng',
            'C. Không': 'Không',
          },
          symptoms,
          (value) => setState(() => symptoms = value),
        );
      case 15:
        return _buildOptionsQuestion(
          'Bạn có thường xuyên vận động hoặc tập thể dục không?',
          {
            'A. Có, ít nhất 5 lần/tuần': 'Ít nhất 5 lần/tuần',
            'B. Có, 2-4 lần/tuần': '2-4 lần/tuần',
            'C. Ít hơn 2 lần/tuần': 'Ít hơn 2 lần/tuần',
            'D. Không bao giờ': 'Không bao giờ',
          },
          exerciseFrequency,
          (value) => setState(() => exerciseFrequency = value),
        );
      default:
        return Container();
    }
  }

  Widget _buildOptionsQuestion(
    String question,
    Map<String, String> options,
    String? currentValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...options.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: RadioListTile<String>(
                title: Text(entry.key),
                value: entry.value,
                groupValue: currentValue,
                onChanged: onChanged,
              ),
            ),
          );
        }),
      ],
    );
  }

  String _getQuestionTitle(int questionNumber) {
    switch (questionNumber) {
      case 1:
        return 'Giới tính của bạn là gì?';
      case 2:
        return 'Bạn có thường xuyên bị đau ngực không?';
      case 3:
        return 'Loại đau ngực bạn thường trải qua là gì?';
      case 4:
        return 'Huyết áp của bạn ở trạng thái nghỉ ngơi thường là bao nhiêu?';
      case 5:
        return 'Mức cholesterol trong máu của bạn là bao nhiêu?';
      case 6:
        return 'Đường huyết của bạn lúc đói là bao nhiêu?';
      case 7:
        return 'Kết quả điện tâm đồ của bạn khi nghỉ ngơi là gì?';
      case 8:
        return 'Nhịp tim tối đa mà bạn đạt được trong bài kiểm tra là bao nhiêu?';
      case 9:
        return 'Bạn có cảm thấy đau ngực khi tập thể dục hoặc vận động không?';
      case 10:
        return 'Mức độ suy giảm ST khi tập thể dục so với khi nghỉ ngơi của bạn là bao nhiêu?';
      case 11:
        return 'Slope của đoạn ST trong bài tập thể dục của bạn là gì?';
      case 12:
        return 'Bạn đã từng được chẩn đoán mắc bệnh tim chưa?';
      case 13:
        return 'Bạn có thường xuyên kiểm tra huyết áp và cholesterol không?';
      case 14:
        return 'Bạn có các triệu chứng như chóng mặt, mệt mỏi khi vận động hoặc nghỉ ngơi không?';
      case 15:
        return 'Bạn có thường xuyên vận động hoặc tập thể dục không?';
      default:
        return '';
    }
  }

  Widget _buildRegistrationForm() {
    return Stack(
      children: [
        Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/clipboard.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kiểm tra nguy cơ tim mạch của Quý khách',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đăng ký thông tin để nhận kết quả',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Gender Selection
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Anh'),
                              value: 'Anh',
                              groupValue: registrationGender,
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        registrationGender = value;
                                      });
                                    },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Chị'),
                              value: 'Chị',
                              groupValue: registrationGender,
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        registrationGender = value;
                                      });
                                    },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Form fields
                      TextFormField(
                        controller: _nameController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Họ và tên',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Số điện thoại',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _birthDateController,
                        enabled: !isLoading,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          hintText: 'Ngày sinh',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email (không bắt buộc)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Submit buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_validateForm()) {
                                _getPrediction();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        isLoading ? 'Đang xử lý...' : 'Nhận kết quả',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              isRegistering = false;
                              currentQuestion = 1;
                              _resetForm();
                            });
                          },
                    child: const Text(
                      'Trả lời lại',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (isLoading) _buildLoadingOverlay(),
      ],
    );
  }

  void _resetForm() {
    _nameController.clear();
    _phoneController.clear();
    _birthDateController.clear();
    _emailController.clear();
    registrationGender = null;
  }

  bool _validateForm() {
    if (registrationGender == null) {
      _showError('Vui lòng chọn giới tính');
      return false;
    }
    if (_nameController.text.isEmpty) {
      _showError('Vui lòng nhập họ và tên');
      return false;
    }
    if (_phoneController.text.isEmpty) {
      _showError('Vui lòng nhập số điện thoại');
      return false;
    }
    if (_birthDateController.text.isEmpty) {
      _showError('Vui lòng chọn ngày sinh');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: isLoading ? null : () => Get.back(),
        ),
        title: const Text(
          'Sàng lọc nguy cơ mắc bệnh tim mạch',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.blue[50],
            child: isRegistering
                ? _buildRegistrationForm()
                : Column(
                    children: [
                      // Header with icon and title
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/clipboard.png',
                                width: 40,
                                height: 40,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Kiểm tra nguy cơ tim mạch của bạn',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Progress section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (currentQuestion > 1)
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          currentQuestion--;
                                        });
                                      },
                                child: const Row(
                                  children: [
                                    Icon(Icons.chevron_left,
                                        color: Colors.blue),
                                    Text(
                                      'Trước',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Text(
                              'Câu $currentQuestion/$totalQuestions',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      String? currentAnswer =
                                          _getSelectedAnswer(currentQuestion);
                                      if (currentAnswer == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Vui lòng chọn câu trả lời để tiếp tục'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } else if (currentQuestion <
                                          totalQuestions) {
                                        setState(() {
                                          currentQuestion++;
                                        });
                                      }
                                    },
                              child: const Row(
                                children: [
                                  Text(
                                    'Sau',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: Colors.blue),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Progress bar
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: LinearProgressIndicator(
                          value: currentQuestion / totalQuestions,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Previous answer if exists
                      if (currentQuestion > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Câu ${currentQuestion - 1}: ${_getQuestionTitle(currentQuestion - 1)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Đáp án đã chọn: ${_getSelectedAnswer(currentQuestion - 1)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Question content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AbsorbPointer(
                            absorbing: isLoading,
                            child: _buildQuestion(),
                          ),
                        ),
                      ),

                      // Continue button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (isLoading ||
                                    _getSelectedAnswer(currentQuestion) == null)
                                ? null
                                : () {
                                    if (currentQuestion < totalQuestions) {
                                      setState(() {
                                        currentQuestion++;
                                      });
                                    } else {
                                      setState(() {
                                        isRegistering = true;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              currentQuestion == totalQuestions
                                  ? 'Hoàn thành'
                                  : 'Tiếp tục',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang xử lý...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
