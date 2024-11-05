// lib/controller/heart_disease_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class HeartDiseaseService {
  static const String baseUrl =
      'http://192.168.1.3:8000'; // Replace with your server's IP or domain

  Future<Map<String, dynamic>> predictHeartDisease({
    required double age,
    required int sex,
    required int chestPainType,
    required double restingBP,
    required double cholesterol,
    required int fastingBS,
    required int restingECG,
    required double maxHR,
    required int exerciseAngina,
    required double oldpeak,
    required int stSlope,
  }) async {
    final url = Uri.parse('$baseUrl/predict');

    final Map<String, dynamic> requestBody = {
      'Age': age,
      'Sex': sex,
      'ChestPainType': chestPainType,
      'RestingBP': restingBP,
      'Cholesterol': cholesterol,
      'FastingBS': fastingBS,
      'RestingECG': restingECG,
      'MaxHR': maxHR,
      'ExerciseAngina': exerciseAngina,
      'Oldpeak': oldpeak,
      'ST_Slope': stSlope,
    };

    print('Sending request to $url with data: $requestBody');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Decode the response with UTF-8 encoding to ensure special characters display correctly
        final decoded = utf8.decode(response.bodyBytes);
        return json.decode(decoded) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to predict heart disease: ${response.body}');
      }
    } catch (e) {
      print('Error details: $e');
      throw Exception('Error connecting to server: $e');
    }
  }
}
