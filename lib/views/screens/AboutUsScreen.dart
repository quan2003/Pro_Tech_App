import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
                        'https://bacsigiadinhhanoi.vn/wp-content/uploads/2021/09/kham-benh-nguoi-gia.jpg'), // Đường dẫn ảnh logo
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
                    'Về chúng tôi',
                    style: TextStyle(
                      fontSize: 22, // Điều chỉnh kích thước text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tìm hiểu về những người làm việc hằng ngày để hỗ trợ chúng tôi trong sứ mệnh của mình',
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
                        'Sứ mệnh của chúng tôi',
                        style: TextStyle(
                          fontSize: 18, // Điều chỉnh kích thước text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                        'assets/images/AboutUs_1.png', // Đường dẫn tới ảnh trong assets
                          height:
                              180, // Giữ nguyên chiều cao của ảnh để cân đối với card
                          width: double.infinity,
                          fit: BoxFit.cover, //Hình ảnh bao phủ toàn bộ width
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Sứ mệnh của Elfie là khuyến khích người lớn trên khắp thế giới theo dõi sức khỏe của họ hàng ngày.',
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
                        'Niềm tin của chúng tôi',
                        style: TextStyle(
                          fontSize: 18, // Điều chỉnh kích thước text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Đoạn văn bản mô tả
                      Text(
                        'Niềm tin của Elfie là chúng ta cần khuyến khích người trưởng thành tự giám sát.\n\n'
                        'Xét thấy rằng nhiều người trưởng thành có thể không thực hiện đầy đủ các thói quen chăm sóc sức khỏe của mình, và nhiều người cảm thấy khó khăn khi duy trì những thay đổi tích cực trong lối sống, rõ ràng rằng việc nâng cao động lực là chìa khóa để thúc đẩy sức khỏe tổng thể và khuyến khích lối sống lành mạnh, năng động hơn cho tất cả mọi người.\n\n'
                        'Điều này phù hợp với tất cả mọi người, cả người khỏe mạnh lẫn người thiếu sức khỏe (ví dụ, 50% người trưởng thành không biết về bệnh mãn tính của mình và gần 50% không tuân thủ điều trị).',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700], // Màu chữ
                        ),
                      ),
                      const SizedBox(
                          height: 16), // Khoảng cách giữa văn bản và hình ảnh

                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                        'assets/images/AboutUs_1.png', // Đường dẫn tới ảnh trong assets
                          height:
                              180, // Giữ nguyên chiều cao của ảnh để cân đối với card
                          width: double.infinity,
                          fit: BoxFit.cover, //Hình ảnh bao phủ toàn bộ width
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ngoài ra, chúng tôi tin tưởng mạnh mẽ rằng để đạt được thành công trong việc thúc đẩy lối sống lành mạnh, giành chiến thắng trong lĩnh vực chăm sóc sức khỏe, chúng tôi cần liên minh với các bên liên quan chính của cộng đồng chăm sóc sức khỏe và hệ sinh thái chăm sóc sức khỏe: cơ quan y tế công cộng, huấn luyện viên chăm sóc sức khỏe, chuyên gia thể dục và dinh dưỡng, chuyên gia chăm sóc sức khỏe và các tổ chức cộng đồng, nhà sản xuất dược phẩm và thiết bị.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5, // Điều chỉnh khoảng cách giữa các dòng
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
                        'Đội ngũ của chúng tôi',
                        style: TextStyle(
                          fontSize: 18, // Điều chỉnh kích thước text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Sứ mệnh của Elfie là khuyến khích người lớn trên khắp thế giới theo dõi sức khỏe của họ hàng ngày.\n'
                        'Đội ngũ Elfie bao gồm các chuyên gia dinh dưỡng, người dùng, bệnh nhân, kỹ sư và chuyên gia chăm sóc sức khỏe tham gia xây dựng nội dung của ứng dụng.\n'
                        'Dưới sự dẫn dắt của hội đồng khoa học của Elfie, họ cung cấp thông tin định tính và cập nhật về sức khỏe, phúc lợi và lối sống.',
                        style: TextStyle(
                          fontSize: 16, // Kích thước chữ hợp lý
                          color: Colors.grey[800],
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                        'assets/images/AboutUs_1.png', // Đường dẫn tới ảnh trong assets
                          height:
                              180, // Giữ nguyên chiều cao của ảnh để cân đối với card
                          width: double.infinity,
                          fit: BoxFit.cover, //Hình ảnh bao phủ toàn bộ width
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                         child: Image.asset(
                        'assets/images/AboutUs_1.png', // Đường dẫn tới ảnh trong assets
                          height:
                              180, // Giữ nguyên chiều cao của ảnh để cân đối với card
                          width: double.infinity,
                          fit: BoxFit.cover, //Hình ảnh bao phủ toàn bộ width
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      RichText(
                        text: TextSpan(
                          text:
                              'Hội đồng khoa học của chúng tôi được dẫn dắt bởi ',
                          style: TextStyle(
                            fontSize: 16, // Kích thước chữ hợp lý
                            color: Colors.grey[800],
                          ),
                          children: const [
                            TextSpan(
                              text: 'Giáo sư Mourad',
                              style: TextStyle(
                                fontWeight: FontWeight
                                    .bold, // In đậm chữ Giáo sư Mourad
                              ),
                            ),
                            TextSpan(
                              text: ' và ',
                            ),
                            TextSpan(
                              text: 'Giáo sư Berwanger.',
                              style: TextStyle(
                                fontWeight: FontWeight
                                    .bold, // In đậm chữ Giáo sư Berwanger
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Các chứng nhận',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Elfie được xác nhận bởi các hiệp hội y tế và tuân thủ bảo vệ dữ liệu bệnh nhân trên toàn thế giới.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Image.network(
                            'https://cdn-icons-png.flaticon.com/512/11865/11865326.png',
                            width: 50,
                            height: 50,
                          ),
                          Image.network(
                            'https://cdn-icons-png.flaticon.com/512/11865/11865326.png',
                            width: 50,
                            height: 50,
                          ),
                          Image.network(
                            'https://cdn-icons-png.flaticon.com/512/11865/11865326.png',
                            width: 50,
                            height: 50,
                          ),
                          Image.network(
                            'https://cdn-icons-png.flaticon.com/512/11865/11865326.png',
                            width: 50,
                            height: 50,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Giảm padding để làm card nhỏ hơn
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Về đối tác',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Để ứng dụng của chúng tôi miễn phí cho tất cả mọi người, Elfie hợp tác với các hiệp hội khoa học và công ty dược phẩm.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Các đối tác của chúng tôi không chịu trách nhiệm hoặc liên quan đến việc tài trợ hoặc tìm nguồn cung cấp phần thưởng của Elfie.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Viện nghiên cứu dược phẩm Servier là đối tác toàn cầu của Elfie.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Image.network(
                          'https://cdn-icons-png.flaticon.com/512/11865/11865326.png',
                          width: 100,
                          height: 50,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'SERVIER\nmoved by you',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
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
