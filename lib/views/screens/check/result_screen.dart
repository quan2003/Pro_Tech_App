import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResultScreen1 extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultScreen1({super.key, required this.result});

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Rủi ro rất cao':
        return Colors.red;
      case 'Rủi ro cao':
        return Colors.orange;
      case 'Rủi ro trung bình':
        return Colors.yellow[700]!;
      default:
        return Colors.green;
    }
  }

  Widget _buildRiskIndicator(
      BuildContext context, String riskLevel, double probability) {
    final riskColor = _getRiskColor(riskLevel);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: riskColor, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mức độ rủi ro:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              riskLevel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Xác suất:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(probability * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsList(
      BuildContext context, List<String> recommendations) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khuyến nghị sức khỏe:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...recommendations.map((recommendation) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          recommendation,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cung cấp giá trị mặc định cho các trường trong `result`
    final riskLevel = result['risk_level'] as String? ?? 'Không xác định';
    final probability = result['risk_probability'] as double? ?? 0.0;
    final recommendations = (result['advice'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['Không có khuyến nghị'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả dự đoán'),
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRiskIndicator(
              context,
              riskLevel,
              probability,
            ),
            const SizedBox(height: 24),
            _buildRecommendationsList(
              context,
              recommendations,
            ),
          ],
        ),
      ),
    );
  }
}
