import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool isAgreed = true; // Trạng thái đồng ý
  String policyText = ''; // Nơi lưu trữ nội dung của file txt
  List<TextSpan> formattedText = []; // Chứa nội dung đã được định dạng

  @override
  void initState() {
    super.initState();
    loadPrivacyPolicy(); // Gọi hàm load file
  }

  Future<void> loadPrivacyPolicy() async {
    // Đọc file txt từ thư mục assets
    final String response = await rootBundle.loadString('assets/images/privacy_policy.txt');
    
    // Parse và định dạng nội dung
    formatText(response);
  }

  // Hàm định dạng nội dung
  void formatText(String text) {
    List<TextSpan> spans = [];
    
    // Regular expression để tìm các mục lớn (I, II, III,...)
    final regex = RegExp(
      r'(I\. THÔNG TIN CHÚNG TÔI THU THẬP\.|II\. CÁC CÁCH CHÚNG TÔI SỬ DỤNG THÔNG TIN\.|III\. CÁC BÊN THỨ BA\.|IV\. BẢO MẬT THÔNG TIN\.|V\. THAY ĐỔI CHÍNH SÁCH\.|VI\. LIÊN HỆ CHÚNG TÔI\.)'
    );
    
    // Tách nội dung thành từng phần dựa trên regex
    final matches = text.split(regex);
    final titles = regex.allMatches(text).map((m) => m.group(0)).toList();

    for (int i = 0; i < matches.length; i++) {
      if (i == 0) {
        spans.add(TextSpan(text: matches[i], style: const TextStyle(fontSize: 16, color: Colors.black))); // Thêm phần nội dung trước mục I
      } else {
        // Thêm tiêu đề mục in đậm (I, II, III...)
        spans.add(TextSpan(
          text: titles[i - 1] ?? '', // Lấy tiêu đề từ danh sách titles
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ));
        
        // Thêm phần nội dung sau tiêu đề mục
        spans.add(TextSpan(
          text: matches[i],
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ));
      }
    }
    
    setState(() {
      formattedText = spans; // Cập nhật nội dung đã định dạng
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header Row: Back button and Avatar (logo)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); // Điều hướng quay lại trang trước
                    },
                  ),
                  // Avatar (logo)
                  const CircleAvatar(
                    radius: 32.0, // Kích thước avatar tương tự form mẫu
                    backgroundImage: NetworkImage(
                      'https://bacsigiadinhhanoi.vn/wp-content/uploads/2021/09/kham-benh-nguoi-gia.jpg',
                    ), // Đường dẫn ảnh logo
                  ),
                ],
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Chính sách bảo mật',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // Main content with scrolling
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị nội dung đã định dạng
                      RichText(
                        text: TextSpan(
                          children: formattedText,
                        ),
                      ),
                      const SizedBox(height: 16.0), // Khoảng cách trước button
                      // Button Row inside the scrollable area
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa toàn bộ nội dung trong hàng
                        children: [
                          const Text(
                            'Đồng ý chính sách',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8.0), // Khoảng cách giữa Text và Button
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isAgreed = !isAgreed; // Chuyển đổi trạng thái khi nhấn nút
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAgreed ? Colors.green : Colors.grey, // Màu thay đổi theo trạng thái
                            ),
                            child: Text(isAgreed ? 'Đồng ý' : 'Đồng ý'), // Text thay đổi theo trạng thái
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
