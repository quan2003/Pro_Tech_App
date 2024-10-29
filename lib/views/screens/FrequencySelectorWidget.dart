import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FrequencySelectorWidget extends StatefulWidget {
  final Function(String, Map<String, dynamic>) onSelect;
  final String initialFrequency;
  final Map<String, dynamic> initialFrequencyDetails;

  const FrequencySelectorWidget({
    super.key,
    required this.onSelect,
    required this.initialFrequency,
    required this.initialFrequencyDetails,
  });

  @override
  _FrequencySelectorWidgetState createState() => _FrequencySelectorWidgetState();
}

class _FrequencySelectorWidgetState extends State<FrequencySelectorWidget> {
  late String selectedFrequency;
  late Map<String, dynamic> frequencyDetails;

  final List<String> frequencies = [
    'Cách ngày',
    'Mỗi ngày',
    'Ngày cụ thể trong tuần',
    'Chỉ khi cần'
  ];

  final List<String> daysOfWeek = [
    'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'
  ];

  @override
  void initState() {
    super.initState();
    selectedFrequency = widget.initialFrequency;
    frequencyDetails = Map.from(widget.initialFrequencyDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tần suất',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...frequencies.map((frequency) => _buildFrequencyItem(frequency)),
          const SizedBox(height: 20),
          if (selectedFrequency == 'Cách ngày')
            _buildEveryNDaysSelector()
          else if (selectedFrequency == 'Ngày cụ thể trong tuần')
            _buildSpecificDaysSelector(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSelect(selectedFrequency, frequencyDetails);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Lưu', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyItem(String frequency) {
    bool isSelected = selectedFrequency == frequency;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFrequency = frequency;
          if (!frequencyDetails.containsKey(frequency)) {
            frequencyDetails[frequency] = frequency == 'Cách ngày' ? 2 : [];
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(frequency, style: const TextStyle(fontSize: 16)),
            if (isSelected)
              const Icon(Icons.check, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildEveryNDaysSelector() {
    int everyNDays = frequencyDetails['Cách ngày'] ?? 2;
    return SizedBox(
      height: 200,
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: everyNDays - 1),
        itemExtent: 40,
        onSelectedItemChanged: (index) {
          setState(() {
            frequencyDetails['Cách ngày'] = index + 1;
          });
        },
        children: List.generate(365, (index) {
          return Center(
            child: Text(
              'Mỗi ${index + 1} ngày',
              style: const TextStyle(fontSize: 16),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSpecificDaysSelector() {
    List<String> selectedDays = List<String>.from(frequencyDetails['Ngày cụ thể trong tuần'] ?? []);
    return Column(
      children: daysOfWeek.map((day) {
        bool isSelected = selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedDays.remove(day);
              } else {
                selectedDays.add(day);
              }
              frequencyDetails['Ngày cụ thể trong tuần'] = selectedDays;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(day, style: const TextStyle(fontSize: 16)),
                if (isSelected)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}