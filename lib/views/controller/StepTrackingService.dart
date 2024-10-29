// ignore_for_file: file_names, unused_field, avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

class StepTrackingService extends GetxService {
  var steps = 0.obs;
  var calories = 0.0.obs;
  var distance = 0.0.obs;
  var minutes = 0.obs;
  var isTracking = false.obs;

  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;

  String gender = 'male';
  DateTime? _startTime;
  int _elapsedSeconds = 0;
  int _lastSavedSteps = 0;

  final List<double> _magnitudeBuffer = [];
  final int _bufferSize = 20;
  final double _stepThreshold = 10.0;
  final int _minStepInterval = 250;
  int _lastStepTimestamp = 0;

  Timer? _syncTimer;
  Timer? _trackingTimer;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        print("Current user: ${_user?.uid}");
        initialize();
      } else {
        print("User is not logged in.");
        stopTracking();
      }
    });
  }

  Future<void> initialize() async {
    print("Initializing StepTrackingService");
    await _checkAndRequestPermission();
    await loadTodayData();
    await loadUserGender();
    if (isTracking.value) {
      startTracking();
    }
    print(
        "StepTrackingService initialized with ${steps.value} steps and gender: $gender");
  }

  Future<void> loadTodayData() async {
    if (_user == null) return;
    try {
      DateTime now = DateTime.now();
      String todayKey = "${now.year}-${now.month}-${now.day}";
      final data = await _firestore
          .collection('activity_data')
          .doc(_user!.uid)
          .collection('daily_data')
          .doc(todayKey)
          .get();
      if (data.exists) {
        steps.value = data['steps'] ?? 0;
        _lastSavedSteps = steps.value;
        calories.value = data['calories'] ?? 0.0;
        distance.value = data['distance'] ?? 0.0;
        _elapsedSeconds = data['elapsedSeconds'] ?? 0;
        minutes.value = (_elapsedSeconds / 60).round();
        isTracking.value = data['isTracking'] ?? false;
        _startTime = data['startTime'] != null
            ? DateTime.parse(data['startTime'])
            : null;
        print(
            "Loaded today's data: ${steps.value} steps, ${minutes.value} minutes");
      } else {
        resetData();
      }
    } catch (e) {
      print("Error loading today's data: $e");
    }
  }

  void startTracking() {
    if (!isTracking.value) {
      isTracking.value = true;
      _startTime = DateTime.now().subtract(Duration(seconds: _elapsedSeconds));
      startListening();
      _startTrackingTimer();
      _startSyncTimer();
    }
  }

  void stopTracking() {
    if (isTracking.value) {
      isTracking.value = false;
      stopListening();
      _trackingTimer?.cancel();
      _syncTimer?.cancel();
      saveDataToFirebase();
    }
  }

  void _startTrackingTimer() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isTracking.value) {
        _elapsedSeconds++;
        minutes.value = (_elapsedSeconds / 60).round();
        updateData();
      }
    });
  }

  Future<void> toggleTracking() async {
    if (isTracking.value) {
      stopTracking();
    } else {
      await _checkAndRequestPermission();
      await loadUserGender();
      startTracking();
    }
    await saveDataToFirebase();
  }

  Future<void> _checkAndRequestPermission() async {
    PermissionStatus status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      status = await Permission.activityRecognition.request();
      if (!status.isGranted) {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    Get.defaultDialog(
      title: "Cần Quyền Vận Động",
      middleText:
          "Vui lòng cấp quyền vận động để ứng dụng có thể theo dõi hoạt động của bạn.",
      onConfirm: () => Get.back(),
      textConfirm: "OK",
    );
  }

  Future<void> loadUserGender() async {
    if (_user == null) return;
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        gender = (userData['gender'] ?? 'male').toString().toLowerCase();
      } else {
        gender = 'male';
      }
      print("User gender: $gender");
    } catch (e) {
      print("Error loading user gender: $e");
      gender = 'male';
    }
  }

  void startListening() {
    if (_accelerometerSubscription != null) return;
    _accelerometerSubscription =
        userAccelerometerEvents.listen(_onAccelerometerEvent);
    print("Started listening to accelerometer events");
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    print("Stopped listening to accelerometer events");
  }

  void _onAccelerometerEvent(UserAccelerometerEvent event) {
    if (!isTracking.value) return;

    double magnitude =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    _magnitudeBuffer.add(magnitude);
    if (_magnitudeBuffer.length > _bufferSize) {
      _magnitudeBuffer.removeAt(0);
    }

    if (_magnitudeBuffer.length == _bufferSize) {
      double avgMagnitude =
          _magnitudeBuffer.reduce((a, b) => a + b) / _bufferSize;
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

      if (avgMagnitude > _stepThreshold &&
          (currentTimestamp - _lastStepTimestamp) > _minStepInterval) {
        _lastStepTimestamp = currentTimestamp;
        _incrementSteps();
      }
    }
  }

  Future<void> loadDataForDate(DateTime date) async {
    if (_user == null) return;
    try {
      String dateKey = "${date.year}-${date.month}-${date.day}";
      final stepData = await _firestore
          .collection('activity_data')
          .doc(_user!.uid)
          .collection('daily_data')
          .doc(dateKey)
          .get();
      if (stepData.exists && stepData.data()?['steps'] != null) {
        steps.value = stepData.data()!['steps'];
        calories.value = stepData.data()?['calories'] ?? 0.0;
        distance.value = stepData.data()?['distance'] ?? 0.0;
        minutes.value = stepData.data()?['minutes'] ?? 0;
        _startTime = stepData.data()!['startTime'] != null
            ? DateTime.parse(stepData.data()!['startTime'])
            : date;
        updateData();
        print("Loaded data for $dateKey: ${steps.value} steps");
      } else {
        resetData();
        _startTime = date;
        print("No data found for $dateKey. Reset to zero.");
      }
    } catch (e) {
      print("Error loading data for $date: $e");
    }
  }

  void _incrementSteps() {
    if (isTracking.value) {
      steps.value++;
      updateData();
      print("Steps incremented: ${steps.value}");
    }
  }

  void updateData() {
    double caloriesPerStep = (gender == 'male') ? 0.045 : 0.04;
    double distancePerStep = (gender == 'male') ? 0.000762 : 0.000667; // in km

    calories.value = steps.value * caloriesPerStep;
    distance.value = steps.value * distancePerStep;
  }

  Future<void> saveDataToFirebase() async {
    if (_user == null) return;
    try {
      DateTime now = DateTime.now();
      String todayKey = "${now.year}-${now.month}-${now.day}";
      await _firestore
          .collection('activity_data')
          .doc(_user!.uid)
          .collection('daily_data')
          .doc(todayKey)
          .set({
        'date': todayKey,
        'steps': steps.value,
        'calories': calories.value,
        'distance': distance.value,
        'elapsedSeconds': _elapsedSeconds,
        'minutes': minutes.value,
        'isTracking': isTracking.value,
        'startTime': _startTime?.toIso8601String(),
      }, SetOptions(merge: true));
      print("Saved data to Firebase for $todayKey");
    } catch (e) {
      print("Error saving data to Firebase: $e");
    }
  }

  Future<void> saveStepsToFirebase() async {
    if (_user == null) return;
    try {
      DateTime now = DateTime.now();
      String todayKey = "${now.year}-${now.month}-${now.day}";
      CollectionReference dailyStepsCollection = _firestore
          .collection('activity_data')
          .doc(_user!.uid)
          .collection('daily_data');
      await dailyStepsCollection.doc(todayKey).set({
        'date': todayKey,
        'steps': steps.value,
        'calories': calories.value,
        'distance': distance.value,
        'minutes': minutes.value,
        'startTime': _startTime?.toIso8601String(),
      }, SetOptions(merge: true));
      print("Saved ${steps.value} steps to Firebase for $todayKey");
    } catch (e) {
      print("Error saving steps to Firebase: $e");
    }
  }

  Future<void> loadTodaySteps() async {
    if (_user == null) return;
    try {
      DateTime now = DateTime.now();
      String todayKey = "${now.year}-${now.month}-${now.day}";
      final stepData = await _firestore
          .collection('activity_data')
          .doc(_user!.uid)
          .collection('daily_data')
          .doc(todayKey)
          .get();
      if (stepData.exists && stepData.data()?['steps'] != null) {
        steps.value = stepData.data()!['steps'];
        _startTime = stepData.data()!['startTime'] != null
            ? DateTime.parse(stepData.data()!['startTime'])
            : DateTime.now();
        updateData();
        print("Loaded today's steps: ${steps.value}");
      } else {
        steps.value = 0;
        _startTime = DateTime.now();
        print("No step data found for today.");
      }
    } catch (e) {
      print("Error loading today's steps: $e");
    }
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      saveDataToFirebase();
    });
  }

// Future<void> toggleTracking() async {
//   isTracking.value = !isTracking.value;
//   if (isTracking.value) {
//     await _checkAndRequestPermission();
//     await loadUserGender();
//     startListening();
//     _startSyncTimer();
//   } else {
//     stopListening();
//   }
//   await saveStepsToFirebase();
// }

  String get stepCountString {
    print("Current step count: ${steps.value}");
    return "${steps.value} bước / 5000";
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  void resetData() {
    steps.value = 0;
    _lastSavedSteps = 0;
    calories.value = 0.0;
    distance.value = 0.0;
    minutes.value = 0;
    _elapsedSeconds = 0;
    _startTime = null;
    isTracking.value = false;
  }
}
