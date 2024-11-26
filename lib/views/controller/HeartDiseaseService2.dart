import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class HeartDiseaseService2 {
  static const String baseUrl =
      'http://192.168.1.2:8000'; // IP WiFi của máy tính
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const Duration requestTimeout = Duration(seconds: 30);

  Future<Map<String, dynamic>> predictHeartDisease({
    required double bmi,
    required int smoking,
    required int alcoholDrinking,
    required int stroke,
    required double physicalHealth,
    required double mentalHealth,
    required int diffWalking,
    required int sex,
    required int ageCategory,
    required int race,
    required int diabetic,
    required int physicalActivity,
    required int genHealth,
    required double sleepTime,
    required int asthma,
    required int kidneyDisease,
    required int skinCancer,
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
      'BMI': bmi,
      'Smoking': smoking,
      'AlcoholDrinking': alcoholDrinking,
      'Stroke': stroke,
      'PhysicalHealth': physicalHealth,
      'MentalHealth': mentalHealth,
      'DiffWalking': diffWalking,
      'Sex': sex,
      'AgeCategory': ageCategory,
      'Race': race,
      'Diabetic': diabetic,
      'PhysicalActivity': physicalActivity,
      'GenHealth': genHealth,
      'SleepTime': sleepTime,
      'Asthma': asthma,
      'KidneyDisease': kidneyDisease,
      'SkinCancer': skinCancer,
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
          .timeout(requestTimeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        print('📥 Response data: $decoded');
        return json.decode(decoded);
      } else {
        print('❌ Server error: ${response.body}');
        throw Exception(
            'Máy chủ trả về lỗi: ${response.statusCode}\n${response.body}');
      }
    } on SocketException catch (e) {
      print('🌐 Network error: $e');
      throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra:\n'
          '1. Điện thoại đã kết nối WiFi chưa?\n'
          '2. Máy tính và điện thoại cùng mạng WiFi?\n'
          '3. Tường lửa Windows đã tắt chưa?');
    } on TimeoutException catch (e) {
      print('⏰ Request timeout: $e');
      throw Exception('Yêu cầu quá thời gian chờ.\n'
          'Vui lòng:\n'
          '1. Kiểm tra tốc độ mạng\n'
          '2. Thử lại sau');
    } catch (e) {
      print('❌ Other error: $e');
      throw Exception('Có lỗi xảy ra: $e');
    } finally {
      client.close();
    }
  }
}
