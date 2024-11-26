import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HeartDiseaseService1 {
  static const String baseUrl =
      'http://192.168.1.2:9000'; // Thay thế bằng IP của máy chủ của bạn

  Future<Map<String, dynamic>> predictHeartDisease({
    required double age,
    required int sex,
    required int chestPainType,
    required double restingBP,
    required double cholesterol,
    required int restingECG,
    required double maxHR,
    required int exerciseAngina,
    required double oldpeak,
    required int stSlope,
  }) async {
    final url = Uri.parse('$baseUrl/predict');
    print('📡 Connecting to server at: $baseUrl');

    // Kiểm tra kết nối trước
    try {
      final ping = await InternetAddress.lookup('192.168.1.2');
      print('🔍 Server IP lookup result: ${ping.first.address}');
    } catch (e) {
      print('❌ Cannot resolve server IP: $e');
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra:\n'
          '1. Máy chủ đã khởi động chưa?\n'
          '2. Điện thoại và máy tính có cùng mạng WiFi không?\n'
          '3. Địa chỉ IP máy tính có đúng là 192.168.1.2 không?');
    }

    final Map<String, dynamic> requestBody = {
      'Age': age,
      'Sex': sex,
      'ChestPainType': chestPainType,
      'RestingBP': restingBP,
      'Cholesterol': cholesterol,
      'RestingECG': restingECG,
      'MaxHR': maxHR,
      'ExerciseAngina': exerciseAngina,
      'Oldpeak': oldpeak,
      'ST_Slope': stSlope,
    };

    print('📤 Sending request with data: $requestBody');

    final client = http.Client();
    try {
      final response = await client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(Duration(seconds: 30)); // Set timeout for the request

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        print('📥 Response data: $decoded');
        return json.decode(decoded); // Return the response as a Map
      } else {
        print('❌ Server error: ${response.body}');
        throw Exception(
            'Máy chủ trả về lỗi: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('❌ Other error: $e');
      throw Exception('Có lỗi xảy ra: $e');
    } finally {
      client.close();
    }
  }
}
