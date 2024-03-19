import 'package:cownter/widgets/graficos/relatorio_geral_chart.dart';
import 'package:flutter/material.dart';


@immutable
class RelatorioGeralCard extends StatelessWidget {
  final String estadoBoi;
  final int qtdeBois;
  final int qtdeBoisTotal;

  const RelatorioGeralCard({super.key, required this.estadoBoi, required this.qtdeBois, required this.qtdeBoisTotal});

  @override
  Widget build(BuildContext context) {
    double porcentagemQtdeBois = 0;

    if (qtdeBoisTotal > 0) {
      porcentagemQtdeBois = (qtdeBois * 100 / qtdeBoisTotal);
    }
  
    return Expanded(
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estadoBoi),
                Text(
                  qtdeBois.toString(),
                  style: const TextStyle(
                    fontSize: 32,
                  )),
              ],
            ),
            SizedBox(
              width: 50,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RelatorioGeralChart(qtdeBois: qtdeBois, qtdeBoisTotal: qtdeBoisTotal),
                  Text("${porcentagemQtdeBois.floor()}%")
                ],
              ))
          ],
        )
      ),
    );
  }
}