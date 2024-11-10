import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthGuidelinesScreen extends StatelessWidget {
  const HealthGuidelinesScreen({super.key});

  // Define URLs for each health metric
  final Map<String, String> _healthMetricUrls = const {
    'Huyết áp':
        'https://academic.oup.com/eurheartj/article/39/33/3021/5079119?login=false',
    'Đường huyết': 'https://www.cdc.gov/diabetes/diabetes-testing/',
    'Chỉ số HbA1c': 'https://www.cdc.gov/diabetes/diabetes-testing/',
    'Cholesterol':
        'https://www.heart.org/en/health-topics/cholesterol/about-cholesterol/what-your-cholesterol-levels-mean',
  };

  // Function to launch URLs
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),

              const SizedBox(height: 16),

              // Header Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hướng dẫn sức khoẻ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pro-Tech giúp bạn so sánh các chỉ số quan trọng của bạn với các hướng dẫn quốc gia mà bạn lựa chọn.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.note_alt_outlined,
                      size: 32,
                      color: Colors.blue[300],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Guidelines Links
              const Text(
                'Đến trang hướng dẫn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Health Metrics List with URL launch functionality
              _buildHealthMetricTile(
                icon: Icons.favorite,
                color: Colors.red,
                title: 'Huyết áp',
                onTap: () => _launchUrl(_healthMetricUrls['Huyết áp']!),
              ),
              _buildHealthMetricTile(
                icon: Icons.water_drop,
                color: Colors.blue,
                title: 'Đường huyết',
                onTap: () => _launchUrl(_healthMetricUrls['Đường huyết']!),
              ),
              _buildHealthMetricTile(
                icon: Icons.science,
                color: Colors.grey,
                title: 'Chỉ số HbA1c',
                onTap: () => _launchUrl(_healthMetricUrls['Chỉ số HbA1c']!),
              ),
              _buildHealthMetricTile(
                icon: Icons.opacity,
                color: Colors.amber,
                title: 'Cholesterol',
                onTap: () => _launchUrl(_healthMetricUrls['Cholesterol']!),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthMetricTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      onTap: onTap,
    );
  }
}
