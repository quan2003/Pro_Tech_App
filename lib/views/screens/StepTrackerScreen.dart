import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../controller/StepTrackingService.dart';
// Import HealthController
import '../controller/health_controller.dart';
import 'MonthScreen.dart';
import 'WeekScreen.dart';
import 'YearScreen.dart';

class StepTrackingScreen extends StatefulWidget {
  const StepTrackingScreen({super.key});

  @override
  _StepTrackingScreenState createState() => _StepTrackingScreenState();
}

class _StepTrackingScreenState extends State<StepTrackingScreen>
    with SingleTickerProviderStateMixin {
  final StepTrackingService _stepService = Get.find<StepTrackingService>();
  final HealthController _healthController =
      Get.find<HealthController>(); // Get HealthController instance

  late TabController _tabController;
  final List<String> _tabs = ['Ngày', 'Tuần', 'Tháng', 'Năm'];
  DateTime _currentDate = DateTime.now();
  String _currentPeriod = "Hôm nay";
  final int _stepGoal = 5000;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _stepService.loadDataForDate(_currentDate);
    _healthController
        .fetchHealthData(); // Fetch health data when the screen is initialized
  }

  void _handleTabSelection() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _currentPeriod = _formatDate(_currentDate);
          _stepService.loadDataForDate(_currentDate);
          break;
        case 1:
          _currentPeriod = 'Tổng số bước trong tuần';
          break;
        case 2:
          _currentPeriod = 'Tổng hàng tháng';
          break;
        case 3:
          _currentPeriod = 'Tổng số bước trong năm';
          break;
        default:
          _currentPeriod = 'Hôm nay';
      }
    });
  }

  String _formatDate(DateTime date) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) {
      return 'Hôm nay';
    } else if (date.isAtSameMomentAs(yesterday)) {
      return 'Hôm qua';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _navigateDay(bool forward) {
    setState(() {
      _currentDate = forward
          ? _currentDate.add(const Duration(days: 1))
          : _currentDate.subtract(const Duration(days: 1));
      _currentPeriod = _formatDate(_currentDate);
      _stepService.loadDataForDate(_currentDate);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _stepService.saveStepsToFirebase();
        Navigator.pop(context, _stepService.steps.value);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Bước chân', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              await _stepService.saveStepsToFirebase();
              Navigator.pop(context, _stepService.steps.value);
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: _tabs.map((String name) => Tab(text: name)).toList(),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.pinkAccent,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTabContent(),
            const WeekScreen(),
            const MonthScreen(),
            const YearScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Obx(
        () => SingleChildScrollView(
          // Bọc trong SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.black),
                      onPressed: () => _navigateDay(false),
                    ),
                    Expanded(
                      child: Text(
                        _currentPeriod,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.black),
                      onPressed: _currentDate.isBefore(DateTime.now())
                          ? () => _navigateDay(true)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              CircularPercentIndicator(
                radius: 150.0,
                lineWidth: 15.0,
                animation: true,
                percent: (_stepGoal > 0)
                    ? (_healthController.steps.value / _stepGoal)
                        .clamp(0.0, 1.0) // Use HealthController for steps
                    : 0.0,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_walk,
                        size: 50, color: Colors.pink),
                    Text(
                      "${_healthController.steps.value}", // Display step count from HealthController
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 50.0),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Logic to edit step goal
                      },
                      child: const Text(
                        "Sửa mục tiêu",
                        style: TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.green,
                backgroundColor: Colors.grey[300]!,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                      "bước",
                      "${_healthController.steps.value}", // Use HealthController for steps
                      Icons.directions_walk),
                  _buildStatItem(
                      "kcal",
                      _stepService.calories.value.toStringAsFixed(1),
                      Icons.local_fire_department),
                  _buildStatItem(
                      "km",
                      _stepService.distance.value.toStringAsFixed(2),
                      Icons.directions),
                  _buildStatItem(
                      "phút", "${_stepService.minutes.value}", Icons.timer),
                ],
              ),
              const SizedBox(height: 40),
              // Improved tracking button
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: _stepService.isTracking.value
                        ? [Colors.red.shade400, Colors.red.shade700]
                        : [Colors.green.shade400, Colors.green.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _stepService.isTracking.value
                          ? Colors.red.withOpacity(0.4)
                          : Colors.green.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _stepService.toggleTracking();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _stepService.isTracking.value
                            ? Icons.stop
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _stepService.isTracking.value
                            ? 'Dừng theo dõi'
                            : 'Bắt đầu theo dõi',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.pinkAccent),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
