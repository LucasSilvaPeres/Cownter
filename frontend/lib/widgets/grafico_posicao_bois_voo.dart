import 'package:cownter/constants/constants.dart';
import 'package:cownter/dtos/grafico_total_bois_voo_dto.dart';
import 'package:cownter/utils/conversors.dart';
import 'package:cownter/utils/extensions.dart';
import 'package:darq/darq.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficoPosicaoBoisVoo extends StatelessWidget {
  final GraficoTotalBoisDTO dto;


  const GraficoPosicaoBoisVoo(this.dto, {super.key});

  FlTitlesData get titlesData {
    return FlTitlesData(
      topTitles: AxisTitles(
        axisNameWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: 10, width: 30, decoration: const BoxDecoration(color: primaryColor)),
            const SizedBox(width: 30,),
            const Text("Bois em pé"),
            const SizedBox(width: 100),
            Container(height: 10, width: 30, decoration: const BoxDecoration(color: tertiaryColor)),
            const SizedBox(width: 30,),
            const Text("Bois deitados"),
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

    final GraficoTotalBoisVooDTO vooComMaisBois = dto.voos.max((e1, e2) {
        final boisE1 = e1.qtdeBoisBebendo + e1.qtdeBoisComendo + e1.qtdeBoisDeitado + e1.qtdeBoisEmPe;
        final boisE2 = e2.qtdeBoisBebendo + e2.qtdeBoisComendo + e2.qtdeBoisDeitado + e2.qtdeBoisEmPe;

        return boisE1 > boisE2 ? 1 : 0;
    });

    double maxY = vooComMaisBois.qtdeBoisBebendo + vooComMaisBois.qtdeBoisComendo + vooComMaisBois.qtdeBoisDeitado + vooComMaisBois.qtdeBoisEmPe * 1.25;
    
    return LineChartData(
      borderData: FlBorderData(
        border: const Border(
          left: BorderSide(color: Colors.black54),
          bottom: BorderSide(color: Colors.black54)
        )),
      maxY: maxY,
      minY: 0,
      maxX: dto.voos.last.data.toJulian.toDouble() + 7,
      minX: dto.voos.first.data.toJulian.toDouble() - 7,
      gridData: FlGridData(
        drawVerticalLine: false,
        drawHorizontalLine: true),
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

  @override
  Widget build(BuildContext context) {
    return LineChart(
          lineChartData,
        );
  }
}