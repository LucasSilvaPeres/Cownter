import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class BoisComendoBebendoChart extends StatelessWidget{
  final int qtdeBoisComendo;
  final int qtdeBoisBebendo;
  final int qtdeOutros;

  const BoisComendoBebendoChart({super.key, required this.qtdeBoisComendo, required this.qtdeBoisBebendo, required this.qtdeOutros});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 0,
        sections: <PieChartSectionData>[
          PieChartSectionData(
            color: Colors.green,
            value: qtdeBoisComendo.toDouble(),
            showTitle: false,
            radius: 75
          ),
          PieChartSectionData(
            color: Colors.yellow,
            value: qtdeBoisBebendo.toDouble(),
            showTitle: false,
            radius: 75
          ),
          PieChartSectionData(
            color: Colors.orange,
            value: qtdeOutros.toDouble(),
            showTitle: false,
            radius: 75
          )
        ]
      )
    );
  }
}