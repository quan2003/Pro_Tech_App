// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  _WeekScreenState createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<int> stepsPerDay = List.filled(7, 0);
  List<double> caloriesPerDay = List.filled(7, 0);
  List<double> distancePerDay = List.filled(7, 0);
  List<int> minutesPerDay = List.filled(7, 0);
  int totalSteps = 0;
  double averageSteps = 0;
  double totalCalories = 0;
  double totalDistance = 0;
  int totalMinutes = 0;
  double? lastWeekAverageSteps;
  DateTime? startOfWeek;
  DateTime? endOfWeek;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      await _loadCachedData();
      await _loadDataFromFirebase(user.uid);
    } else {
      print("Không có người dùng đang đăng nhập.");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('weekData');
    Map<String, dynamic> data = json.decode(cachedData!);
    setState(() {
      stepsPerDay = List<int>.from(data['stepsPerDay']);
      caloriesPerDay = List<double>.from(data['caloriesPerDay']);
      distancePerDay = List<double>.from(data['distancePerDay']);
      minutesPerDay = List<int>.from(data['minutesPerDay']);
      totalSteps = data['totalSteps'];
      averageSteps = data['averageSteps'];
      totalCalories = data['totalCalories'];
      totalDistance = data['totalDistance'];
      totalMinutes = data['totalMinutes'];
      lastWeekAverageSteps = data['lastWeekAverageSteps'];
    });
  }

  Future<void> _loadDataFromFirebase(String userId) async {
    DateTime now = DateTime.now();
    startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    endOfWeek = startOfWeek!.add(const Duration(days: 6));

    DocumentReference userDocRef =
        _firestore.collection('activity_data').doc(userId);

    List<Future<DocumentSnapshot>> futures = [];
    for (int i = 0; i < 7; i++) {
      DateTime currentDate = startOfWeek!.add(Duration(days: i));
      String dateKey =
          "${currentDate.year}-${currentDate.month}-${currentDate.day}";
      futures.add(userDocRef.collection('daily_data').doc(dateKey).get());
    }

    List<DocumentSnapshot> snapshots = await Future.wait(futures);

    for (int i = 0; i < 7; i++) {
      if (snapshots[i].exists) {
        Map<String, dynamic> data = snapshots[i].data() as Map<String, dynamic>;
        stepsPerDay[i] = data['steps'] ?? 0;
        caloriesPerDay[i] = (data['calories'] ?? 0).toDouble();
        distancePerDay[i] = (data['distance'] ?? 0).toDouble();
        minutesPerDay[i] = data['minutes'] ?? 0;
      } else {
        stepsPerDay[i] = 0;
        caloriesPerDay[i] = 0;
        distancePerDay[i] = 0;
        minutesPerDay[i] = 0;
      }
    }

    totalSteps = stepsPerDay.reduce((a, b) => a + b);
    totalCalories = caloriesPerDay.reduce((a, b) => a + b);
    totalDistance = distancePerDay.reduce((a, b) => a + b);
    totalMinutes = minutesPerDay.reduce((a, b) => a + b);
    averageSteps = totalSteps / 7;

    await _loadLastWeekDataFromFirebase(userId);

    _cacheData();

    setState(() {});
  }

  Future<void> _loadLastWeekDataFromFirebase(String userId) async {
    DateTime now = DateTime.now();
    DateTime startOfLastWeek = now.subtract(Duration(days: now.weekday + 6));

    List<Future<DocumentSnapshot>> futures = [];
    for (int i = 0; i < 7; i++) {
      DateTime currentDate = startOfLastWeek.add(Duration(days: i));
      String dateKey =
          "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";
      futures.add(_firestore
          .collection('activity_data')
          .doc(userId)
          .collection('daily_data')
          .doc(dateKey)
          .get());
    }

    List<DocumentSnapshot> snapshots = await Future.wait(futures);
    List<int> lastWeekSteps = List.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      if (snapshots[i].exists) {
        Map<String, dynamic> data = snapshots[i].data() as Map<String, dynamic>;
        lastWeekSteps[i] = data['steps'] ?? 0;
      }
    }

    int lastWeekTotalSteps = lastWeekSteps.reduce((a, b) => a + b);
    lastWeekAverageSteps = lastWeekTotalSteps / 7;
  }

  Future<void> _cacheData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = {
      'stepsPerDay': stepsPerDay,
      'caloriesPerDay': caloriesPerDay,
      'distancePerDay': distancePerDay,
      'minutesPerDay': minutesPerDay,
      'totalSteps': totalSteps,
      'averageSteps': averageSteps,
      'totalCalories': totalCalories,
      'totalDistance': totalDistance,
      'totalMinutes': totalMinutes,
      'lastWeekAverageSteps': lastWeekAverageSteps,
    };
    prefs.setString('weekData', json.encode(data));
  }

  Future<void> checkFirestoreStructure(String userId) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection('activity_data').doc(userId);
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        print("Tài liệu người dùng tồn tại: ${userDoc.data()}");

        QuerySnapshot dailyDataSnapshot =
            await userDocRef.collection('daily_data').limit(5).get();

        print("Số lượng tài liệu daily_data: ${dailyDataSnapshot.docs.length}");

        for (var doc in dailyDataSnapshot.docs) {
          print("ID tài liệu: ${doc.id}, Dữ liệu: ${doc.data()}");
        }
      } else {
        print(
            "Tài liệu người dùng không tồn tại. Sẽ được tạo khi tải dữ liệu.");
      }
    } catch (e) {
      print("Lỗi khi kiểm tra cấu trúc Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? _buildLoadingIndicator() : _buildWeekContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildWeekContent() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỔNG HÀNG TUẦN',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Từ ngày ${startOfWeek?.day ?? ''} đến ngày ${endOfWeek?.day ?? ''}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${totalSteps} bước',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text('Trung bình ${averageSteps.toStringAsFixed(0)}'),
                    const SizedBox(width: 8),
                    _buildTrendIcon(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeekChart(),
          const Expanded(child: SizedBox()),
          _buildStatItem('bước', totalSteps.toString(), Icons.directions_walk),
          _buildStatItem('kcal', totalCalories.toStringAsFixed(1),
              Icons.local_fire_department),
          _buildStatItem(
              'km', totalDistance.toStringAsFixed(2), Icons.directions),
          _buildStatItem('phút', totalMinutes.toString(), Icons.timer),
        ],
      ),
    );
  }

  Widget _buildTrendIcon() {
    if (lastWeekAverageSteps == null) {
      return const SizedBox();
    }

    if (averageSteps > lastWeekAverageSteps!) {
      return const Icon(Icons.arrow_upward, color: Colors.green, size: 16);
    } else if (averageSteps < lastWeekAverageSteps!) {
      return const Icon(Icons.arrow_downward, color: Colors.red, size: 16);
    } else {
      return const Icon(Icons.horizontal_rule, color: Colors.grey, size: 16);
    }
  }

  Widget _buildWeekChart() {
    int maxSteps = 5000;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((day) {
            return Expanded(
              child: Center(
                child: Text(day, style: const TextStyle(color: Colors.grey)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stepsPerDay.map((steps) {
            double fillPercentage = (steps / maxSteps).clamp(0.0, 1.0);
            return Expanded(
              child: SizedBox(
                height: 150,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 30,
                      height: 150,
                      color: Colors.grey[300],
                    ),
                    Container(
                      width: 30,
                      height: fillPercentage * 150,
                      color: Colors.blue[200],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stepsPerDay.map((steps) {
            return Expanded(
              child: Center(
                child: Text(
                  steps > 0 ? steps.toString() : '-',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
