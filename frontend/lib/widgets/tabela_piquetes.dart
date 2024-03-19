import 'package:cownter/constants/constants.dart';
import 'package:cownter/dtos/tabela_piquete_dto.dart';
import 'package:cownter/services/imagens_service.dart';
import 'package:cownter/utils/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TabelaPiquetes extends StatefulWidget {
  final List<TabelaPiqueteDTO> dadosTabela;

  const TabelaPiquetes({super.key, required this.dadosTabela});

  @override
  State<TabelaPiquetes> createState() => _TabelaPiquetesState();
}

class _TabelaPiquetesState extends State<TabelaPiquetes> {
  Uint8List? imagemContagem;

  void MostraImagem(String idContagem) async {
    var service = ImagemService(dotenv.env["COWNTER_API_URL"] ?? "");

    var imagemData = await service.fetchArquivoImagem(idContagem);

    showDialog(
        context: context,
        builder: (BuildContext context) {

          return AlertDialog(
            backgroundColor: Colors.white,
            // <-- SEE HERE
            title: Column(
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Machine Learning',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 30,
                              color: Colors.black,
                              weight: 500,
                            ))
                      ],
                    ),
                  ),
                )
              ],
            ),

            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.all(16.0),
                      child: imagemData.isNotEmpty
                          ? Image.memory(imagemData)
                          : const Text("Imagem não disponível")),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.orange),
      columns: const <DataColumn>[
        DataColumn(
            label: Text(
          "Piquetes",
          textAlign: TextAlign.center,
        )),
        DataColumn(
            label: Text(
          "Bois",
          textAlign: TextAlign.center,
        )),
        DataColumn(
            label: Text(
          "Bois em pé",
          textAlign: TextAlign.center,
        )),
        DataColumn(
            label: Text(
          "Bois deitados",
          textAlign: TextAlign.center,
        )),
        DataColumn(
            label: Text(
          "Bois comendo",
          textAlign: TextAlign.center,
        )),
        DataColumn(
            label: Text(
          "Bois bebendo",
          textAlign: TextAlign.center,
        )),
        DataColumn(
            label: Text(
          "Data voo",
          textAlign: TextAlign.center,
        )),
        DataColumn(
            label: Text(
          "Ação",
          textAlign: TextAlign.center,
        )),
      ],
      rows: widget.dadosTabela
          .map((dado) => DataRow(
                  color:
                      MaterialStateColor.resolveWith((states) => Colors.white),
                  cells: <DataCell>[
                    DataCell(Text(dado.nomePiquete)),
                    DataCell(Container(
                        alignment: Alignment.center,
                        child: Text("${dado.qtdeBois}",
                            textAlign: TextAlign.center))),
                    DataCell(Container(
                        alignment: Alignment.center,
                        child: Text("${dado.qtdeBoisPe}",
                            textAlign: TextAlign.center))),
                    DataCell(Container(
                        alignment: Alignment.center,
                        child: Text("${dado.qtdeBoisDeitado}",
                            textAlign: TextAlign.center))),
                    DataCell(Container(
                        alignment: Alignment.center,
                        child: Text("${dado.qtdeBoisComendo}",
                            textAlign: TextAlign.center))),
                    DataCell(Container(
                        alignment: Alignment.center,
                        child: Text("${dado.qtdeBoisBebendo}",
                            textAlign: TextAlign.center))),
                    DataCell(Container(
                        alignment: Alignment.center,
                        child: Text(
                          "${dado.dataUltimoVoo.formattedDateHour}",
                          textAlign: TextAlign.center,
                        ))),
                    DataCell(
                            IconButton(
                                style: ButtonStyle(
                                    iconSize: MaterialStateProperty.all(40)),
                                icon: const Icon(Icons.image, color: primaryColor),
                                onPressed: () {
                                  MostraImagem(dado.idUltimaContagem);
                                })
                          )
                  ]))
          .toList(),
    );
  }
}
