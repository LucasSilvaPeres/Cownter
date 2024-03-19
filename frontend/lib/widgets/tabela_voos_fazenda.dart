import 'package:cownter/constants/constants.dart';
import 'package:cownter/controllers/contagens_voo_modal_controller.dart';
import 'package:cownter/dtos/grafico_total_bois_voo_dto.dart';
import 'package:cownter/services/imagens_service.dart';
import 'package:cownter/utils/appRoutes.dart';
import 'package:cownter/utils/extensions.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';


class TabelaVoosFazenda extends StatelessWidget {
  const TabelaVoosFazenda(this.dados, {super.key});

  final GraficoTotalBoisDTO dados;

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      rowsPerPage: 3,
      columns: const <DataColumn>[
        DataColumn(label: Text("Data do voo")),
        DataColumn(numeric: true, label: Text("Total")),
        DataColumn(numeric: true, label: Text("Bebendo")),
        DataColumn(numeric: true, label: Text("Comendo")),
        DataColumn(numeric: true, label: Text("Deitado")),
        DataColumn(numeric: true, label: Text("Em pé")),
        DataColumn(numeric: true, label: Text("Detalhes")),
      ],
      source: DataSourceTabelaVoosFazenda(dados, context),
    );
  }
}

class DataSourceTabelaVoosFazenda extends DataTableSource {
  final BuildContext context;
  final GraficoTotalBoisDTO dados;
  final ContagensVooModalController modalController =
      GetIt.I.get<ContagensVooModalController>();
  final ImagemService imagemService = ImagemService(dotenv.env["COWNTER_API_URL"] ?? "");

  DataSourceTabelaVoosFazenda(this.dados, this.context);

