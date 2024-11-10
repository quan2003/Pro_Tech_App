import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pro_tech_app/views/screens/AppVersionPage.dart';
import 'package:pro_tech_app/views/screens/HealthGuidelinesScreen.dart';
import 'package:pro_tech_app/views/screens/SettingsScreen.dart';
import 'package:provider/provider.dart';
import '../controller/health_controller.dart';
import '../utils/SettingsProvider.dart';
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
import 'check/HeartDiseaseCheckScreen.dart';

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
  final HealthController healthController = Get.put(HealthController());
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
    final theme = Theme.of(context);
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
            title: Text("Trang chủ", style: theme.textTheme.titleLarge),
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
                  accountName: Text(userName,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: Colors.white)),
                  accountEmail: Text(
                    user?.email ?? 'Không có email',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person), // Profile Icon
                  title: Text("Hồ sơ", style: theme.textTheme.bodyLarge),
                  onTap: () {
                    // Navigate to the profile screen
                    Get.to(() => ProfileScreen(userId: user!.uid));
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
                  leading:
                      const Icon(Icons.account_circle), // Account and data icon
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
                                style: theme.textTheme.headlineMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '$formattedDate, $formattedTime',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Health Overview Card
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: theme.brightness == Brightness.dark
                          ? theme.cardColor
                          : Colors.white,
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
                                Expanded(
                                  child: ThemedText(
                                    'Chỉ số khối cơ thể (BMI)',
                                    style: theme.textTheme.titleLarge,
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
                                              ThemedText(
                                                bmi.toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ThemedText(
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
                      color: theme.brightness == Brightness.dark
                          ? theme.cardColor
                          : Colors.white,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ThemedText(
                                  'Mục tiêu của tôi',
                                  style: theme.textTheme.titleLarge,
                                ),
                                Icon(
                                  Icons.settings,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // _buildHealthGoal(
                            //   onTap: () {
                            //     Get.to(() => const StepTrackingScreen());
                            //   },
                            //   icon: Image.asset(
                            //     'assets/images/shoe.png', // Đường dẫn đến tệp weigh.png trong thư mục assets
                            //     height:
                            //         50.0, // Điều chỉnh kích thước hình ảnh nếu cần
                            //     width: 50.0,
                            //   ),
                            //   label: 'HA • tháng này',
                            //   value: '0 / 5',
                            //   color: Colors.redAccent,
                            // ),
                            // _buildHealthGoal(
                            //   onTap: () {
                            //     Get.to(() => const StepTrackingScreen());
                            //   },
                            //   icon: Image.asset(
                            //     'assets/images/shoe.png', // Đường dẫn đến tệp weigh.png trong thư mục assets
                            //     height:
                            //         50.0, // Điều chỉnh kích thước hình ảnh nếu cần
                            //     width: 50.0,
                            //   ),
                            //   label: 'Khai báo một cơn đau',
                            //   value: 'Đau thắt ngực',
                            //   color: Colors.orange,
                            // ),
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
                                  await Get.to(
                                      () => const StepTrackingScreen());
                                  healthController
                                      .fetchHealthData(); // Refresh sau khi quay lại
                                },
                                icon: Image.asset(
                                  'assets/images/shoe.png',
                                  height: 50.0,
                                  width: 50.0,
                                ),
                                label: 'Bước • hôm nay',
                                value: healthController.stepCountString,
                                color: Colors.pinkAccent,
                              );
                            }),
                            Obx(() {
                              return _buildHealthGoal(
                                onTap: () async {
                                  await Get.to(
                                      () => const SleepTrackingScreen());
                                  healthController
                                      .fetchHealthData(); // Refresh sau khi quay lại
                                },
                                icon: Image.asset(
                                  'assets/images/sleep.png',
                                  height: 50.0,
                                  width: 50.0,
                                ),
                                label:
                                    'Giấc ngủ • ${healthController.sleepQualityString}',
                                value: healthController.sleepDurationString,
                                color: Colors.teal,
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue[400]!,
                            Colors.blue[600]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kiểm tra sức khỏe',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Kết quả đánh giá sẽ cho bạn\nlời khuyên xử trí phù hợp!',
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Image.asset(
                                    'assets/images/doctors.png',
                                    height: 80,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              // Tăng tỷ lệ để card cao hơn
                              childAspectRatio: 0.95,
                              children: [
                                _buildHealthCheckCard2(
                                  title: 'Kiểm tra nguy cơ mắc bệnh tim mạch',
                                  iconPath: 'assets/images/heart.png',
                                  onTap: () {
                                    Get.to(
                                      () => const HeartDiseaseCheckScreen(),
                                      transition: Transition.rightToLeft,
                                    );
                                  },
                                ),
                                _buildHealthCheckCard2(
                                  title: 'Kiểm tra nguy cơ mắc bệnh Alzgeimer',
                                  iconPath: 'assets/images/brain.png',
                                  onTap: () {},
                                ),
                                _buildHealthCheckCard2(
                                  title: 'Kiểm tra nguy cơ mắc bệnh tiểu đường',
                                  iconPath: 'assets/images/diabetes.png',
                                  onTap: () {},
                                ),
                                _buildHealthCheckCard2(
                                  title:
                                      'Kiểm tra nguy cơ mắc bệnh trào ngược dạ dày',
                                  iconPath: 'assets/images/stomach.png',
                                  onTap: () {},
                                ),
                              ],
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
          bottomNavigationBar: Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              // Tính toán chiều cao dựa trên font size
              double heightFactor = settings.fontSize <= 1.2 ? 1.0 : 1.5;

              return SizedBox(
                height: kToolbarHeight *
                    heightFactor, // Điều chỉnh chiều cao tự động
                child: ConvexAppBar(
                  style: TabStyle.reactCircle,
                  backgroundColor: Colors.white,
                  activeColor: Colors.pinkAccent,
                  color: Colors.grey,
                  height: kToolbarHeight *
                      heightFactor, // Điều chỉnh chiều cao của ConvexAppBar
                  items: [
                    _buildTabItem(Icons.home, 'Trang chủ', settings.fontSize),
                    _buildTabItem(
                        Icons.favorite, 'Sức khoẻ', settings.fontSize),
                    _buildTabItem(Icons.medication, 'Thuốc', settings.fontSize),
                    _buildTabItem(Icons.forum, 'Bảng tin', settings.fontSize),
                  ],
                  initialActiveIndex: _selectedIndex,
                  onTap: _onItemTapped,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Helper method để tạo TabItem với font size tương thích
  TabItem _buildTabItem(IconData icon, String title, double fontSize) {
    // Giảm kích thước chữ của title để tránh overflow
    double adjustedFontSize = 12 * (fontSize <= 1.2 ? fontSize : 1.2);

    return TabItem(
      icon: icon,
      title: title,
      isIconBlend: true,
      // Xóa các thuộc tính không hỗ trợ
      // fontFamily và textStyle không được hỗ trợ bởi TabItem
    );
  }

  Widget _buildHealthCheckCard2({
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? theme.cardColor
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  iconPath,
                  height: 28,
                  width: 28,
                  fit: BoxFit.contain,
                  color:
                      theme.brightness == Brightness.dark ? Colors.white : null,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ThemedText(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                ThemedText(
                  'Bắt đầu',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthGoal({
    required Widget icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThemedText(
                      value,
                      style: theme.textTheme.titleMedium,
                    ),
                    ThemedText(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.grey[400],
              size: 18 * (theme.textTheme.bodyMedium?.fontSize ?? 14) / 14,
            ),
          ],
        ),
      ),
    );
  }
}

class ThemedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextAlign? textAlign;

  const ThemedText(
    this.text, {
    super.key,
    this.style,
    this.overflow,
    this.maxLines,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyMedium;
    final finalStyle = (style ?? defaultStyle)?.copyWith(
      color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
    );

    return Text(
      text,
      style: finalStyle,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }
}

extension ThemeTextExtension on TextStyle? {
  TextStyle? withThemedColor(BuildContext context) {
    if (this == null) return null;
    final theme = Theme.of(context);
    return this!.copyWith(
      color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
    );
  }
}

// Thêm một extension để hỗ trợ việc scale font size an toàn
extension SafeFontSize on double {
  double get safeScale {
    // Giới hạn scale factor để tránh overflow
    return this <= 1.2 ? this : 1.2;
  }
}
