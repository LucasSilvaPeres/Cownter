import 'dart:typed_data';

import 'package:cownter/controllers/form_fotos_controller.dart';
import 'package:cownter/dtos/voo_dto.dart';
import 'package:cownter/utils/extensions.dart';
import 'package:darq/darq.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'package:image_picker/image_picker.dart';

class EnvioFotosScreen extends StatefulWidget {
  final coresEstadoFoto = {
    "Para upload": Colors.black,
    "Enviando": Colors.yellow,
    "Concluida": Colors.green,
    "Com problema": Colors.red
  };

  EnvioFotosScreen({super.key});

  @override
  State<EnvioFotosScreen> createState() => _EnvioFotosScreenState();
}

class _EnvioFotosScreenState extends State<EnvioFotosScreen> {
  FormFotosController controller = GetIt.I.get<FormFotosController>();

  final _dataVooController = TextEditingController();

  final picker = ImagePicker();

  List<FotoDTO> fotos = [];

  DateTime dataVoo = DateTime.now();

  @override
  void initState() {
    _dataVooController.text = dataVoo.formattedDate;
  }

  listarImagensParaUpload() async {
    setState(() {
      fotos = [];
    });

    final fotosGaleria = await picker.pickMultiImage();

    for (var fotoGaleria in fotosGaleria) {
      try {
        fotoGaleria.readAsBytes().then((bytes) async {
          final exifData = await readExifFromBytes(bytes);

          if (exifData.isNotEmpty) {
            if (exifData.containsKey("JPEGThumbnail")) {
              exifData.remove("JPEGThumbnail");
            }
          } else {
            throw Exception();
          }
          FotoDTO foto = FotoDTO(fotoGaleria.name, "Para upload", bytes);

          setState(() {
            fotos.add(foto);
          });
        });
      } catch (ex) {
        FotoDTO foto = FotoDTO(fotoGaleria.name, "", [],
            problema: "Não foi possível ler os bytes da imagem");

        setState(() {
          fotos.add(foto);
        });
      }
    }
  }

  Future<void> enviarFotos() async {
    Future.forEach(fotos, (FotoDTO foto) async {
      setState(() {
        foto.alterarEstado("Enviando");
      });

      await controller.enviarFoto(foto).then(
        (value) {
          if (value.containsKey("error")) {
            setState(() {
              foto.alterarEstado("Com problema");

              foto.alterarProblema(value["error"]);
            });
          } else {
            setState(() {
              foto.alterarEstado("Concluida");
            });
          }
        },
      ).onError((error, stackTrace) {
        setState(() {
          foto.alterarEstado("Com problema");
        });
      });
    });
  }

  Future<void> cadastrarVoo(BuildContext context) async {
    VooDTO voo;
    try {
      // voo = await controller.cadastrarVoo(dataVoo);

      await enviarFotos();
    } on Error {
      await showDialog(
          context: context,
          useSafeArea: true,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: const Text(
                  "Um voo com esta data já está cadastrado na base",
                  style: TextStyle(
                      color: Colors.black, decoration: TextDecoration.none),
                ));
          });
    }
  }

  Future<void> selecionarData() async {
    final DateTime data = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1990, 1, 1),
          lastDate: DateTime.now(),
        ) ??
        DateTime.now();

    setState(() {
      dataVoo = data;
    });

    _dataVooController.text = dataVoo.formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text.rich(
            TextSpan(
              text: 'Cadastro de voos',
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    gradient: LinearGradient(colors: [
                      Color.fromARGB(227, 255, 255, 255),
                      Color.fromARGB(188, 41, 112, 1),
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              ),
            )
          ],
        ),
        body: Observer(builder: (_) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Form(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Selecione as imagens para envio", style: TextStyle(fontSize: 18),),
                          Center(
                            child: IconButton(
                              iconSize: 100,
                                icon:
                                    const Icon(Icons.add_photo_alternate_rounded),
                                onPressed: listarImagensParaUpload),
                          )
                        ],
                      ),
                    ),
                    if (fotos.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 400,
                        child: GridView.builder(
                            itemCount: fotos.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 12,
                                    crossAxisSpacing: 10.0,
                                    mainAxisSpacing: 10.0),
                            itemBuilder: (BuildContext context, int index) {
                              return Column(children: [
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                      color: widget.coresEstadoFoto[
                                              fotos[index].estado] ??
                                          Colors.black,
                                      width: 5.0,
                                    )),
                                    child: Image.memory(
                                        fotos[index].bytes as Uint8List,
                                        scale: 0.25,
                                        fit: BoxFit.cover)),
                                Text(fotos[index].nomeUpload),
                              ]);
                            }),
                      ),
                    if (fotos.isNotEmpty &&
                        fotos.all((e) => e.estado == "Para upload"))
                      TextButton(
                          child: const Text("Confirmar"),
                          onPressed: () async {
                            await cadastrarVoo(context);
                          }),
                  ],
                ),
              ),
            ),
          );
        }));
  }
}
