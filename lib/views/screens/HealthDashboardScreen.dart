// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import '../controller/health_service.dart';

class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({super.key});

  @override
  _HealthDashboardScreenState createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> {
  final HealthService _healthService = HealthService();
  Map<String, dynamic> _healthData = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeHealthService();
  }

  Future<void> _initializeHealthService() async {
    setState(() => _isLoading = true);
    try {
      await _healthService.initialize();
      bool authorized = await _healthService.requestAuthorization();
      if (authorized) {
        await _fetchData();
      } else {
        setState(() {
          _error = 'Health data access not authorized';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error initializing health service: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    try {
      final data = await _healthService.fetchAllHealthData();
      setState(() {
        _healthData = data;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = "Error fetching health data: $e";
        _isLoading = false;
      });
    }
  }

  Widget _buildHealthCard({
    required String title,
    required String value,
    required Widget icon,
    Color backgroundColor = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(width: 24, height: 24, child: icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addHealthData(HealthDataType type, String title) async {
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter value"),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                double value = double.parse(controller.text);
                bool success =
                    await _healthService.writeHealthData(type, value);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title added successfully')),
                  );
                  _fetchData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add $title')),
                  );
                }
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHealthCard(
                        title: 'Steps',
                        value: '${_healthData['steps'] ?? '0'}',
                        icon: const Icon(Icons.directions_walk,
                            color: Colors.blue),
                      ),
                      _buildHealthCard(
                        title: 'Heart Rate',
                        value: _healthData['heart_rate'] != null
                            ? '${_healthData['heart_rate']['value']} ${_healthData['heart_rate']['unit']}'
                            : 'N/A BPM',
                        icon: const Icon(Icons.favorite, color: Colors.red),
                      ),
                      _buildHealthCard(
                        title: 'Blood Pressure',
                        value: _healthData['blood_pressure'] != null
                            ? '${_healthData['blood_pressure']['systolic']}/${_healthData['blood_pressure']['diastolic']} ${_healthData['blood_pressure']['unit']}'
                            : 'N/A mmHg',
                        icon:
                            const Icon(Icons.show_chart, color: Colors.purple),
                      ),
                      _buildHealthCard(
                        title: 'Blood Glucose',
                        value: _healthData['blood_glucose'] != null
                            ? '${_healthData['blood_glucose']['value']} ${_healthData['blood_glucose']['unit']}'
                            : 'N/A mg/dL',
                        icon:
                            const Icon(Icons.water_drop, color: Colors.orange),
                      ),
                      _buildHealthCard(
                        title: 'Blood Oxygen',
                        value: _healthData['blood_oxygen'] != null
                            ? '${_healthData['blood_oxygen']['value']} ${_healthData['blood_oxygen']['unit']}'
                            : 'N/A %',
                        icon: const Icon(Icons.air, color: Colors.lightBlue),
                      ),
                      _buildHealthCard(
                        title: 'Weight',
                        value: _healthData['weight'] != null
                            ? '${_healthData['weight']['value']} ${_healthData['weight']['unit']}'
                            : 'N/A kg',
                        icon: const Icon(Icons.monitor_weight,
                            color: Colors.brown),
                      ),
                      _buildHealthCard(
                        title: 'Height',
                        value: _healthData['height'] != null
                            ? '${_healthData['height']['value']} ${_healthData['height']['unit']}'
                            : 'N/A cm',
                        icon: const Icon(Icons.height, color: Colors.green),
                      ),
                      _buildHealthCard(
                        title: 'Body Temperature',
                        value: _healthData['temperature'] != null
                            ? '${_healthData['temperature']['value']} ${_healthData['temperature']['unit']}'
                            : 'N/A °C',
                        icon: const Icon(Icons.thermostat, color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () =>
                            _healthService.openHealthConnectSettings(),
                        child: const Text(
                          'Open Health Connect Settings',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple.shade100,
        onPressed: () => _showAddDataDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDataDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add Health Data'),
        children: [
          SimpleDialogOption(
            child: const Text('Add Steps'),
            onPressed: () {
              Navigator.pop(context);
              _addHealthData(HealthDataType.STEPS, 'Steps');
            },
          ),
          SimpleDialogOption(
            child: const Text('Add Heart Rate'),
            onPressed: () {
              Navigator.pop(context);
              _addHealthData(HealthDataType.HEART_RATE, 'Heart Rate');
            },
          ),
          SimpleDialogOption(
            child: const Text('Add Blood Pressure (Systolic)'),
            onPressed: () {
              Navigator.pop(context);
              _addHealthData(HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
                  'Blood Pressure (Systolic)');
            },
          ),
          SimpleDialogOption(
            child: const Text('Add Blood Pressure (Diastolic)'),
            onPressed: () {
              Navigator.pop(context);
              _addHealthData(HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
                  'Blood Pressure (Diastolic)');
            },
          ),
          SimpleDialogOption(
            child: const Text('Add Blood Glucose'),
            onPressed: () {
              Navigator.pop(context);
              _addHealthData(HealthDataType.BLOOD_GLUCOSE, 'Blood Glucose');
            },
          ),
          SimpleDialogOption(
            child: const Text('Add Blood Oxygen'),
            onPressed: () {
              Navigator.pop(context);
              _addHealthData(HealthDataType.BLOOD_OXYGEN, 'Blood Oxygen');
            },
          ),
          SimpleDialogOption(
            child: const Text('Add Weight'),
            onPressed: () {
              Navigator.pop(context);
              _addHealthData(HealthDataType.WEIGHT, 'Weight');
            },
          ),
          SimpleDialogOption(
            child: const Text('Add Height'),
            onPressed: () {
              Navigator.pop(context);
              _addHealthData(HealthDataType.HEIGHT, 'Height');
            },
          ),
          SimpleDialogOption(
            child: const Text('Add Body Temperature'),
            onPressed: () {
              Navigator.pop(context);
              _addHealthData(
                  HealthDataType.BODY_TEMPERATURE, 'Body Temperature');
            },
          ),
        ],
      ),
    );
  }
}
