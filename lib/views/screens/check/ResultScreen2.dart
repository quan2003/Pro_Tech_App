import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ResultScreen2 extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultScreen2({super.key, required this.result});

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const Text(
            'Kết quả phân tích',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
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
                      color: Colors.red[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(String riskLevel, double probability) {
    Color getRiskColor() {
      if (riskLevel.contains('rất cao')) return Colors.red[900]!;
      if (riskLevel.contains('cao')) return Colors.red[700]!;
      if (riskLevel.contains('trung bình')) return Colors.orange[700]!;
      return Colors.green[700]!;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: getRiskColor().withOpacity(0.3), width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: getRiskColor(),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  riskLevel,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: getRiskColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Xác suất:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${probability.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: getRiskColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceList(String adviceText) {
    final List<String> adviceList =
        adviceText.split('\n').where((line) => line.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Lời khuyên chi tiết:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        ...adviceList
            .map((advice) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _getAdviceIcon(advice),
                          color: _getAdviceColor(advice),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            advice.trim(),
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  IconData _getAdviceIcon(String advice) {
    if (advice.toLowerCase().contains('nguy cơ') ||
        advice.toLowerCase().contains('rủi ro')) {
      return Icons.warning_rounded;
    } else if (advice.toLowerCase().contains('tốt') ||
        advice.toLowerCase().contains('tiếp tục')) {
      return Icons.check_circle;
    } else if (advice.toLowerCase().contains('bmi') ||
        advice.toLowerCase().contains('cân')) {
      return Icons.monitor_weight;
    } else if (advice.toLowerCase().contains('tập') ||
        advice.toLowerCase().contains('thể dục')) {
      return Icons.directions_run;
    } else if (advice.toLowerCase().contains('ngủ')) {
      return Icons.bedtime;
    } else if (advice.toLowerCase().contains('thuốc')) {
      return Icons.smoke_free;
    } else if (advice.toLowerCase().contains('rượu')) {
      return Icons.no_drinks;
    } else if (advice.toLowerCase().contains('khám')) {
      return Icons.local_hospital;
    }
    return Icons.info;
  }

  Color _getAdviceColor(String advice) {
    if (advice.toLowerCase().contains('nguy cơ') ||
        advice.toLowerCase().contains('rủi ro')) {
      return Colors.red[700]!;
    } else if (advice.toLowerCase().contains('tốt') ||
        advice.toLowerCase().contains('tiếp tục')) {
      return Colors.green[700]!;
    } else if (advice.toLowerCase().contains('bmi') ||
        advice.toLowerCase().contains('cân')) {
      return Colors.blue[700]!;
    } else if (advice.toLowerCase().contains('tập') ||
        advice.toLowerCase().contains('thể dục')) {
      return Colors.orange[700]!;
    }
    return Colors.grey[700]!;
  }

  @override
  Widget build(BuildContext context) {
    if (result.isEmpty ||
        result['risk_level'] == null ||
        result['risk_probability'] == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('SCORE2'),
          centerTitle: true,
          backgroundColor: Colors.red[900],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitFadingCircle(
                color: Colors.red[900],
                size: 50.0,
              ),
              const SizedBox(height: 24),
              Text(
                'Đang phân tích dữ liệu...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final riskLevel = result['risk_level'].toString();
    final probability = result['risk_probability'] is num
        ? (result['risk_probability'] as num).toDouble()
        : double.tryParse(result['risk_probability'].toString()) ?? 0.0;
    final advice = result['advice']?.toString() ?? 'Không có lời khuyên';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SCORE2'),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepIndicator(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRiskCard(riskLevel, probability),
                  _buildAdviceList(advice),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
