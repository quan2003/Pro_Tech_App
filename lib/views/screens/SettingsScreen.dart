import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/SettingsProvider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Scaffold(
          appBar: _buildAppBar(settings),
          // Wrap với SingleChildScrollView để cho phép scroll khi nội dung overflow
          body: SingleChildScrollView(
            child: _buildBody(settings),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(SettingsProvider settings) {
    return AppBar(
      title: Text(
        'Cài đặt',
        style: TextStyle(fontSize: 20 * settings.fontSize),
      ),
      leading: const BackButton(),
    );
  }

  Widget _buildBody(SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Sử dụng MainAxisSize.min
        children: [
          _buildThemeSection(settings),
          const Divider(),
          _buildFontSizeSection(settings),
          const Divider(height: 32),
          _buildPreviewSection(settings),
        ],
      ),
    );
  }

  Widget _buildThemeSection(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Thêm dòng này
      children: [
        _buildSectionHeader('Giao diện', settings),
        SwitchListTile(
          title: Text(
            'Chế độ tối',
            style: TextStyle(fontSize: 16 * settings.fontSize),
          ),
          subtitle: Text(
            'Bật để sử dụng giao diện tối',
            style: TextStyle(fontSize: 14 * settings.fontSize),
          ),
          value: settings.isDarkMode,
          onChanged: (value) => settings.toggleTheme(),
        ),
      ],
    );
  }

  Widget _buildFontSizeSection(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Thêm dòng này
      children: [
        _buildSectionHeader('Cỡ chữ', settings),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text('A', style: TextStyle(fontSize: 14 * settings.fontSize)),
              Expanded(
                child: Slider(
                  value: settings.fontSize,
                  min: 0.8,
                  max: 1.4,
                  divisions: 3,
                  label: _getFontSizeLabel(settings.fontSize),
                  onChanged: (value) => settings.setFontSize(value),
                ),
              ),
              Text('A', style: TextStyle(fontSize: 24 * settings.fontSize)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Điều chỉnh cỡ chữ để dễ đọc hơn',
            style: TextStyle(
              fontSize: 14 * settings.fontSize,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Thêm dòng này
      children: [
        _buildSectionHeader('Xem trước', settings),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tiêu đề mẫu',
                    style: TextStyle(
                      fontSize: 20 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đây là đoạn văn mẫu để bạn có thể xem trước kích thước chữ. '
                    'Hãy điều chỉnh thanh trượt ở trên để có được kích thước phù hợp với nhu cầu của bạn.',
                    style: TextStyle(fontSize: 16 * settings.fontSize),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18 * settings.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getFontSizeLabel(double size) {
    if (size <= 0.8) return 'Nhỏ';
    if (size <= 1.0) return 'Vừa';
    if (size <= 1.2) return 'Lớn';
    return 'Rất lớn';
  }
}
