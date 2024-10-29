import 'package:flutter/material.dart';

class DayCell extends StatelessWidget {
  final int day;
  final bool isCurrentMonth;
  final double progressPercent;

  const DayCell({
    super.key,
    required this.day,
    required this.isCurrentMonth,
    required this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrentMonth ? Colors.grey[200] : Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (progressPercent > 0)
            CircularProgressIndicator(
              value: progressPercent,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[200]!),
              strokeWidth: 2,
            ),
          Text(
            day.toString(),
            style: TextStyle(
              color: isCurrentMonth ? Colors.black87 : Colors.grey[400],
              fontWeight: FontWeight.w500,
              fontSize: 14, // Điều chỉnh kích thước chữ nếu cần
            ),
          ),
        ],
      ),
    );
  }
}