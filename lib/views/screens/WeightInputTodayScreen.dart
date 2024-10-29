import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import để khởi tạo dữ liệu ngôn ngữ

class WeightInputTodayScreen extends StatefulWidget {
  const WeightInputTodayScreen({super.key});

  @override
  _WeightInputTodayScreenState createState() => _WeightInputTodayScreenState();
}

class _WeightInputTodayScreenState extends State<WeightInputTodayScreen> {
  int _weight = 62;
  final int _minWeight = 0;
  final int _maxWeight = 300;
  String _unit = 'kg';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(
        'vi', null); // Khởi tạo dữ liệu cho ngôn ngữ Tiếng Việt
  }

  Future<void> _selectDate(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Text(
                  'Đặt ngày',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Container(
                  child: CupertinoDatePicker(
                    initialDateTime: _selectedDate,
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: const Text('Hoàn tất',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            iconSize: 28,
            splashRadius: 24,
          ),
        ],
        title: const Text(
          'Cân nặng',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(157, 174, 239, 121),
                  borderRadius:
                      BorderRadius.circular(30), // Viền bo tròn cho giống ảnh
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12), // Cân đối padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('Today, d MMMM yyyy', 'vi')
                          .format(_selectedDate),
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle,
                      color: Colors.pink, size: 40),
                  onPressed: () {
                    setState(() {
                      if (_weight > _minWeight) {
                        _weight--;
                      }
                    });
                  },
                ),
                const SizedBox(width: 20),
                Text(
                  '$_weight',
                  style: const TextStyle(
                      fontSize: 64, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: Colors.pink, size: 40),
                  onPressed: () {
                    setState(() {
                      if (_weight < _maxWeight) {
                        _weight++;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ToggleButtons(
              borderRadius: BorderRadius.circular(20),
              selectedColor: Colors.white,
              fillColor: Colors.pink,
              isSelected: [_unit == 'kg', _unit == 'lbs', _unit == 'st'],
              onPressed: (int index) {
                setState(() {
                  if (index == 0) {
                    _unit = 'kg';
                  } else if (index == 1) {
                    _unit = 'lbs';
                  } else if (index == 2) {
                    _unit = 'st';
                  }
                });
              },
              children: const [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text('kg', style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text('lbs', style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text('st', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Slider(
              value: _weight.toDouble(),
              min: _minWeight.toDouble(),
              max: _maxWeight.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _weight = value.toInt();
                });
              },
              activeColor: Colors.pink,
              inactiveColor: Colors.grey,
              divisions: 300,
              label: '$_weight',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.help_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Đo cân nặng như thế nào?',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
