// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';
// import '../controller/BMIController.dart';

// class BmiScreen extends StatelessWidget {
//   final BMIController bmiController = Get.put(BMIController());

//   const BmiScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Chỉ số khối cơ thể (BMI)')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Hiển thị ngày tháng
//             const Text(
//               '19 THG 9, 2024',
//               style: TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 20),

//             // Biểu đồ gauge BMI
//             SizedBox(
//               height: 250,
//               child: SfRadialGauge(
//                 axes: <RadialAxis>[
//                   RadialAxis(
//                     minimum: 10,
//                     maximum: 40,
//                     showLabels: false,
//                     showTicks: false,
//                     ranges: <GaugeRange>[
//                       GaugeRange(
//                         startValue: 10,
//                         endValue: 18.5,
//                         color: Colors.blue,
//                         startWidth: 20,
//                         endWidth: 20,
//                       ),
//                       GaugeRange(
//                         startValue: 18.5,
//                         endValue: 25,
//                         color: Colors.green,
//                         startWidth: 20,
//                         endWidth: 20,
//                       ),
//                       GaugeRange(
//                         startValue: 25,
//                         endValue: 30,
//                         color: Colors.orange,
//                         startWidth: 20,
//                         endWidth: 20,
//                       ),
//                       GaugeRange(
//                         startValue: 30,
//                         endValue: 40,
//                         color: Colors.red,
//                         startWidth: 20,
//                         endWidth: 20,
//                       ),
//                     ],
//                     pointers: <GaugePointer>[
//                       NeedlePointer(
//                         value: bmiController.bmiValue.value,
//                         enableAnimation: true,
//                         animationType: AnimationType.easeOutBack,
//                       ),
//                     ],
//                     annotations: <GaugeAnnotation>[
//                       GaugeAnnotation(
//                         widget: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               bmiController.bmiValue.value.toStringAsFixed(1),
//                               style: const TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               bmiController.bmiCategory.value,
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 color: bmiController.bmiColor.value,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         angle: 90,
//                         positionFactor: 0.75,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
