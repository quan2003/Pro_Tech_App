import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

class YearScreen extends StatefulWidget {
  const YearScreen({super.key});

  @override
  _YearScreenState createState() => _YearScreenState();
}

class _YearScreenState extends State<YearScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, IconData> iconMap = {
    'directions_walk': Icons.directions_walk,
    'local_fire_department': Icons.local_fire_department,
    'straighten': Icons.square_foot,
    'timer': Icons.timer,
  };

  Map<String, int> monthlyData = {};
  int totalSteps = 0;
  double averageSteps = 0;
  double totalCalories = 0;
  double totalDistance = 0;
  int totalMinutes = 0;
  DateTime? startOfYear;
  DateTime? endOfYear;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromFirebase();
  }
 DateTime? parseCustomDate(String dateString) {
    try {
      List<String> parts = dateString.split('-');
      if (parts.length == 3) {
        int year = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int day = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date $dateString: $e');
    }
    return null;
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

      print('Current user ID: ${user.uid}');

      var collectionRef = _firestore
          .collection('activity_data')
          .doc(user.uid)
          .collection('daily_data');

      print('Collection path: ${collectionRef.path}');

      QuerySnapshot querySnapshot = await collectionRef.get();

      print('Total number of documents found: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isEmpty) {
        print('No data found at all.');
      } else {
        monthlyData.clear();
        totalSteps = 0;
        totalCalories = 0;
        totalDistance = 0;
        totalMinutes = 0;

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
          print('Document data: $docData');

          String? dateString = docData['date'] as String?;
          if (dateString == null || dateString.isEmpty) {
            print('Date is null or empty for document ${doc.id}');
            continue;
          }

          DateTime? date = parseCustomDate(dateString);
          if (date == null) {
            print('Failed to parse date: $dateString');
            continue;
          }

          String monthKey = DateFormat('yyyy-MM').format(date);

          int steps = (docData['steps'] as num?)?.toInt() ?? 0;
          monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + steps;

          totalSteps += steps;
          totalCalories += (docData['calories'] as num?)?.toDouble() ?? 0;
          totalDistance += (docData['distance'] as num?)?.toDouble() ?? 0;
          int minutes = (docData['minutes'] as num?)?.toInt() ?? 0;
          totalMinutes += minutes;

          print('Processed: Date: $dateString, Steps: $steps, MonthKey: $monthKey');
        }

        if (monthlyData.isNotEmpty) {
          averageSteps = totalSteps / monthlyData.length;

          print('Monthly data: $monthlyData');
          print('Total Steps: $totalSteps');
          print('Average Steps per Month: $averageSteps');
          print('Total Calories: $totalCalories');
          print('Total Distance: $totalDistance');
          print('Total Minutes: $totalMinutes');

          // Set startOfYear and endOfYear based on the data we have
          var dates = monthlyData.keys.map((key) => DateFormat('yyyy-MM').parse(key)).toList();
          startOfYear = dates.reduce((a, b) => a.isBefore(b) ? a : b);
          endOfYear = dates.reduce((a, b) => a.isAfter(b) ? a : b);
        } else {
          print('No valid data processed.');
        }
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

  Widget _buildYearChart() {
    if (monthlyData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    double maxY = monthlyData.values.isEmpty
        ? 1000
        : monthlyData.values.reduce(math.max).toDouble();
    maxY = math.max(maxY, 1000);
    List<BarChartGroupData> barGroups = [];

    monthlyData.forEach((key, value) {
      DateTime date = DateFormat('yyyy-MM').parse(key);
      barGroups.add(BarChartGroupData(
        x: date.month,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            gradient: _barsGradient,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
    });

    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBorder: const BorderSide(color: Colors.blueAccent, width: 1),
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String monthName = DateFormat('MMMM').format(DateTime(
                    startOfYear?.year ?? DateTime.now().year, group.x, 1));
                return BarTooltipItem(
                  '$monthName\n',
                  const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${NumberFormat('#,###').format(rod.toY.round())} bước',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = [
                    'T1',
                    'T2',
                    'T3',
                    'T4',
                    'T5',
                    'T6',
                    'T7',
                    'T8',
                    'T9',
                    'T10',
                    'T11',
                    'T12'
                  ];
                  int index = value.toInt() - 1;
                  if (index >= 0 && index < months.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        months[index],
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: maxY / 5,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          Colors.blue.shade300,
          Colors.blue.shade900,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      color: Colors.white, // Set background color to white
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TỔNG HÀNG NĂM',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Năm ${startOfYear?.year ?? ''}',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${NumberFormat('#,###').format(totalSteps)} bước',
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Trung bình ${NumberFormat('#,###').format(averageSteps.round())}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_upward,
                                      color: Colors.green, size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildYearChart(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildStatisticsSummary(),
                  ),
                ],
              ),
            ),
    ),
  );
}

  Widget _buildStatisticsSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('directions_walk',
            NumberFormat('#,###').format(totalSteps), 'bước'),
        _buildStatItem('local_fire_department',
            NumberFormat('#,###').format(totalCalories.round()), 'kcal'),
        _buildStatItem('straighten', totalDistance.toStringAsFixed(1), 'km'),
        _buildStatItem(
            'timer', NumberFormat('#,###').format(totalMinutes), 'phút'),
      ],
    );
  }

  Widget _buildStatItem(String iconName, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(iconMap[iconName] ?? Icons.error, size: 24, color: Colors.blue),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child:
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
