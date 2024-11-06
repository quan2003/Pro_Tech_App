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
  double _sleepQualityRating = 3.0;
  String _sleepNotes = '';

  // Thống kê
  double _averageSleepDuration = 0;
  TimeOfDay _averageBedtime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _averageWakeTime = const TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSleepHistory();
    _calculateStatistics();
  }

  void _calculateStatistics() {
    if (_sleepHistory.isEmpty) return;

    // Tính thời lượng ngủ trung bình
    double totalDuration = 0;
    double totalBedtimeMinutes = 0;
    double totalWakeMinutes = 0;

    for (var session in _sleepHistory) {
      var start = DateTime.parse(session['start']);
      var end = DateTime.parse(session['end']);
      var duration = end.difference(start);

      totalDuration += duration.inMinutes;
      totalBedtimeMinutes += start.hour * 60 + start.minute;
      totalWakeMinutes += end.hour * 60 + end.minute;
    }

    setState(() {
      _averageSleepDuration = totalDuration / _sleepHistory.length / 60;

      int avgBedtimeMinutes =
          (totalBedtimeMinutes / _sleepHistory.length).round();
      _averageBedtime = TimeOfDay(
          hour: (avgBedtimeMinutes / 60).floor(),
          minute: avgBedtimeMinutes % 60);

      int avgWakeMinutes = (totalWakeMinutes / _sleepHistory.length).round();
      _averageWakeTime = TimeOfDay(
          hour: (avgWakeMinutes / 60).floor(), minute: avgWakeMinutes % 60);
    });
  }

  void _loadSleepHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('sleepHistory');
    if (history != null) {
      setState(() {
        _sleepHistory = history
            .map((item) =>
                Map<String, dynamic>.fromEntries(item.split(',').map((e) {
                  var parts = e.split(':');
                  return MapEntry(parts[0], parts[1]);
                })))
            .toList();
      });
      _calculateStatistics();
    }
  }

  void _saveSleepData() async {
    if (_sleepStartTime != null && _wakeUpTime != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> sleepSession = {
        'start': _sleepStartTime!.toIso8601String(),
        'end': _wakeUpTime!.toIso8601String(),
        'quality': _sleepQualityRating.toString(),
        'notes': _sleepNotes,
      };

      _sleepHistory.add(sleepSession);
      await prefs.setStringList(
          'sleepHistory',
          _sleepHistory
              .map((item) =>
                  item.entries.map((e) => '${e.key}:${e.value}').join(','))
              .toList());

      _calculateStatistics();
      setState(() {});
    }
  }

  Future<void> _showSleepQualityDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh giá chất lượng giấc ngủ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: _sleepQualityRating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _sleepQualityRating.toString(),
              onChanged: (value) {
                setState(() => _sleepQualityRating = value);
              },
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Ghi chú về giấc ngủ',
                hintText: 'Ví dụ: Ngủ ngon, không bị gián đoạn...',
              ),
              maxLines: 3,
              onChanged: (value) => _sleepNotes = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveSleepData();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê giấc ngủ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Thời lượng ngủ trung bình: ${_averageSleepDuration.toStringAsFixed(1)} giờ',
            ),
            Text(
              'Giờ đi ngủ trung bình: ${_averageBedtime.format(context)}',
            ),
            Text(
              'Giờ thức dậy trung bình: ${_averageWakeTime.format(context)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepHistoryItem(Map<String, dynamic> session, int index) {
    var start = DateTime.parse(session['start']);
    var end = DateTime.parse(session['end']);
    var duration = end.difference(start);
    var quality = double.tryParse(session['quality'] ?? '0') ?? 0;
    var notes = session['notes'] ?? '';

    return Card(
      child: ExpansionTile(
        title: Text('Giấc ngủ ${_sleepHistory.length - index}'),
        subtitle: Text(
          'Thời lượng: ${duration.inHours}h ${duration.inMinutes % 60}m',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bắt đầu: ${DateFormat('dd/MM/yyyy HH:mm').format(start)}',
                ),
                Text(
                  'Kết thúc: ${DateFormat('dd/MM/yyyy HH:mm').format(end)}',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Chất lượng: '),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          color: i < quality ? Colors.amber : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Ghi chú: $notes'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi giấc ngủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              // TODO: Hiển thị biểu đồ phân tích
            },
          ),
        ],
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isTracking = !_isTracking;
                        if (_isTracking) {
                          _sleepStatus = 'Đang theo dõi';
                          _selectTime(isStart: true);
                        } else {
                          _sleepStatus = 'Không theo dõi';
                        }
                      });
                    },
                    icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                    label: Text(
                        _isTracking ? 'Dừng theo dõi' : 'Bắt đầu theo dõi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTracking ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            if (!_isTracking && _sleepStartTime != null && _wakeUpTime == null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectTime(isStart: false),
                        icon: const Icon(Icons.alarm),
                        label: const Text('Nhập giờ thức dậy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _buildStatisticsCard(),
            const SizedBox(height: 20),
            const Text(
              'Lịch sử giấc ngủ:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _sleepHistory.length,
                itemBuilder: (context, index) {
                  return _buildSleepHistoryItem(
                    _sleepHistory[_sleepHistory.length - 1 - index],
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
          _showSleepQualityDialog();
        }
      });
    }
  }
}
