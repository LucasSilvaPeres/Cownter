import 'package:cownter/constants/constants.dart';
import 'package:cownter/dtos/grafico_total_bois_voo_dto.dart';
import 'package:cownter/utils/conversors.dart';
import 'package:cownter/utils/extensions.dart';
import 'package:darq/darq.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficoAcaoBoisVoo extends StatelessWidget {
  final GraficoTotalBoisDTO dto;

  const GraficoAcaoBoisVoo(this.dto, {super.key});

  FlTitlesData get titlesData {
    return FlTitlesData(
      topTitles: AxisTitles(
        axisNameWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: 10, width: 30, decoration: const BoxDecoration(color: primaryColor)),
            const SizedBox(width: 30,),
            const Text("Bois comendo"),
            const SizedBox(width: 100),
            Container(height: 10, width: 30, decoration: const BoxDecoration(color: tertiaryColor)),
            const SizedBox(width: 30,),
            const Text("Bois bebendo"),
          ],
        )
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          interval: 20,
          reservedSize: 50,
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(julian2DateTime(value.toInt()).formattedDateDDMMYY),
            );
          }
        )
      )
    );
  }

  LineChartData get lineChartData {
    List<FlSpot> spotsBoisEmPe = dto.voos.map((e) {

      return FlSpot(e.data.toJulian.toDouble(), e.qtdeBoisEmPe.toDouble());
    }).toList();

    List<FlSpot> spotsBoisDeitado = dto.voos.map((e) {
      return FlSpot(e.data.toJulian.toDouble(), e.qtdeBoisDeitado.toDouble());
    }).toList();
    
    return LineChartData(
      gridData: FlGridData(show: true),
      lineBarsData: [
        LineChartBarData(
          isCurved: false,
          color: primaryColor,
          spots: spotsBoisEmPe
        ),
        LineChartBarData(
          isCurved: false,
          color: tertiaryColor,
          spots: spotsBoisDeitado
        )
      ],
      titlesData: titlesData
    );
  }

  BarChart get barChart {
    final GraficoTotalBoisVooDTO vooComMaisBois = dto.voos.max((e1, e2) {
        final boisE1 = e1.qtdeBoisBebendo + e1.qtdeBoisComendo;
        final boisE2 = e2.qtdeBoisBebendo + e2.qtdeBoisComendo;

        return boisE1 > boisE2 ? 1 : 0;
    });

    double maxY = vooComMaisBois.qtdeBoisBebendo + vooComMaisBois.qtdeBoisComendo as double;
    
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          drawVerticalLine: false,
          drawHorizontalLine: true),
        borderData: FlBorderData(
          border: const Border(
            bottom: BorderSide(color: Colors.black54)
          )),
        maxY: maxY,
        titlesData: titlesData,
        barGroups: dto.voos.map((e) {
          return BarChartGroupData(
            x: e.data.toJulian,
            barRods: [
              BarChartRodData(
                width: 10,
                toY: (e.qtdeBoisBebendo.toDouble()),
                borderRadius: BorderRadius.zero,
                color: primaryColor
              ),
              BarChartRodData(
                width: 10,
                toY: (e.qtdeBoisComendo.toDouble()),
                borderRadius: BorderRadius.zero,
                color: tertiaryColor
              )
            ]
          );
        }).toList()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return barChart;
  }
}