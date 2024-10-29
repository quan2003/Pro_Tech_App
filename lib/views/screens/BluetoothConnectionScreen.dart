// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';

// void main() {
//   runApp(XiaomiBandApp());
// }

// class XiaomiBandApp extends StatelessWidget {
//   const XiaomiBandApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Xiaomi Band 8 App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: StreamBuilder<BluetoothState>(
//         stream: FlutterBlue.instance.state,
//         initialData: BluetoothState.unknown,
//         builder: (c, snapshot) {
//           final state = snapshot.data;
//           if (state == BluetoothState.on) {
//             return FindDevicesScreen();
//           }
//           return BluetoothOffScreen(state: state);
//         },
//       ),
//     );
//   }
// }

// class BluetoothOffScreen extends StatelessWidget {
//   const BluetoothOffScreen({super.key, this.state});

//   final BluetoothState? state;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.lightBlue,
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Icon(
//               Icons.bluetooth_disabled,
//               size: 200.0,
//               color: Colors.white54,
//             ),
//             Text(
//               'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FindDevicesScreen extends StatelessWidget {
//   const FindDevicesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tìm Xiaomi Band 8'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () => FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
//         child: SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//               StreamBuilder<List<ScanResult>>(
//                 stream: FlutterBlue.instance.scanResults,
//                 initialData: const [],
//                 builder: (c, snapshot) => Column(
//                   children: snapshot.data!
//                       .where((r) => r.device.name.contains('Xiaomi Smart Band 8 D673'))
//                       .map(
//                         (r) => ListTile(
//                           title: Text(r.device.name),
//                           subtitle: Text(r.device.id.toString()),
//                           trailing: ElevatedButton(
//                             child: Text('KẾT NỐI'),
//                             onPressed: () => Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) => DeviceScreen(device: r.device),
//                               ),
//                             ),
//                           ),
//                         ),
//                       )
//                       .toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: StreamBuilder<bool>(
//         stream: FlutterBlue.instance.isScanning,
//         initialData: false,
//         builder: (c, snapshot) {
//           if (snapshot.data!) {
//             return FloatingActionButton(
//               onPressed: () => FlutterBlue.instance.stopScan(),
//               backgroundColor: Colors.red,
//               child: Icon(Icons.stop),
//             );
//           } else {
//             return FloatingActionButton(
//               child: Icon(Icons.search),
//               onPressed: () => FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// class DeviceScreen extends StatelessWidget {
//   const DeviceScreen({super.key, required this.device});

//   final BluetoothDevice device;

//   // UUID cho Xiaomi Smart Band 8 (cần xác nhận lại)
//   final String HEART_RATE_SERVICE_UUID = "0000180d-0000-1000-8000-00805f9b34fb";
//   final String HEART_RATE_CHARACTERISTIC_UUID = "00002a37-0000-1000-8000-00805f9b34fb";
//   final String STEPS_SERVICE_UUID = "0000fee0-0000-1000-8000-00805f9b34fb";
//   final String STEPS_CHARACTERISTIC_UUID = "00000007-0000-3512-2118-0009af100700";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(device.name),
//         actions: <Widget>[
//           StreamBuilder<BluetoothDeviceState>(
//             stream: device.state,
//             initialData: BluetoothDeviceState.connecting,
//             builder: (c, snapshot) {
//               VoidCallback? onPressed;
//               String text;
//               switch (snapshot.data) {
//                 case BluetoothDeviceState.connected:
//                   onPressed = () => device.disconnect();
//                   text = 'NGẮT KẾT NỐI';
//                   break;
//                 case BluetoothDeviceState.disconnected:
//                   onPressed = () => device.connect();
//                   text = 'KẾT NỐI';
//                   break;
//                 default:
//                   onPressed = null;
//                   text = snapshot.data.toString().substring(21).toUpperCase();
//                   break;
//               }
//               return TextButton(
//                 onPressed: onPressed,
//                 child: Text(
//                   text,
//                   style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
//                 ),
//               );
//             },
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             StreamBuilder<BluetoothDeviceState>(
//               stream: device.state,
//               initialData: BluetoothDeviceState.connecting,
//               builder: (c, snapshot) => ListTile(
//                 leading: (snapshot.data == BluetoothDeviceState.connected)
//                     ? Icon(Icons.bluetooth_connected)
//                     : Icon(Icons.bluetooth_disabled),
//                 title: Text('Trạng thái: ${snapshot.data.toString().split('.')[1]}.'),
//                 subtitle: Text('${device.id}'),
//                 trailing: StreamBuilder<bool>(
//                   stream: device.isDiscoveringServices,
//                   initialData: false,
//                   builder: (c, snapshot) => IndexedStack(
//                     index: snapshot.data! ? 1 : 0,
//                     children: <Widget>[
//                       IconButton(
//                         icon: Icon(Icons.refresh),
//                         onPressed: () => device.discoverServices(),
//                       ),
//                       IconButton(
//                         icon: SizedBox(
//                           width: 18.0,
//                           height: 18.0,
//                           child: CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation(Colors.grey),
//                           ),
//                         ),
//                         onPressed: null,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             StreamBuilder<List<BluetoothService>>(
//               stream: device.services,
//               initialData: const [],
//               builder: (c, snapshot) {
//                 return Column(
//                   children: snapshot.data!.map((s) {
//                     if (s.uuid.toString() == HEART_RATE_SERVICE_UUID) {
//                       return _buildHeartRateService(s);
//                     } else if (s.uuid.toString() == STEPS_SERVICE_UUID) {
//                       return _buildStepsService(s);
//                     }
//                     return SizedBox(); // Bỏ qua các dịch vụ khác
//                   }).toList(),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeartRateService(BluetoothService service) {
//     return StreamBuilder<List<int>>(
//       stream: service.characteristics
//           .firstWhere((c) => c.uuid.toString() == HEART_RATE_CHARACTERISTIC_UUID)
//           .value,
//       initialData: const [],
//       builder: (c, snapshot) {
//         final value = snapshot.data;
//         return ListTile(
//           title: Text('Nhịp tim'),
//           subtitle: Text('${value!.isNotEmpty ? value[1] : 0} BPM'),
//           trailing: ElevatedButton(
//             child: Text('Đọc'),
//             onPressed: () => service.characteristics
//                 .firstWhere((c) => c.uuid.toString() == HEART_RATE_CHARACTERISTIC_UUID)
//                 .read(),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStepsService(BluetoothService service) {
//     return StreamBuilder<List<int>>(
//       stream: service.characteristics
//           .firstWhere((c) => c.uuid.toString() == STEPS_CHARACTERISTIC_UUID)
//           .value,
//       initialData: const [],
//       builder: (c, snapshot) {
//         final value = snapshot.data;
//         int steps = 0;
//         if (value!.isNotEmpty && value.length >= 2) {
//           steps = (value[1] << 8) | value[0];
//         }
//         return ListTile(
//           title: Text('Số bước chân'),
//           subtitle: Text('$steps'),
//           trailing: ElevatedButton(
//             child: Text('Đọc'),
//             onPressed: () => service.characteristics
//                 .firstWhere((c) => c.uuid.toString() == STEPS_CHARACTERISTIC_UUID)
//                 .read(),
//           ),
//         );
//       },
//     );
//   }
// }