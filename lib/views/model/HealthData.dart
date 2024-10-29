class HealthData {
  final String date;
  final String status;

  HealthData({required this.date, required this.status});

  // Convert the object to a list for CSV generation
  List<String> toCsvRow() {
    return [date, status];
  }
}
