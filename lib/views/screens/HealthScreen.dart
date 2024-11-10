import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../controller/health_service.dart';
import 'AboutUsScreen.dart';
import 'AccountDataScreen.dart';
import 'AddMedicationScreen.dart';
import 'AppVersionPage.dart';
import 'BulletinBoardScreen.dart';
import 'CookiePolicyScreen.dart';
import 'FirstDayIntroduction.dart';
import 'HealthDashboardScreen.dart';
import 'HealthGuidelinesScreen.dart';
import 'HomeScreen.dart';
import 'MedicineScreen.dart';
import 'ChatScreen.dart';
import 'PrivacyPolicyScreen.dart';
import 'ProfileScreen.dart';
import '../Routes/AppRoutes.dart';
import 'SettingsScreen.dart';
import 'TearmsAndConditionsScreen.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final HealthService _healthService = HealthService();
  Map<String, dynamic> _healthData = {};
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _initializeHealthService();
  }

  Future<void> _initializeHealthService() async {
    setState(() => _isLoading = true);
    try {
      // Khởi tạo health service
      bool initialized = await _healthService.initialize();
      if (!initialized) {
        print("Failed to initialize health service");
        return;
      }

      // Yêu cầu quyền truy cập
      bool authorized = await _healthService.requestAuthorization();
      if (!authorized) {
        print("Health data access not authorized");
        return;
      }

      // Fetch dữ liệu
      await _fetchHealthData();
    } catch (e) {
      print('Error initializing health service: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchHealthData() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    try {
      Map<String, dynamic> data = await _healthService.fetchAllHealthData();

      setState(() {
        _healthData = data;
      });
      print('Fetched health data: $_healthData'); // Debug log
    } catch (e) {
      print('Error fetching health data: $e');
    }
  }

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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildWeightCard(),
                  const SizedBox(height: 16),
                  _buildStepCountCard(), // Step count card
                  const SizedBox(height: 16),
                  _buildSleepManagementCard(), // Sleep management card
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
    final theme = Theme.of(context);
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
            title: Text("Hồ sơ", style: theme.textTheme.bodyLarge),
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
          // Add more ListTiles for other drawer items
        ],
      ),
    );
  }

  void _onItemTapped(int index, BuildContext constext) {
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
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Debug log
    print('Building weight card with data: ${_healthData['weight']}');

    // Lấy dữ liệu cân nặng
    num? currentWeight = _healthData['weight']?['current_weight'];
    String weightStatus = _healthData['weight']?['status'] ?? 'CHƯA CÓ';
    Color statusColor = Colors.grey;

    // Xác định màu dựa trên BMI
    if (_healthData['weight']?['bmi'] != null) {
      double bmi = _healthData['weight']!['bmi'];
      if (bmi < 18.5) {
        weightStatus = 'THIẾU CÂN';
        statusColor = Colors.orange;
      } else if (bmi < 24.9) {
        weightStatus = 'BÌNH THƯỜNG';
        statusColor = Colors.green;
      } else if (bmi < 29.9) {
        weightStatus = 'THỪA CÂN';
        statusColor = Colors.orange;
      } else {
        weightStatus = 'BÉO PHÌ';
        statusColor = Colors.red;
      }
    }

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HealthDashboardScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.monitor_weight, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Cân Nặng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      weightStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              if (_healthData['weight']?['date'] != null)
                Text(
                  DateFormat('dd MMMM HH:mm').format(
                    DateTime.parse(_healthData['weight']!['date']),
                  ),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentWeight != null
                        ? '${currentWeight.toStringAsFixed(1)} kg'
                        : 'Chưa có dữ liệu',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_healthData['weight']?['previous_weight'] != null)
                    Text(
                      _getWeightChange(
                        currentWeight,
                        _healthData['weight']!['previous_weight'],
                      ),
                      style: TextStyle(
                        color: _getWeightChangeColor(
                          currentWeight,
                          _healthData['weight']!['previous_weight'],
                        ),
                      ),
                    ),
                ],
              ),
              if (_healthData['weight']?['previous_date'] != null)
                Text(
                  _getDaysDifference(
                    DateTime.parse(_healthData['weight']!['previous_date']),
                  ),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              if (_healthData['weight']?['bmi'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  'BMI: ${_healthData['weight']!['bmi'].toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getWeightChange(num? current, num? previous) {
    if (current == null || previous == null) return '';
    num change = current - previous;
    return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} kg';
  }

  Color _getWeightChangeColor(num? current, num? previous) {
    if (current == null || previous == null) return Colors.grey;
    return current >= previous ? Colors.red : Colors.green;
  }

  String _getDaysDifference(DateTime previousDate) {
    final difference = DateTime.now().difference(previousDate).inDays;
    return '$difference NGÀY TRƯỚC';
  }

  Widget _buildStepCountCard() {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Access data from _healthData
    int currentSteps = _healthData['steps'] ?? 0;
    int averageSteps = _healthData['steps_average'] ?? 0;
    int stepsGoal = _healthData['steps_goal'] ?? 10000;

    // Calculate activity level
    String activityLevel = '';
    Color activityColor = Colors.grey;
    if (currentSteps >= 10000) {
      activityLevel = 'CAO';
      activityColor = Colors.green;
    } else if (currentSteps >= 5000) {
      activityLevel = 'TRUNG BÌNH';
      activityColor = Colors.orange;
    } else {
      activityLevel = 'THẤP';
      activityColor = Colors.red;
    }

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HealthDashboardScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_walk, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Bước chân',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: activityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      activityLevel,
                      style: TextStyle(
                        color: activityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HÔM NAY',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$currentSteps bước',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'TRUNG BÌNH 30 NGÀY',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$averageSteps bước',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: currentSteps / stepsGoal,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(activityColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mục tiêu: $stepsGoal bước',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepManagementCard() {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final sleepData = _healthData['sleep'];
    String sleepHours = 'Chưa có dữ liệu';
    String startTime = '--:--';
    String endTime = '--:--';
    String qualityLevel = 'CHƯA CÓ';
    Color qualityColor = Colors.grey;

    if (sleepData != null) {
      try {
        // Parse sleep duration
        double hours = double.parse(sleepData['value']);
        int wholeHours = hours.floor();
        int minutes = ((hours - wholeHours) * 60).round();
        sleepHours = '$wholeHours h ${minutes.toString().padLeft(2, '0')} m';

        // Parse start and end times
        if (sleepData['start_time'] != null && sleepData['end_time'] != null) {
          DateTime start = DateTime.parse(sleepData['start_time']);
          DateTime end = DateTime.parse(sleepData['end_time']);
          startTime = DateFormat('HH:mm').format(start);
          endTime = DateFormat('HH:mm').format(end);
        }

        // Determine sleep quality based on duration
        if (hours >= 7) {
          qualityLevel = 'TỐT';
          qualityColor = Colors.green;
        } else if (hours >= 6) {
          qualityLevel = 'VỪA PHẢI';
          qualityColor = Colors.orange;
        } else {
          qualityLevel = 'KÉM';
          qualityColor = Colors.red;
        }
      } catch (e) {
        print('Error processing sleep data: $e');
      }
    }

    return Card(
      color: Colors.blue.shade50, // Light blue background for sleep card
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HealthDashboardScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bed, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Quản lý giấc ngủ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: qualityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      qualityLevel,
                      style: TextStyle(
                        color: qualityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'THỜI GIAN NGỦ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          sleepHours,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Từ $startTime đến $endTime',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _calculateSleepProgress(sleepData),
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(qualityColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mục tiêu: 8 giờ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '8h',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper method to calculate sleep progress
  double _calculateSleepProgress(Map<String, dynamic>? sleepData) {
    if (sleepData == null || sleepData['value'] == null) return 0.0;
    try {
      double hours = double.parse(sleepData['value']);
      // Limit progress to 100% even if sleep is more than 8 hours
      return (hours / 8.0).clamp(0.0, 1.0);
    } catch (e) {
      print('Error calculating sleep progress: $e');
      return 0.0;
    }
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
        int totalQuantity = 0;
        int totalScheduledDoses = 0;
        int totalTakenDoses = 0;

        DateTime now = DateTime.now();
        DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));

        for (var med in medications) {
          Map<String, dynamic> data = med.data() as Map<String, dynamic>;

          // Tính tổng quantity
          int quantity = 0;
          var rawQuantity = data['quantity'];
          if (rawQuantity is int) {
            quantity = rawQuantity;
          } else if (rawQuantity is String) {
            quantity = int.tryParse(rawQuantity) ?? 0;
          }
          totalQuantity += quantity;

          // Lấy lịch uống thuốc
          List<dynamic> schedules = data['schedules'] ?? [];

          for (var schedule in schedules) {
            // Kiểm tra null và type safety cho dateTime
            if (schedule != null && schedule['dateTime'] != null) {
              try {
                DateTime? scheduleDate;
                var dateTimeData = schedule['dateTime'];

                if (dateTimeData is Timestamp) {
                  scheduleDate = dateTimeData.toDate();
                } else if (dateTimeData is String) {
                  scheduleDate = DateTime.tryParse(dateTimeData);
                }

                if (scheduleDate != null &&
                    scheduleDate.isAfter(thirtyDaysAgo) &&
                    scheduleDate.isBefore(now)) {
                  totalScheduledDoses++;
                  if (schedule['taken'] == true) {
                    totalTakenDoses++;
                  }
                }
              } catch (e) {
                print('Error processing schedule: $e');
                continue;
              }
            }
          }
        }

        // Tính tỉ lệ tuân thủ trong 30 ngày
        double adherenceRate = totalScheduledDoses > 0
            ? (totalTakenDoses / totalScheduledDoses * 100)
            : 0;

        return Card(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddMedicationScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        const Icon(Icons.medication,
                            color: Colors.pinkAccent, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Tuân thủ uống thuốc',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Chip thay thế cho ElevatedButton
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getAdherenceColor(adherenceRate),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getAdherenceText(adherenceRate),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TRUNG BÌNH 30 NGÀY',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${adherenceRate.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'TRONG HỘP',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '$totalQuantity viên',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper function để lấy màu dựa trên tỉ lệ tuân thủ
  Color _getAdherenceColor(double rate) {
    if (rate >= 80) {
      return Colors.green;
    } else if (rate >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // Helper function để lấy text hiển thị dựa trên tỉ lệ tuân thủ
  String _getAdherenceText(double rate) {
    if (rate >= 80) {
      return 'CAO';
    } else if (rate >= 50) {
      return 'TRUNG BÌNH';
    } else {
      return 'THẤP';
    }
  }

  Widget _buildHealthRecordCard() {
    return Card(
      child: InkWell(
        onTap: () {
          // Handle navigation
        },
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.article, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sổ theo dõi',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Xem tất cả lần đo của bạn',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
