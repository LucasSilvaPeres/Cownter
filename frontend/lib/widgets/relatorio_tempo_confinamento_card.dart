import 'package:cownter/dtos/tempo_confinamento_dto.dart';
import 'package:cownter/widgets/graficos/relatorio_tempo_confinamento_chart.dart';
import 'package:flutter/material.dart';

List<BoisTempoConfinamentoDTO> fakeData = [
  BoisTempoConfinamentoDTO(-50, 64, 80),
  BoisTempoConfinamentoDTO(-40, 11, 47),
  BoisTempoConfinamentoDTO(-30, 77, 24),
  BoisTempoConfinamentoDTO(-20, 1, 44),
  BoisTempoConfinamentoDTO(-10, 3, 87),
  BoisTempoConfinamentoDTO(0, 34, 24),
  BoisTempoConfinamentoDTO(10, 66, 14),
  BoisTempoConfinamentoDTO(20, 55, 66),
  BoisTempoConfinamentoDTO(30, 97, 25),
  BoisTempoConfinamentoDTO(40, 74, 84),
  BoisTempoConfinamentoDTO(50, 20, 10),
];

class RelatorioTempoConfinamentoCard extends StatelessWidget {
  final List<BoisTempoConfinamentoDTO> dadosRelatorio;

  const RelatorioTempoConfinamentoCard(
      {super.key, required this.dadosRelatorio});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 300,
        child: Card(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: RelatorioTempoConfinamentoChart(dadosRelatorio: fakeData),
        )));
  }
}
