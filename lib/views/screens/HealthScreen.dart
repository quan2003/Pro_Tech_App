import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'AboutUsScreen.dart';
import 'AccountDataScreen.dart';
import 'AddMedicationScreen.dart';
import 'BulletinBoardScreen.dart';
import 'CookiePolicyScreen.dart';
import 'FirstDayIntroduction.dart';
import 'HomeScreen.dart';
import 'MedicineScreen.dart';
import 'ChatScreen.dart';
import 'PrivacyPolicyScreen.dart';
import 'ProfileScreen.dart';
import '../Routes/AppRoutes.dart';
import 'TearmsAndConditionsScreen.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sức khoẻ của tôi"),
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
              // Implement the functionality for this button
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
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildWeightCard(),
                  const SizedBox(height: 16),
                  _buildMedicationCard(),
                  const SizedBox(height: 16),
                  _buildHealthRecordCard(),
                ],
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
        initialActiveIndex: 1,
        onTap: (int index) {
          _onItemTapped(index, context);
        },
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
            leading: const Icon(Icons.person),
            title: const Text("Hồ sơ"),
            onTap: () {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Get.to(() => ProfileScreen(userId: user.uid));
              } else {
                Get.snackbar('Lỗi', 'Vui lòng đăng nhập để xem hồ sơ.');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info), // App version icon
            title: const Text('Phiên bản ứng dụng'),
            onTap: () {
              // Logic for displaying app version
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle), // Account and data icon
            title: const Text('Tài khoản & dữ liệu'),
            onTap: () {
              Get.to(() => const AccountDataScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.language), // Language icon
            title: const Text('Ngôn ngữ'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.public), // Country icon
            title: const Text('Quốc gia'),
            onTap: () {
              // Logic for changing country settings
            },
          ),
          const Divider(), // Add a divider to separate sections
          // Health Section
          ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: const Text('Tình trạng sức khỏe'),
            onTap: () {
              // Navigate to Health Status
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Kế hoạch sức khỏe'),
            onTap: () {
              // Navigate to Health Plan
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_hospital),
            title: const Text('Bệnh viện / bác sĩ'),
            onTap: () {
              // Navigate to Hospitals/Doctors
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Đơn vị'),
            onTap: () {
              // Navigate to Health Units
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Hướng dẫn sức khỏe'),
            onTap: () {
              // Navigate to Health Guidance
            },
          ),

          // Access Permissions Section
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Thông báo'),
            onTap: () {
              // Navigate to Notification Settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.bluetooth),
            title: const Text('Thiết bị Bluetooth'),
            onTap: () {
              // Get.to(() => FindDevicesScreen());
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
          // Add more ListTiles for other drawer items
        ],
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        // Already on HealthScreen
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MedicineScreen()),
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BulletinBoardScreen()),
        );
        break;
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<String>(
        future: _fetchUserName(),
        builder: (context, snapshot) {
          String userName = snapshot.data ?? 'Khách';
          String formattedDate =
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
          String formattedTime = DateFormat('HH:mm').format(DateTime.now());

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Xin chào, $userName!",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '$formattedDate, $formattedTime',
                style: const TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildTabButton('Tổng quan', isSelected: true),
            const SizedBox(width: 8),
            _buildTabButton('Sống khỏe'),
            const SizedBox(width: 8),
            _buildTabButton('Chăm sóc'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, {bool isSelected = false}) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.pinkAccent : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text),
    );
  }

  Widget _buildWeightCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.monitor_weight, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Cân Nặng',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Chip(
                  label: const Text('BÌNH THƯỜNG'),
                  backgroundColor: Colors.green[100],
                  labelStyle: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('19 THÁNG 9 15:15',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('62 kg',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('+0 kg', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const Text('60 NGÀY TRƯỚC', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('medications')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        List<DocumentSnapshot> medications = snapshot.data?.docs ?? [];
        int totalPills = 0;
        int remainingPills = 0;

        for (var med in medications) {
          Map<String, dynamic> data = med.data() as Map<String, dynamic>;
          // Safely get the 'quantity' value, converting to int if necessary
          int quantity = 0;
          var rawQuantity = data['quantity'];
          if (rawQuantity is int) {
            quantity = rawQuantity;
          } else if (rawQuantity is String) {
            quantity = int.tryParse(rawQuantity) ?? 0;
          }

          // Calculate taken pills based on 'schedules' array
          List<dynamic> schedules = data['schedules'] ?? [];
          int takenPills =
              schedules.where((schedule) => schedule['taken'] == true).length;

          totalPills += quantity;
          remainingPills += (quantity - takenPills);
        }

        double adherenceRate = totalPills > 0
            ? (totalPills - remainingPills) / totalPills * 100
            : 0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.medication, color: Colors.pinkAccent),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tuân thủ uống thuốc',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddMedicationScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      child: const Text(
                        'CẬP NHẬT',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TRUNG BÌNH 30 NGÀY',
                            style: TextStyle(color: Colors.grey)),
                        Text('${adherenceRate.toStringAsFixed(1)}%',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('TRONG HỘP',
                            style: TextStyle(color: Colors.grey)),
                        Text('$remainingPills còn lại',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthRecordCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.article, color: Colors.blue),
        title: const Text('Sổ theo dõi',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Xem tất cả lần đo của bạn'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
