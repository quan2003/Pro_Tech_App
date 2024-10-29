import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'BulletinBoardScreen.dart';
import 'CookiePolicyScreen.dart';
import 'FirstDayIntroduction.dart';
import 'HealthScreen.dart';
import 'MedicineScreen.dart';
import 'PrivacyPolicyScreen.dart';
import 'ProfileScreen.dart';
import '../Routes/AppRoutes.dart';
import 'package:intl/intl.dart';
import 'ChatScreen.dart';
import '../controller/BMIController.dart';
import 'AccountDataScreen.dart';
import 'AboutUsScreen.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../controller/StepTrackingService.dart';
import 'SleepTrackingScreen.dart';
import 'StepTrackerScreen.dart';
import 'TearmsAndConditionsScreen.dart';

// Function to show running reminder notification
void _showRunningReminder() {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.show(
    0,
    'Nhắc nhở chạy bộ',
    'Đã đến giờ chạy bộ buổi sáng rồi!',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'running_reminder_channel',
        'Running Reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

// Function to show step count reminder notification
void _showStepCountReminder() {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.show(
    1,
    'Thống kê bước chạy',
    'Hãy kiểm tra số bước chạy của bạn hôm nay!',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'step_count_channel',
        'Step Count Reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StepTrackingService stepController = Get.put(StepTrackingService());
  final BMIController bmiController = Get.put(BMIController());

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Cấp quyền thông báo'),
        content: const Text(
            'Ứng dụng cần quyền thông báo để gửi nhắc nhở chạy bộ và thống kê bước chạy hàng ngày.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Để sau'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Cấp quyền'),
            onPressed: () {
              Navigator.of(context).pop();
              // _requestNotificationPermissions();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateSteps() async {
    final steps = int.tryParse(stepController.stepCountString) ?? 0;
    stepController.steps.value = steps;
    print(steps);
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

  void _onItemTapped(int index) async {
    if (index == 1) {
      // Index 1 tương ứng với tab "Sức khoẻ"
      await Get.to(() => const HealthScreen());
    } else if (index == 2) {
      // Index 2 tương ứng với tab "Thuốc"
      Get.to(() => const MedicineScreen());
    } else if (index == 3) {
      // Index 3 tương ứng với tab "Phần thưởng"
      Get.to(() => const BulletinBoardScreen());
    }

    // Cập nhật lại chỉ số sau khi quay lại từ trang khác
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchUserName(),
      builder: (context, snapshot) {
        String userName = snapshot.data ?? 'Khách';
        User? user = FirebaseAuth.instance.currentUser;

        // Get current date and time
        String formattedDate =
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
        String formattedTime = DateFormat('HH:mm').format(DateTime.now());

        return Scaffold(
          appBar: AppBar(
            title: const Text("Trang chủ"),
            backgroundColor: Colors.teal,
            actions: [
              IconButton(
                icon: const Icon(Icons.message),
                onPressed: () {
                  if (user != null) {
                    Get.to(() => ChatScreen(userId: user.uid));
                  } else {
                    Get.snackbar(
                        'Lỗi', 'Vui lòng đăng nhập trước khi trò chuyện.');
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_sharp),
                onPressed: () {
                  //  _showOptionsMenu();
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _showNotificationPermissionDialog,
                // onPressed: () async {
                //   NotificationSettings settings =
                //       await FirebaseMessaging.instance.requestPermission();

                //   // if (settings.authorizationStatus ==
                //   //     AuthorizationStatus.authorized) {
                //   //   Get.snackbar('Thành công', 'Bạn đã cấp quyền thông báo.');
                //   // } else {
                //   //   Get.snackbar('Lỗi', 'Bạn đã từ chối quyền thông báo.');
                //   // }
                // },
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                // Drawer Header
                UserAccountsDrawerHeader(
                  accountName: Text(userName),
                  accountEmail: Text(user?.email ?? 'Không có email'),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.pinkAccent,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person), // Profile Icon
                  title: const Text("Hồ sơ"),
                  onTap: () {
                    // Navigate to the profile screen
                    Get.to(() => ProfileScreen(userId: user!.uid));
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
                  leading:
                      const Icon(Icons.account_circle), // Account and data icon
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
                    Get.toNamed(AppRoutes.HEALTH_DASHBOARD);
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
                      MaterialPageRoute(
                          builder: (context) => const AboutUsScreen()),
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
                  title: const Text('Đăng xuất',
                      style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Get.offNamed(AppRoutes.SIGNINSCREEN);
                  },
                ),
              ],
            ),
          ),
          // ... (remaining drawer items)
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Xin chào, $userName!",
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '$formattedDate, $formattedTime',
                                style: const TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.alarm,
                              color: Colors.teal), // Change to alarm icon
                          onPressed: () {
                            // _scheduleAlarm(); // Calls the method to schedule an alarm
                            Get.snackbar('Báo thức',
                                'Báo thức đã được đặt trong 10 giây tới.');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Health Overview Card
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.white, // Nền trắng
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.health_and_safety,
                                    color: Colors.teal),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Chỉ số khối cơ thể (BMI)',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.help_outline,
                                      color: Colors.teal),
                                  onPressed: () {
                                    Get.to(() => ChatScreen(
                                        userId: user!.uid,
                                        predefinedMessage:
                                            'Cách tính chỉ số BMI?'));
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // BMI Gauge Chart
                            SizedBox(
                              height: 250,
                              child: Obx(() {
                                double bmi = bmiController.bmiValue.value;
                                return SfRadialGauge(
                                  axes: <RadialAxis>[
                                    RadialAxis(
                                      minimum: 10,
                                      maximum: 40,
                                      showLabels: false,
                                      showTicks: false,
                                      ranges: <GaugeRange>[
                                        GaugeRange(
                                          startValue: 10,
                                          endValue: 18.5,
                                          color: Colors.blue,
                                          startWidth: 20,
                                          endWidth: 20,
                                        ),
                                        GaugeRange(
                                          startValue: 18.5,
                                          endValue: 25,
                                          color: Colors.green,
                                          startWidth: 20,
                                          endWidth: 20,
                                        ),
                                        GaugeRange(
                                          startValue: 25,
                                          endValue: 30,
                                          color: Colors.orange,
                                          startWidth: 20,
                                          endWidth: 20,
                                        ),
                                        GaugeRange(
                                          startValue: 30,
                                          endValue: 40,
                                          color: Colors.red,
                                          startWidth: 20,
                                          endWidth: 20,
                                        ),
                                      ],
                                      pointers: <GaugePointer>[
                                        NeedlePointer(
                                          value: bmi,
                                          enableAnimation: true,
                                          animationType:
                                              AnimationType.easeOutBack,
                                        ),
                                      ],
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                          widget: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                bmi.toStringAsFixed(1),
                                                style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                bmiController.bmiCategory.value,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: bmiController
                                                      .bmiColor.value,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          angle: 90,
                                          positionFactor: 0.75,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // New Health Goals Section
                    const SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white, // Nền trắng
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Section Header
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mục tiêu của tôi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.settings,
                                    color: Colors.grey), // Settings icon
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildHealthGoal(
                              onTap: () {
                                Get.to(() => const StepTrackingScreen());
                              },
                              icon: Image.asset(
                                'assets/images/shoe.png', // Đường dẫn đến tệp weigh.png trong thư mục assets
                                height:
                                    50.0, // Điều chỉnh kích thước hình ảnh nếu cần
                                width: 50.0,
                              ),
                              label: 'HA • tháng này',
                              value: '0 / 5',
                              color: Colors.redAccent,
                            ),
                            _buildHealthGoal(
                              onTap: () {
                                Get.to(() => const StepTrackingScreen());
                              },
                              icon: Image.asset(
                                'assets/images/shoe.png', // Đường dẫn đến tệp weigh.png trong thư mục assets
                                height:
                                    50.0, // Điều chỉnh kích thước hình ảnh nếu cần
                                width: 50.0,
                              ),
                              label: 'Khai báo một cơn đau',
                              value: 'Đau thắt ngực',
                              color: Colors.orange,
                            ),
                            _buildHealthGoal(
                              onTap: () {
                                Get.to(() => const StepTrackingScreen());
                              },
                              icon: Image.asset(
                                'assets/images/weigh.png', // Đường dẫn đến tệp weigh.png trong thư mục assets
                                height:
                                    50.0, // Điều chỉnh kích thước hình ảnh nếu cần
                                width: 50.0,
                              ),
                              label: 'Cân nặng • tuần này',
                              value: '0 / 3',
                              color: Colors.blue,
                            ),

                            Obx(() {
                              return _buildHealthGoal(
                                onTap: () async {
                                  // Điều hướng đến StepTrackingScreen và chờ kết quả
                                  final steps = await Get.to(
                                      () => const StepTrackingScreen());

                                  // Kiểm tra và cập nhật số bước nếu có
                                  if (steps != null) {
                                    stepController.steps.value =
                                        steps; // Cập nhật số bước
                                  }
                                },
                                icon: Image.asset(
                                  'assets/images/shoe.png', // Đường dẫn đến tệp weigh.png trong thư mục assets
                                  height:
                                      50.0, // Điều chỉnh kích thước hình ảnh nếu cần
                                  width: 50.0,
                                ),
                                label: 'Bước • hôm nay',
                                value: stepController
                                    .stepCountString, // Hiển thị số bước
                                color: Colors.pinkAccent,
                              );
                            }),

                            _buildHealthGoal(
                              onTap: () {
                                Get.to(() => const SleepTrackingScreen());
                              },
                              icon: Image.asset(
                                'assets/images/sleep.png', // Đường dẫn đến tệp weigh.png trong thư mục assets
                                height:
                                    50.0, // Điều chỉnh kích thước hình ảnh nếu cần
                                width: 50.0,
                              ),
                              label: 'Thời gian hồi phục',
                              value: '9m • 83% hồi phục',
                              color: Colors.teal,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
      },
    );
  }

  Widget _buildHealthGoal({
    required Widget icon, // Thay IconData bằng Widget
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon, // Hiển thị Widget icon (có thể là Icon hoặc Image)
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
