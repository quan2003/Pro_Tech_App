import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'AboutUsScreen.dart';
import 'AccountDataScreen.dart';
import 'AppVersionPage.dart';
import 'CookiePolicyScreen.dart';
import 'FirstDayIntroduction.dart';
import 'HealthGuidelinesScreen.dart';
import 'HealthScreen.dart';
import 'HomeScreen.dart';
import 'MedicineScreen.dart';
import 'PostDetailScreen.dart';
import 'ChatScreen.dart';
import 'PrivacyPolicyScreen.dart';
import 'ProfileScreen.dart';
import '../Routes/AppRoutes.dart';
import 'SettingsScreen.dart';
import 'TearmsAndConditionsScreen.dart';

class BulletinBoardScreen extends StatefulWidget {
  const BulletinBoardScreen({super.key});

  @override
  _BulletinBoardScreenState createState() => _BulletinBoardScreenState();
}

class _BulletinBoardScreenState extends State<BulletinBoardScreen> {
  int _selectedIndex = 3;
  Map<String, String?> selectedOptions = {};
  Map<String, bool> answeredQuizzes = {};

  Future<String> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return userDoc['name'] ?? 'Khách';
      }
    }
    return 'Khách';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HealthScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MedicineScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bảng tin"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Get.to(() => ChatScreen(userId: user.uid));
              } else {
                Get.snackbar('Lỗi', 'Vui lòng đăng nhập trước khi trò chuyện.');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_sharp),
            onPressed: () {
              // Implement add post functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Implement notification functionality
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts_quiz')
                    .where('isHidden', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Không có bài đăng nào.'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String docId = document.id;
                      if (data['isHidden'] == true) {
                        return Container(); // Return an empty container for hidden posts
                      }
                      String imageUrl = data['imageUrl'] ?? '';
                      String title = data['title'] ?? 'Không có tiêu đề';
                      String description = data['description'] ?? '';
                      Timestamp? timestamp = data['timestamp'] as Timestamp?;

                      if (description.isEmpty && timestamp != null) {
                        description = _generateTimeBasedDescription(timestamp);
                      }

                      List<String> options =
                          List<String>.from(data['options'] ?? []);
                      int responses = _parseNumericValue(data['responses']);
                      String? correctOption = data['correctAnswer']?.toString();
                      String? type = data['type'];
                      int views = _parseNumericValue(data['views']);
                      int commentCount =
                          _parseNumericValue(data['commentCount']);
                      int likeCount = _parseNumericValue(data['likeCount']);

                      return GestureDetector(
                        onTap: () {
                          if (type?.toLowerCase() == 'post') {
                            _incrementPostViews(docId);
                            _showPostDetails(docId);
                          }
                        },
                        child: _buildBulletinCard(
                          docId: docId,
                          imageAsset: imageUrl,
                          title: title,
                          description: description,
                          options: options,
                          responses: responses,
                          correctOption: correctOption,
                          type: type,
                          views: views,
                          likeCount: likeCount,
                          commentCount: commentCount,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        backgroundColor: Colors.white,
        activeColor: Colors.pinkAccent,
        color: Colors.grey,
        items: const [
          TabItem(icon: Icons.home, title: 'Trang chủ'),
          TabItem(icon: Icons.favorite, title: 'Sức khoẻ'),
          TabItem(icon: Icons.medication, title: 'Thuốc'),
          TabItem(icon: Icons.forum, title: 'Bảng tin'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          FutureBuilder<String>(
            future: _fetchUserName(),
            builder: (context, snapshot) {
              String userName = snapshot.data ?? 'Khách';
              User? user = FirebaseAuth.instance.currentUser;
              return UserAccountsDrawerHeader(
                accountName: Text(userName),
                accountEmail: Text(user?.email ?? 'Không có email'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person), // Profile Icon
            title: const Text('Hồ sơ'),
            onTap: () {
              // Navigate to the profile screen
              Get.to(() => const ProfileScreen(
                    userId: '',
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info), // App version icon
            title: const Text('Phiên bản ứng dụng'),
            onTap: () {
              Get.to(() => const AppVersionPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle), // Account and data icon
            title: const Text('Tài khoản & dữ liệu'),
            onTap: () {
              Get.to(() => const AccountDataScreen());
            },
          ),
          const Divider(),
          // Health Section
          ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: const Text('Tình trạng sức khỏe'),
            onTap: () {
              Get.toNamed(AppRoutes.HEALTH_DASHBOARD);
            },
          ),
          ListTile(
            leading: const Icon(Icons.app_shortcut),
            title: const Text('Ứng dụng sức khỏe'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Hướng dẫn sức khỏe'),
            onTap: () {
              Get.to(() => const HealthGuidelinesScreen());
            },
          ),

          // Access Permissions Section
          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Cài đặt'),
            onTap: () {
              Get.to(() => const SettingsScreen());
            },
          ),

          // Introduction and Information Section
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Về chúng tôi'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Giới thiệu về Ngày Đầu Tiên'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Firstdayintroduction()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.rule),
            title: const Text('Điều khoản & điều kiện'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TermsAndConditions()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Chính sách bảo mật'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Quy tắc Trò chơi hóa'),
            onTap: () {
              // Gamification Rules
            },
          ),
          ListTile(
            leading: const Icon(Icons.cookie),
            title: const Text('Chính sách Cookie'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CookiePolicyScreen()),
              );
            },
          ),

          // Logout Section
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Get.offNamed(AppRoutes.SIGNINSCREEN);
            },
          ),
          // Add other ListTiles as in HealthScreen
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Get.offNamed(AppRoutes.SIGNINSCREEN);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<String>(
      future: _fetchUserName(),
      builder: (context, snapshot) {
        String userName = snapshot.data ?? 'Khách';
        String formattedDate =
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
        String formattedTime = DateFormat('HH:mm').format(DateTime.now());

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Xin chào, $userName!",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$formattedDate, $formattedTime',
                style: const TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  String _generateTimeBasedDescription(Timestamp timestamp) {
    DateTime postTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(postTime);

    if (difference.inMinutes < 1) {
      return 'Pro - Tech: Vừa xong';
    } else if (difference.inMinutes < 60) {
      return 'Pro - Tech: ${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return 'Pro - Tech: ${difference.inHours} giờ trước';
    } else {
      return 'Pro - Tech: ${difference.inDays} ngày trước';
    }
  }

  int _parseNumericValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is List && value.isNotEmpty) {
      return _parseNumericValue(value.first);
    }
    return 0;
  }

  Widget _buildBulletinCard({
    required String docId,
    String? imageAsset,
    required String title,
    required String description,
    required List<String> options,
    int responses = 0,
    String? correctOption,
    String? type,
    int views = 0,
    int likeCount = 0,
    int commentCount = 0,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageAsset != null && imageAsset.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error);
                  },
                ),
              ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (type?.toLowerCase() == 'quiz')
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    children: options.asMap().entries.map((entry) {
                      int index = entry.key;
                      String option = entry.value;

                      bool isCorrect =
                          int.tryParse(correctOption ?? '') == index;
                      bool isSelected = selectedOptions[docId] == option;
                      bool hasAnswered = answeredQuizzes[docId] ?? false;

                      return GestureDetector(
                        onTap: () {
                          if (!hasAnswered) {
                            setState(() {
                              selectedOptions[docId] = option;
                              answeredQuizzes[docId] = true;
                            });
                            _incrementQuizResponses(docId);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12.0),
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            color: hasAnswered
                                ? (isCorrect
                                    ? Colors.green[100]
                                    : (isSelected
                                        ? Colors.red[100]
                                        : Colors.white))
                                : (isSelected
                                    ? Colors.blue[100]
                                    : Colors.white),
                            border: Border.all(
                              color: hasAnswered
                                  ? (isCorrect
                                      ? Colors.green
                                      : (isSelected ? Colors.red : Colors.grey))
                                  : (isSelected ? Colors.blue : Colors.grey),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              if (hasAnswered && (isCorrect || isSelected))
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: hasAnswered
                                        ? (isCorrect
                                            ? Colors.green
                                            : (isSelected
                                                ? Colors.red
                                                : Colors.black))
                                        : (isSelected
                                            ? Colors.blue
                                            : Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            if (type?.toLowerCase() == 'post') ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Text('$likeCount lượt thích',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.comment, color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Text('$commentCount bình luận',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              type?.toLowerCase() == 'quiz'
                  ? '$responses người đã trả lời'
                  : '$views lượt xem',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDetails(String docId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: docId),
      ),
    );
  }

  void _incrementQuizResponses(String docId) {
    FirebaseFirestore.instance
        .collection('posts_quiz')
        .doc(docId)
        .update({'responses': FieldValue.increment(1)});
  }

  void _incrementPostViews(String docId) {
    FirebaseFirestore.instance
        .collection('posts_quiz')
        .doc(docId)
        .update({'views': FieldValue.increment(1)});
  }
}
