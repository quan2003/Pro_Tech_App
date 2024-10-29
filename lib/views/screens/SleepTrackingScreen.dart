import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  _SleepTrackingScreenState createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  bool _isTracking = false;
  String _sleepStatus = 'Chưa theo dõi';
  DateTime? _sleepStartTime;
  DateTime? _wakeUpTime;
  List<Map<String, dynamic>> _sleepHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSleepHistory();
  }

  void _loadSleepHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('sleepHistory');
    setState(() {
      _sleepHistory = history!
          .map((item) => Map<String, dynamic>.from(item
              .split(',')
              .map((e) => MapEntry(e.split(':')[0], e.split(':')[1])) as Map))
          .toList();
    });
  }

  void _saveSleepData() async {
    if (_sleepStartTime != null && _wakeUpTime != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> sleepSession = {
        'start': _sleepStartTime!.toIso8601String(),
        'end': _wakeUpTime!.toIso8601String(),
      };
      _sleepHistory.add(sleepSession);
      await prefs.setStringList(
          'sleepHistory',
          _sleepHistory
              .map((item) =>
                  item.entries.map((e) => '${e.key}:${e.value}').join(','))
              .toList());
      setState(() {});
    }
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
      if (_isTracking) {
        _sleepStatus = 'Đang theo dõi';
        _selectTime(isStart: true);
      } else {
        _sleepStatus = 'Không theo dõi';
      }
    });
  }

  Future<void> _selectTime({required bool isStart}) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      DateTime now = DateTime.now();
      DateTime selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      setState(() {
        if (isStart) {
          _sleepStartTime = selectedDateTime;
          _sleepStatus = 'Đang ngủ';
        } else {
          _wakeUpTime = selectedDateTime;
          _sleepStatus = 'Đã thức dậy';
          _saveSleepData();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi giấc ngủ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trạng thái: $_sleepStatus',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleTracking,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTracking ? Colors.red : Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: Text(_isTracking ? 'Dừng theo dõi' : 'Bắt đầu theo dõi'),
            ),
            if (!_isTracking && _sleepStartTime != null && _wakeUpTime == null)
              ElevatedButton(
                onPressed: () => _selectTime(isStart: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                child: const Text('Nhập giờ thức dậy'),
              ),
            const SizedBox(height: 40),
            const Text(
              'Lịch sử giấc ngủ:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _sleepHistory.length,
                itemBuilder: (context, index) {
                  var session = _sleepHistory[_sleepHistory.length - 1 - index];
                  var start = DateTime.parse(session['start']);
                  var end = DateTime.parse(session['end']);
                  var duration = end.difference(start);
                  return Card(
                    child: ListTile(
                      title: Text('Giấc ngủ ${_sleepHistory.length - index}'),
                      subtitle: Text(
                        'Bắt đầu: ${DateFormat('dd/MM/yyyy HH:mm').format(start)}\n'
                        'Kết thúc: ${DateFormat('dd/MM/yyyy HH:mm').format(end)}\n'
                        'Thời lượng: ${duration.inHours}h ${duration.inMinutes % 60}m',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
