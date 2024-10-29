import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ChatScreen.dart';

class Hba1cTestScreen extends StatefulWidget {
  const Hba1cTestScreen({super.key});

  @override
  _Hba1cTestScreenState createState() => _Hba1cTestScreenState();
}

class _Hba1cTestScreenState extends State<Hba1cTestScreen> {
  double _hba1cValue = 7.6;
  bool isPercentage = true;
  DateTime selectedDate = DateTime.now();

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    const Text(
                      'Đặt ngày',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: selectedDate,
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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

  void _toggleUnit() {
    setState(() {
      isPercentage = !isPercentage;
      if (isPercentage) {
        _hba1cValue = (_hba1cValue / 10.929) + 2.15;
      } else {
        _hba1cValue = (_hba1cValue - 2.15) * 10.929;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('d MMMM yyyy', 'vi').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xét nghiệm HbA1c', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(157, 255, 255, 255),
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Hôm nay, $formattedDate",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _hba1cValue.toStringAsFixed(1),
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!isPercentage) _toggleUnit();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isPercentage ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "%",
                        style: TextStyle(
                          color: isPercentage ? Colors.white : Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isPercentage) _toggleUnit();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: !isPercentage ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "mmol/mol",
                        style: TextStyle(
                          color: !isPercentage ? Colors.white : Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.pink,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: Colors.pink,
                overlayColor: Colors.pink.withAlpha(32),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 30.0),
              ),
              child: Slider(
                value: _hba1cValue,
                min: 3.0,
                max: 17.0,
                divisions: 140,
                label: _hba1cValue.toStringAsFixed(1),
                onChanged: (double value) {
                  setState(() {
                    _hba1cValue = value;
                  });
                },
              ),
            ),
            Text(
              "A1C đơn vị ${isPercentage ? "%" : "mmol/mol"} (3.0 ~ 17.0)",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.black),
                  onPressed: () {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Get.to(() => ChatScreen(
                          userId: user.uid,
                          predefinedMessage: 'Xét nghiệm HbA1c là gì?'));
                    }
                  },
                ),
                const Text(
                  'Xét nghiệm HbA1c là gì?',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const Icon(Icons.chevron_right, color: Colors.black)
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý khi nhấn Tiếp tục
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Tiếp tục",
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