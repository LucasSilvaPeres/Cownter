import 'package:cownter/dtos/bois_comendo_bebendo_dto.dart';
import 'package:cownter/widgets/graficos/bois_comendo_bebendo_chart.dart';
import 'package:flutter/material.dart';

class BoisComendoBebendoCard extends StatelessWidget {
  final BoisComendoBebendoDTO dados;

  const BoisComendoBebendoCard({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    double porcentagemBoisComendo = 0;
    double porcentagemBoisBebendo = 0;
    double porcentagemOutros = 0;

    if (dados.qtdeBoisTotal > 0) {
      porcentagemBoisComendo =
          (dados.qtdeBoisComendo * 100 / dados.qtdeBoisTotal);
      porcentagemBoisBebendo =
          (dados.qtdeBoisBebendo * 100 / dados.qtdeBoisTotal);
      porcentagemOutros = (dados.qtdeOutros * 100 / dados.qtdeBoisTotal);
    }

    return SizedBox(
        width: double.infinity,
        height: 300,
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Expanded(
                        child: BoisComendoBebendoChart(
                            qtdeBoisComendo: dados.qtdeBoisComendo,
                            qtdeBoisBebendo: dados.qtdeBoisBebendo,
                            qtdeOutros: dados.qtdeOutros)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green),
                              ),
                              Text("Bois comendo: ${dados.qtdeBoisBebendo}"),
                              Text("${porcentagemBoisBebendo.toInt()}%")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.yellow),
                              ),
                              Text("Bois bebendo: ${dados.qtdeBoisComendo}"),
                              Text("${porcentagemBoisComendo.toInt()}%")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.orange),
                              ),
                              Text("Outros: ${dados.qtdeOutros}"),
                              Text("${porcentagemOutros.toInt()}")
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ))));
  }
}
