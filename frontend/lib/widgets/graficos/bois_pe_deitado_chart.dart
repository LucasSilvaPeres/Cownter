import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class BoisPeDeitadoChart extends StatelessWidget{
  final int qtdeBoisDeitados;
  final int qtdeBoisPe;

  const BoisPeDeitadoChart({super.key, required this.qtdeBoisDeitados, required this.qtdeBoisPe});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 0,
        sections: <PieChartSectionData>[
          PieChartSectionData(
            color: Colors.green,
            value: qtdeBoisPe.toDouble(),
            showTitle: false,
            radius: 75
          ),
          PieChartSectionData(
            color: Colors.yellow,
            value: qtdeBoisDeitados.toDouble(),
            showTitle: false,
            radius: 75
          )
        ]
      )
    );
  }
}