import 'package:flutter/material.dart';

class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  _DeviceManagementPageState createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  List<Map<String, dynamic>> devices = [
    {'name': 'Device 1', 'warranty': '8/16/22', 'purchase': '10 Dec 2019', 'active': true},
    {'name': 'Device 2', 'warranty': '8/16/25', 'purchase': '10 Dec 2022', 'active': true},
    {'name': 'Device 3', 'warranty': '8/16/24', 'purchase': '10 Dec 2020', 'active': true},
    {'name': 'Device 4', 'warranty': '8/16/24', 'purchase': '10 Dec 2020', 'active': true},
    {'name': 'Device 1', 'warranty': '8/16/22', 'purchase': '10 Dec 2019', 'active': true},
    {'name': 'Device 2', 'warranty': '8/16/25', 'purchase': '10 Dec 2022', 'active': true},
    {'name': 'Device 3', 'warranty': '8/16/24', 'purchase': '10 Dec 2020', 'active': true},
    {'name': 'Device 4', 'warranty': '8/16/24', 'purchase': '10 Dec 2020', 'active': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device'),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.filter_list),
            label: const Text('Filter'),
            onPressed: () {
              // Implement filter functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Device Name')),
            DataColumn(label: Text('Warranty date')),
            DataColumn(label: Text('Purchase date')),
            DataColumn(label: Text('Device Control')),
            DataColumn(label: Text('Actions')),
          ],
          rows: devices.map((device) {
            return DataRow(cells: [
              DataCell(Text(device['name'])),
              DataCell(Text(device['warranty'])),
              DataCell(Text(device['purchase'])),
              DataCell(Row(
                children: [
                  Text(device['active'] ? 'Active' : 'Inactive'),
                  Switch(
                    value: device['active'],
                    onChanged: (bool value) {
                      setState(() {
                        device['active'] = value;
                      });
                    },
                    activeColor: Colors.teal,
                  ),
                  const Text('Deactivate', style: TextStyle(color: Colors.red)),
                ],
              )),
              const DataCell(Icon(Icons.visibility)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}