  @override
  DataRow? getRow(int index) {
    var dado = dados.voos[index];

    return DataRow2(
        onTap: () async {
          modalController.atualizarContagens(dado.id);

          showDialog(
            context: context,
            useSafeArea: true,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return Observer(builder: (_) {
                if (modalController.contagens.isEmpty) {
                  return Container(
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator());
                } else {
                  return Container(
                    alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(100, 255, 255, 255)),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                childAspectRatio: 1,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0),
                        itemCount: modalController.contagens.length,
                        itemBuilder: (BuildContext context, int index) {
                          var contagem = modalController.contagens[index];
                          return FutureBuilder(
                            future: modalController.contagens[index].fetchImagem(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else {
                                double totalBois = (contagem.qtdeBoisEmPe + contagem.qtdeBoisDeitado + contagem.qtdeBoisBebendo + contagem.qtdeBoisComendo).toDouble();

                                return Container(
                                  alignment: Alignment.center,
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Flexible(flex: 1, child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.memory(contagem.imagem!),
                                        )),
                                        Text("${contagem.data.formattedDateHour}"),
                                        TextButton(child: const Text("Ver detalhes"), onPressed: () {
                                          showDialog(builder: (context) {
                                            return SizedBox(
                                              height: 600,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Hero(
                                                      tag: contagem.id,
                                                      child: Image.memory(contagem.imagem!)
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      padding: const EdgeInsets.all(16.0),
                                                      decoration: const BoxDecoration(color: Colors.white),
                                                      child: Column(
                                                        children: [
                                                          const Text("% DE BOIS", style: TextStyle(fontSize: 24)),
                                                          const SizedBox(height: 30),
                                                          Stack(
                                                            alignment: Alignment.center,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  const Text("Total", style: TextStyle(color: Colors.black45),),
                                                                  Text(
                                                                    totalBois.toString(),
                                                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 200,
                                                                child: PieChart(
                                                                  PieChartData(
                                                                    sections: <PieChartSectionData>[
                                                                      PieChartSectionData(
                                                                        color: Colors.red,
                                                                        value: contagem.qtdeBoisEmPe.toDouble(),
                                                                        showTitle: true,
                                                                        title: "${((contagem.qtdeBoisEmPe / totalBois) * 100).toStringAsFixed(2)}%",
                                                                        radius: 30,
                                                                        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                                                                          Shadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 4.0)
                                                                        ] )
                                                                      ),
                                                                      PieChartSectionData(
                                                                        color: Colors.blue,
                                                                        value: contagem.qtdeBoisDeitado.toDouble(),
                                                                        showTitle: true,
                                                                        title: "${((contagem.qtdeBoisDeitado / totalBois) * 100).toStringAsFixed(2)}%",
                                                                        radius: 30,
                                                                        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                                                                          Shadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 4.0)
                                                                        ] )
                                                                      ),
                                                                      PieChartSectionData(
                                                                        color: Colors.green,
                                                                        value: contagem.qtdeBoisComendo.toDouble(),
                                                                        showTitle: true,
                                                                        radius: 30,
                                                                        title: "${((contagem.qtdeBoisComendo / totalBois) * 100).toStringAsFixed(2)}%",
                                                                        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                                                                          Shadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 4.0)
                                                                        ] )
                                                                      ),
                                                                      PieChartSectionData(
                                                                        color: Colors.yellow,
                                                                        value: contagem.qtdeBoisBebendo.toDouble(),
                                                                        showTitle: true,
                                                                        title: "${((contagem.qtdeBoisBebendo / totalBois) * 100).toStringAsFixed(2)}%",
                                                                        radius: 30,
                                                                        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                                                                          Shadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 4.0)
                                                                        ] )
                                                                      ),
                                                                    ]
                                                                  )
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 30),
                                                          Column(
                                                            children: [
                                                              Container(padding: const EdgeInsets.all(8.0), alignment: Alignment.centerLeft, child: const Text("Quantidade", style: TextStyle(fontSize: 18), textAlign: TextAlign.start)),
                                                              Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(16.0),
                                                                    child: Column(children: [
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red),),
                                                                          const SizedBox(width: 20,),
                                                                          const Text("Em pé"),
                                                                          const SizedBox(width: 20,),
                                                                          Text(contagem.qtdeBoisEmPe.toString()),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.blue),),
                                                                          const SizedBox(width: 20,),
                                                                          const Text("Deitado"),
                                                                          const SizedBox(width: 20,),
                                                                          Text(contagem.qtdeBoisDeitado.toString()),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green),),
                                                                          const SizedBox(width: 20,),
                                                                          const Text("Comendo"),
                                                                          const SizedBox(width: 20,),
                                                                          Text(contagem.qtdeBoisComendo.toString()),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.yellow),),
                                                                          const SizedBox(width: 20,),
                                                                          const Text("Bebendo"),
                                                                          const SizedBox(width: 20,),
                                                                          Text(contagem.qtdeBoisBebendo.toString()),
                                                                        ],
                                                                      )
                                                                    ],
                                                                                                                          ),
                                                                  ),
                                                                ],
                                                              )
                                                          ],)
                                                        ],
                                                      )
                                                    ))
                                                ],
                                              ),
                                            );
                                          }, context: context);
                                        })
                                      ],
                                    ),
                                  ),
                                );
                              }
                            });
                        },
                      ));
                }
              });
            },
          );
        },
        cells: <DataCell>[
          DataCell(Text(dado.data.formattedDateDDMMYY)),
          DataCell(Text((dado.qtdeBoisEmPe + dado.qtdeBoisDeitado + dado.qtdeBoisBebendo + dado.qtdeBoisComendo).toString())),
          DataCell(Text(dado.qtdeBoisBebendo.toString())),
          DataCell(Text(dado.qtdeBoisComendo.toString())),
          DataCell(Text(dado.qtdeBoisDeitado.toString())),
          DataCell(Text(dado.qtdeBoisEmPe.toString())),
          DataCell(IconButton(color: primaryColor, icon: const Icon(Icons.search), onPressed: () {
            Navigator.pushNamed(context, AppRoutes.PIQUETES,
              arguments: PiquetesRouteArguments(dado.data));
          },)),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => 3;

  @override
  int get selectedRowCount => 3;
}
