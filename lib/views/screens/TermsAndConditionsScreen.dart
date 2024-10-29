import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

import 'HomeFirst.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  _TermsAndConditionsScreenState createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen>
    with SingleTickerProviderStateMixin {
  bool _isAgreed = false;

  final String _termsText = """
# Điều khoản và Dịch vụ của Health

## 1. Giới thiệu

Chào mừng bạn đến với Health! Đây là các điều khoản và dịch vụ áp dụng cho việc sử dụng ứng dụng Health.

## 2. Sử dụng Ứng dụng

- Bạn đồng ý sử dụng ứng dụng một cách hợp pháp và không sử dụng cho bất kỳ mục đích nào vi phạm pháp luật.
- Bạn không được phép sao chép, phân phối hoặc biến đổi ứng dụng mà không có sự cho phép của chúng tôi.

## 3. Bảo mật Thông tin

- Chúng tôi cam kết bảo vệ thông tin cá nhân của bạn.
- Thông tin của bạn sẽ được lưu trữ an toàn và không chia sẻ với bên thứ ba mà không có sự đồng ý của bạn.

## 4. Thay đổi Điều khoản

Health.io có quyền thay đổi các điều khoản này bất cứ lúc nào. Bạn sẽ được thông báo về bất kỳ thay đổi nào thông qua ứng dụng hoặc email.

## 5. Liên hệ

Nếu bạn có bất kỳ câu hỏi nào, vui lòng liên hệ với chúng tôi tại [support@health.io](mailto:support@health.io).

---

Cảm ơn bạn đã sử dụng Health.io!
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Điều khoản và Dịch vụ"),
        backgroundColor: Colors.purple.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Thêm biểu tượng ở đầu trang
            Row(
              children: [
                const Icon(
                  Icons.article,
                  color: Colors.purpleAccent,
                  size: 40,
                ),
                const SizedBox(width: 10),
                Text(
                  "Điều khoản và Dịch vụ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Nội dung điều khoản và dịch vụ với khả năng cuộn
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade200.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Markdown(
                  data: _termsText,
                  styleSheet: MarkdownStyleSheet(
                    h1: TextStyle(
                      color: Colors.purple.shade800,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    h2: TextStyle(
                      color: Colors.purple.shade700,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    p: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    listBullet: TextStyle(
                      color: Colors.purple.shade800,
                      fontSize: 16,
                    ),
                    a: const TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Checkbox và label
            Row(
              children: [
                Checkbox(
                  value: _isAgreed,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAgreed = value ?? false;
                    });
                  },
                  activeColor: Colors.purpleAccent,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAgreed = !_isAgreed;
                      });
                    },
                    child: const Text(
                      "Tôi đồng ý với các Điều khoản và Dịch vụ.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Nút "Tiếp tục"
            ElevatedButton(
              onPressed: () {
                if (_isAgreed) {
                  // Sử dụng PageRouteBuilder để điều hướng với animation
                  Navigator.of(context).push(_createRoute());
                } else {
                  // Hiển thị cảnh báo nếu chưa đồng ý
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Bạn cần đồng ý với Điều khoản và Dịch vụ để tiếp tục."),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _isAgreed ? Colors.purpleAccent : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation:
                    _isAgreed ? 5 : 0, // Thêm bóng đổ khi nút được kích hoạt
              ),
              child: const Text(
                "Tiếp tục",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade200,
    );
  }

  // Tạo route với animation
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const HomeFirst(), // Thay bằng màn hình bạn muốn chuyển tới
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Animation bắt đầu từ bên phải
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
