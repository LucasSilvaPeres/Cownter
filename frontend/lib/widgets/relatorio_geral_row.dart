import 'package:cownter/dtos/relatorio_geral_dto.dart';
import 'package:cownter/widgets/relatorio_geral_card.dart';
import 'package:flutter/material.dart';

class RelatorioGeralRow extends StatelessWidget {
  final RelatorioGeralDTO dados;

  const RelatorioGeralRow({super.key, required this.dados});
  

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <RelatorioGeralCard> [
        RelatorioGeralCard(
          estadoBoi: "Bois em pé",
          qtdeBois: dados.qtdeBoisPe,
          qtdeBoisTotal: dados.qtdeBoisTotal),
        RelatorioGeralCard(
          estadoBoi: "Bois deitados",
          qtdeBois: dados.qtdeBoisDeitado,
          qtdeBoisTotal: dados.qtdeBoisTotal),
        RelatorioGeralCard(estadoBoi: "Bois comendo",
        qtdeBois: dados.qtdeBoisComendo,
        qtdeBoisTotal: dados.qtdeBoisTotal),
        RelatorioGeralCard(estadoBoi: "Bois bebendo",
        qtdeBois: dados.qtdeBoisBebendo,
        qtdeBoisTotal: dados.qtdeBoisTotal),
      ]
    );
  }
}