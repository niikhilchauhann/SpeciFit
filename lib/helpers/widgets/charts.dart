// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import '../../utilities/export.dart';

// int touchedIndex = -1;
// List<PieChartSectionData> showingSections() {
//   return List.generate(3, (i) {
//     final isTouched = i == touchedIndex;
//     final fontSize = isTouched ? 14.0 : 14.0;

//     final radius = isTouched ? 52.0 : 44.0;
//     switch (i) {
//       case 0:
//         return PieChartSectionData(
//           color: carbscolor,
//           value: 50,
//           title: isTouched ? 'Carbs' : '55%',
//           radius: radius,
//           titleStyle: TextStyle(
//             fontSize: fontSize,
//             fontWeight: FontWeight.bold,
//             color: bgcolor,
//           ),
//         );
//       case 1:
//         return PieChartSectionData(
//           color: proteincolor,
//           value: 30,
//           title: isTouched ? 'Protein' : '20%',
//           radius: radius,
//           titleStyle: TextStyle(
//             fontSize: fontSize,
//             fontWeight: FontWeight.bold,
//             color: bgcolor,
//           ),
//         );
//       case 2:
//         return PieChartSectionData(
//           color: fatcolor,
//           value: 35,
//           title: isTouched ? 'Fat' : '25%',
//           radius: radius,
//           titleStyle: TextStyle(
//             fontSize: fontSize,
//             fontWeight: FontWeight.bold,
//             color: bgcolor,
//           ),
//         );

//       default:
//         throw Error();
//     }
//   });
// }
