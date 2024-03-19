import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RelatorioGeralChart extends StatelessWidget {
  final int qtdeBois;
  final int qtdeBoisTotal;

  const RelatorioGeralChart({super.key, required this.qtdeBois, required this.qtdeBoisTotal});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 25,
        startDegreeOffset: -90,
        sections: <PieChartSectionData>[
          PieChartSectionData(
            color: Colors.green,
            value: qtdeBois.toDouble(),
            radius: 5,
            showTitle: false
          ),
          PieChartSectionData(
            color: Colors.yellow,
            value: qtdeBoisTotal.toDouble(),
            radius: 5,
            showTitle: false
          )
        ]
      )
    );
  }
}
