import 'package:cownter/dtos/tempo_confinamento_dto.dart';
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";



class RelatorioTempoConfinamentoChart extends StatefulWidget {
  final List<BoisTempoConfinamentoDTO> dadosRelatorio;

  const RelatorioTempoConfinamentoChart({super.key, required this.dadosRelatorio});

  final Color corQtdeBoisEmPe = Colors.green;
  final Color corQtdeBoisDeitados = Colors.yellow;
  final Color corMedia = Colors.cyan;

  @override
  State<RelatorioTempoConfinamentoChart> createState() => _RelatorioTempoConfinamentoChartState();
}

class _RelatorioTempoConfinamentoChartState extends State<RelatorioTempoConfinamentoChart> {

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  BarChartGroupData makeGroupData(BoisTempoConfinamentoDTO dado) {
    return BarChartGroupData(
      barsSpace: 0,
      x: dado.qtdeDias,
      barRods: [
        BarChartRodData(
          toY: dado.qtdeBoisEmPe.toDouble(),
          color: widget.corQtdeBoisEmPe,
          width: 5,
        ),
        BarChartRodData(
          toY: dado.qtdeBoisDeitados.toDouble(),
          color: widget.corQtdeBoisDeitados,
          width: 5
        ),
      ]
    );
  }

  handleTouchCallback(FlTouchEvent event, BarTouchResponse? response) {
    if (response == null || response.spot == null) {
      setState(() {
        touchedGroupIndex = -1;
        showingBarGroups = List.of(rawBarGroups);
      });
      return;
    }

    touchedGroupIndex = response.spot!.touchedBarGroupIndex;

    setState(() {
      if (!event.isInterestedForInteractions) {
        touchedGroupIndex = -1;
        showingBarGroups = List.of(rawBarGroups);

        return;
      }

      showingBarGroups = List.of(rawBarGroups);

      if (touchedGroupIndex != -1) {
        var sum = 0.0;

        for (final rod in showingBarGroups[touchedGroupIndex].barRods) {
          sum += rod.toY;
        }

        final avg = sum / showingBarGroups[touchedGroupIndex].barRods.length;

        showingBarGroups[touchedGroupIndex] = showingBarGroups[touchedGroupIndex].copyWith(
          barRods: showingBarGroups[touchedGroupIndex].barRods.map((rod) {
            return rod.copyWith(toY: avg, color: widget.corMedia);
          }).toList()
        );
      }
    });
  }

  AxisTitles makeRightAxisTitles() {
    return AxisTitles(
      sideTitles: SideTitles(showTitles: false)
    );
  }

  AxisTitles makeTopAxisTitles() {
    return AxisTitles(
      sideTitles: SideTitles(showTitles: false)
    );
  }

  AxisTitles makeBottomAxisTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) => SideTitleWidget(axisSide: meta.axisSide, space: 6, child: Text("$value dias", style: const TextStyle(fontSize: 12))),
      )
    );
  }

  AxisTitles makeLeftAxisTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) => SideTitleWidget(axisSide: meta.axisSide, space: 6, child: Text("$value", style: const TextStyle(fontSize: 12))),
        interval: 10,
        reservedSize: 32
      )
    );
  }

  FlTitlesData makeFLTitleData() {
    return FlTitlesData(
      show: true,
      rightTitles: makeRightAxisTitles(),
      topTitles: makeTopAxisTitles(),
      bottomTitles: makeBottomAxisTitles(),
      leftTitles: makeLeftAxisTitles()
    );
  }

  BarTouchData makeBarTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.grey,
        getTooltipItem: (a, b, c, d) => null
      ),
      touchCallback: handleTouchCallback,
    );
  }

  @override
  void initState() {
    super.initState();

    final items = widget.dadosRelatorio.map((dado) => makeGroupData(dado)).toList();

    rawBarGroups = items;
    showingBarGroups = rawBarGroups;
  }

  FlGridData makeFlGridData() {
    return FlGridData(
      drawHorizontalLine: true,
      drawVerticalLine: false,
      horizontalInterval: 10,
      getDrawingHorizontalLine: (value) => FlLine(color: Colors.black38, strokeWidth: 0.5));
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: makeFlGridData(),
        borderData: FlBorderData(show: false),
        maxY: 100,
        barTouchData: makeBarTouchData(),
        titlesData: makeFLTitleData(),
        barGroups: showingBarGroups
      )
    );
  }
}
