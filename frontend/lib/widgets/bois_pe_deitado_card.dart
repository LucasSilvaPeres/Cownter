import 'package:cownter/dtos/bois_pe_deitado_dto.dart';
import 'package:cownter/widgets/graficos/bois_pe_deitado_chart.dart';
import 'package:flutter/material.dart';

class BoisPeDeitadoCard extends StatelessWidget {
  final BoisPeDeitadoDTO dados;

  const BoisPeDeitadoCard({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    double porcentagemBoisDeitado = 0;
    double porcentagemBoisPe = 0;

    if (dados.qtdeBoisTotal > 0) {
      porcentagemBoisDeitado =
          (dados.qtdeBoisDeitado * 100 / dados.qtdeBoisTotal);
      porcentagemBoisPe = (dados.qtdeBoisPe * 100 / dados.qtdeBoisTotal);
    }

    return Container(
        width: double.infinity,
        height: 300,
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Expanded(
                        child: BoisPeDeitadoChart(
                            qtdeBoisDeitados: dados.qtdeBoisDeitado,
                            qtdeBoisPe: dados.qtdeBoisPe)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.green),
                              ),
                              Text("Bois em pé: ${dados.qtdeBoisPe}"),
                              Text("${porcentagemBoisPe.toInt()}%")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.yellow),
                              ),
                              Text("Bois deitados: ${dados.qtdeBoisDeitado}"),
                              Text("${porcentagemBoisDeitado.toInt()}%")
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ))));
  }
}
