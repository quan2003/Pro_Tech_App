import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:intl/intl.dart';

import '../controller/DayCell.dart';

class MonthScreen extends StatefulWidget {
  const MonthScreen({super.key});

  @override
  _MonthScreenState createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, Map<String, dynamic>> dailyData = {};
  int totalSteps = 0;
  double averageSteps = 0;
  double totalCalories = 0;
  double totalDistance = 0;
  int totalMinutes = 0;
  int stepGoal = 5000;
  DateTime? startOfMonth;
  DateTime? endOfMonth;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromFirebase();
  }

  Future<void> _loadDataFromFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      // Sử dụng ngày hiện tại thay vì ngày trong tương lai
      DateTime now = DateTime.now();
      startOfMonth = DateTime(now.year, now.month, 1);
      endOfMonth = DateTime(now.year, now.month + 1, 0);

      String startDate = DateFormat('yyyy-M-d').format(startOfMonth!);
      String endDate = DateFormat('yyyy-M-d').format(endOfMonth!);

      var collectionRef = _firestore
          .collection('activity_data')
          .doc(user.uid)
          .collection('daily_data');

      print('Start Date: $startDate');
      print('End Date: $endDate');
      print('User ID: ${user.uid}');
      print('Query path: ${collectionRef.path}');

      QuerySnapshot querySnapshot = await collectionRef
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDate)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endDate)
          .get();

      print('Number of documents found: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isEmpty) {
        print('No data found for this month.');
      } else {
        totalSteps = 0;
        totalCalories = 0;
        totalDistance = 0;
        totalMinutes = 0;

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
          dailyData[doc.id] = docData;

          print('Document ID: ${doc.id}, Data: $docData');

          int steps = (docData['steps'] ?? 0).toInt();
          totalSteps += steps;

          totalCalories += (docData['calories'] ?? 0).toDouble();
          totalDistance += (docData['distance'] ?? 0).toDouble();
          int minutes = (docData['minutes'] ?? 0).toInt();
          totalMinutes += minutes;
        }

        averageSteps = totalSteps / endOfMonth!.day;

        print('Total Steps: $totalSteps');
        print('Average Steps: $averageSteps');
        print('Total Calories: $totalCalories');
        print('Total Distance: $totalDistance');
        print('Total Minutes: $totalMinutes');
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMonthContent(),
    );
  }

  Widget _buildMonthContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỔNG HÀNG THÁNG',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Tháng ${startOfMonth?.month ?? ''}, ${startOfMonth?.year ?? ''}',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$totalSteps bước',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Text(
                      'Trung bình ${averageSteps.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_upward,
                        color: Colors.green, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMonthCalendar(),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('bước', '$totalSteps', Icons.directions_walk),
              _buildStatItem('kcal', totalCalories.toStringAsFixed(0),
                  Icons.local_fire_department),
              _buildStatItem(
                  'km', totalDistance.toStringAsFixed(1), Icons.directions),
              _buildStatItem('phút', '$totalMinutes', Icons.timer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar() {
    List<String> weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    int daysInMonth = endOfMonth?.day ?? 30;
    int firstWeekday = startOfMonth?.weekday ?? 1;
    int daysInPreviousMonth =
        DateTime(startOfMonth!.year, startOfMonth!.month, 0).day;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays
              .map(
                  (day) => Text(day, style: TextStyle(color: Colors.grey[600])))
              .toList(),
        ),
        const SizedBox(
            height: 16), // Tăng khoảng cách giữa tên các ngày và lịch
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 8, // Thêm khoảng cách ngang giữa các ô
            mainAxisSpacing: 8, // Thêm khoảng cách dọc giữa các ô
          ),
          padding: EdgeInsets.zero, // Loại bỏ padding mặc định
          itemCount: 42, // 6 weeks
          itemBuilder: (context, index) {
            int displayedDay;
            bool isCurrentMonth;
            if (index < firstWeekday - 1) {
              displayedDay = daysInPreviousMonth - (firstWeekday - 2 - index);
              isCurrentMonth = false;
            } else if (index >= firstWeekday - 1 + daysInMonth) {
              displayedDay = index - (firstWeekday - 1 + daysInMonth) + 1;
              isCurrentMonth = false;
            } else {
              displayedDay = index - (firstWeekday - 2);
              isCurrentMonth = true;
            }

            String dateKey = isCurrentMonth
                ? DateFormat('yyyy-M-d').format(DateTime(
                    startOfMonth!.year, startOfMonth!.month, displayedDay))
                : '';
            int steps = isCurrentMonth
                ? (dailyData[dateKey]?['steps'] ?? 0).toInt()
                : 0;
            double progressPercent = steps / stepGoal;

            return DayCell(
              day: displayedDay,
              isCurrentMonth: isCurrentMonth,
              progressPercent: progressPercent > 1 ? 1 : progressPercent,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 38, color: Colors.blue),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
