import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Firstdayintroduction extends StatelessWidget {
  const Firstdayintroduction({super.key});

  void _launchURL() async {
    const url = 'https://www.google.com.vn/'; // Thay thế bằng URL thật của bạn
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Nền ngoài màu trắng ấm
      body: SafeArea(
        child: ListView(
          children: [
            // Header Row: Back button and Avatar (logo)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        'https://cdn-icons-png.flaticon.com/512/11865/11865326.png'), // Đường dẫn ảnh logo
                  ),
                ],
              ),
            ),

            // Title "Về chúng tôi"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đối tác',
                    style: TextStyle(
                      fontSize: 22, // Điều chỉnh kích thước text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Xem thêm đối tác của chúng tôi và câu chuyện của họ',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600]), // Điều chỉnh màu text
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card with Mission Statement
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Giảm padding để làm card nhỏ hơn
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 3, // đổ bóng ngoài viền
                child: Container(
                  constraints: const BoxConstraints(
                      maxWidth:
                          600), // Giới hạn chiều rộng của thẻ để thẻ hẹp hơn
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title: Sứ mệnh của chúng tôi
                      const Text(
                        'Giới thiệu ngày đầu tiên',
                        style: TextStyle(
                          fontSize: 18, // Điều chỉnh kích thước text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://cdn-icons-png.flaticon.com/512/11865/11865326.png', // Đường dẫn ảnh minh họa
                          height:
                              180, // Giữ nguyên chiều cao của ảnh để cân đối với card
                          width: double.infinity,
                          fit: BoxFit.cover, //Hình ảnh bao phủ toàn bộ width
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Ra mắt cộng đồng từ năm 2016 dưới sự bảo trợ của Hội Tim mạch học Việt Nam và Hội Nội Tiết và Đái Tháo Đường Việt Nam. Dự án Ngày đầu tiên ra đời với mong muốn giúp cộng đồng hiểu rõ hơn về 3 căn bệnh thầm lặng: Tăng Huyết Áp, Đái Tháo Đường và Đau thắt ngực, nhận biết các nguy cơ và cách phòng tránh.',
                        style: TextStyle(
                          fontSize: 16, // Kích thước chữ hợp lý
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Button to access the website
                      InkWell(
                        onTap: _launchURL, // Gọi hàm mở URL khi nhấn vào nút
                        child: const Text(
                          'Truy cập website Ngày Đầu Tiên',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.pink,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            // Card with Mission Statement
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Giảm padding để làm card nhỏ hơn
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 3, // đổ bóng ngoài viền
                child: Container(
                  constraints: const BoxConstraints(
                      maxWidth:
                          600), // Giới hạn chiều rộng của thẻ để thẻ hẹp hơn
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title: Sứ mệnh của chúng tôi
                      const Text(
                        'Sứ mệnh',
                        style: TextStyle(
                          fontSize: 18, // Điều chỉnh kích thước text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Đoạn văn bản mô tả
                      Text(
                        'Mỗi ngày trôi qua là một ngày không ngừng cố gắng của dự án chỉ với một sứ mệnh duy nhất là giúp người bệnh Tăng huyết áp, Đái tháo đường và Đau thắt ngực tuân thủ điều trị dễ dàng hơn, sống khỏe hơn cùng bệnh, giúp cộng đồng có nhận thức đúng đắn về bệnh, tầm soát và kiểm soát nguy cơ tốt hơn. Đến nay, dự án đã được đông đảo bác sĩ công nhận là một cổng thông tin chính thống dành cho Tăng huyết áp, Đái tháo đường và Đau thắt ngực. Cũng như là điểm đến cho rất nhiều bệnh nhân, gia đình người bệnh mỗi khi có bất kỳ khó khăn nào khi chiến đấu với các căn bệnh mạn tính này.',
                        style: TextStyle(
                          fontSize: 16, // Kích thước chữ hợp lý
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(
                          height: 16), // Khoảng cách giữa văn bản và hình ảnh

                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://cdn-icons-png.flaticon.com/512/11865/11865326.png', // Đường dẫn ảnh minh họa
                          height:
                              180, // Giữ nguyên chiều cao của ảnh để cân đối với card
                          width: double.infinity,
                          fit: BoxFit.cover, //Hình ảnh bao phủ toàn bộ width
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Dự án nhằm 2 mục tiêu chiến lược giúp cho bệnh nhân Việt Nam được CHẨN ĐOÁN SỚM và KIỂM SOÁT TỐT bệnh của mình.',
                        style: TextStyle(
                          fontSize: 16, // Kích thước chữ hợp lý
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Card with Mission Statement
          ],
        ),
      ),
    );
  }
}
