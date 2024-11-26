import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ResultScreen2.dart';

class HealthAdviceChat extends StatefulWidget {
  final Map<String, dynamic> healthData;

  const HealthAdviceChat({super.key, required this.healthData});

  @override
  _HealthAdviceChatState createState() => _HealthAdviceChatState();
}

class _HealthAdviceChatState extends State<HealthAdviceChat> {
  final String apiKey = 'YOUR_API_KEY'; // Thay bằng API Key của bạn
  final String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta2/models/gemini-pro:generateText';
  bool isLoading = false;

  final String systemPrompt = '''
Bạn là một trợ lý y tế chuyên tư vấn về sức khỏe tim mạch và lối sống lành mạnh. Dựa trên dữ liệu sức khỏe dưới đây, hãy đưa ra lời khuyên hữu ích và thực tế để cải thiện sức khỏe tim mạch:

Dữ liệu đầu vào:
- BMI: {BMI}
- Hút thuốc: {Smoking}
- Uống rượu: {AlcoholDrinking}
- Đột quỵ: {Stroke}
- Số ngày sức khỏe thể chất không tốt: {PhysicalHealth}
- Số ngày sức khỏe tinh thần không tốt: {MentalHealth}
- Khó khăn khi đi bộ: {DiffWalking}
- Giới tính: {Sex}
- Nhóm tuổi: {AgeCategory}
- Chủng tộc: {Race}
- Tiểu đường: {Diabetic}
- Hoạt động thể chất: {PhysicalActivity}
- Tình trạng sức khỏe chung: {GenHealth}
- Số giờ ngủ: {SleepTime}
- Hen suyễn: {Asthma}
- Bệnh thận: {KidneyDisease}
- Ung thư da: {SkinCancer}

Hãy trả lời với lời khuyên thực tế, ngắn gọn và dễ áp dụng.
''';

  @override
  void initState() {
    super.initState();
    _sendHealthAdvice();
  }

  void _sendHealthAdvice() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Chèn dữ liệu sức khỏe vào prompt
      String formattedPrompt = systemPrompt;
      widget.healthData.forEach((key, value) {
        formattedPrompt =
            formattedPrompt.replaceAll('{$key}', value.toString());
      });

      // Gọi API Gemini
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "prompt": {"text": formattedPrompt},
          "temperature": 0.7,
          "maxOutputTokens": 150
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Lấy lời khuyên từ phản hồi
        final advice = jsonResponse['candidates']?[0]?['output'] ??
            'Chat AI không trả lời. Vui lòng thử lại.';

        // Điều hướng đến màn hình kết quả
        Get.to(() => ResultScreen2(result: {
              'risk_level':
                  'Rủi ro thấp', // Ví dụ: Thêm logic tính toán nếu cần
              'risk_probability': 0.2, // Dữ liệu ví dụ
              'health_recommendations': [advice],
            }));
      } else {
        throw Exception(
            'Không thể kết nối đến hệ thống Chat AI. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Hiển thị thông báo lỗi
      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đang phân tích sức khỏe...'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : const Text('Đang xử lý dữ liệu sức khỏe...'),
      ),
    );
  }
}
