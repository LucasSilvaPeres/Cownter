import 'dart:typed_data';

import 'package:cownter/dtos/bois_comendo_bebendo_dto.dart';
import 'package:cownter/dtos/bois_pe_deitado_dto.dart';
import 'package:cownter/dtos/relatorio_geral_dto.dart';
import 'package:cownter/dtos/tabela_piquete_dto.dart';
import 'package:cownter/dtos/tempo_confinamento_dto.dart';
import 'package:cownter/services/dashboard_service.dart';
import 'package:cownter/services/imagens_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobx/mobx.dart';
import 'package:darq/darq.dart';

part 'dashboard_controller.g.dart';

class DashboardController = _DashboardController with _$DashboardController;

abstract class _DashboardController with Store {
  @observable
  bool loading = true;

  @observable
  DashboardDTO dados = DashboardDTO("", "", []);

  @observable
  DashboardPiqueteDTO dadosFiltrados = DashboardPiqueteDTO('', '', []);

  @observable
  DateTime data = DateTime.now();

  @observable
  RelatorioGeralDTO dadosRelatorioGeral = RelatorioGeralDTO(0, 0, 0, 0, 0);

  @observable
  late List<BoisTempoConfinamentoDTO> dadosBoisTempoConfinamento;

  @observable
  BoisPeDeitadoDTO dadosBoisPeDeitado = BoisPeDeitadoDTO(0, 0, 0);

  @observable
  BoisComendoBebendoDTO dadosBoisComendoBebendo =
      BoisComendoBebendoDTO(0, 0, 0, 0);

  @observable
  List<TabelaPiqueteDTO> dadosTabelaPiquete = [];

  List<DashboardContagemDTO> contagensData = [];

  DateTime getDataUltimaContagem() {
    DateTime data_ = DateTime.now();

    if (dados.piquetes.isNotEmpty) {
      for (var piquete in dados.piquetes) {
        if (piquete.voos.isNotEmpty) {
          for (var voo in piquete.voos) {
            List<DateTime> datasVoos = voo.contagens.map((e) => e.data).toList();

            if (datasVoos.isNotEmpty) {
              DateTime ultimaDataVoo = datasVoos.max(
                (a, b) => a.compareTo(b)
              );

              data_ = ultimaDataVoo;
            }
          }
        }
      }
    }

    return data_;
  }

  Future<Uint8List> requisitarImagemContagem(String idContagem) async {
    String url = dotenv.env["COWNTER_API_URL"] ?? "";

    ImagemService imagemService = ImagemService(url);

    return await imagemService.fetchArquivoImagem(idContagem);
  }

  Future<void> requisitarDados(DateTime? dataVoo) async {

    loading = true;

    String url = dotenv.env['COWNTER_API_URL'] ?? "";
    
    DashboardService service = DashboardService(url);

    dados =
        await service.fetchDadosFazenda("4efcc9ee-396f-469c-b570-6e0cbd6aa575");

    if (dataVoo != null) {
      setData(dataVoo);
    } else {
      DateTime dataUltimaContagem = getDataUltimaContagem();

      setData(dataUltimaContagem);
    }


    atualizarDadosRelatorioGeral();
    atualizarDadosBoisPeDeitado();
    atualizarDadosBoisComendoBebendo();
    atualizarDadosTabelaPiquete('');

    loading = false;
  }

  void limpadadosFiltradosMapa() {
    dadosFiltrados = DashboardPiqueteDTO('', '', []);
  }

  void setData(DateTime novaData) {
    data = novaData;
  }

  void dadosFiltradosMapa(String idPiquete) {
    DateTime data_ = DateTime.now();

    dadosFiltrados =
        dados.piquetes.where((element) => element.idPiquete == idPiquete).first;
    //dados.piquetes.first.voos.first.contagens.first

    data_ = dadosFiltrados.voos.first.data;
    setData(data_);
    var voos = [...dadosFiltrados.voos];

    for (var element in voos) {
      var dataatual = element.data.year == data_.year &&
          element.data.month == data_.month &&
          element.data.day == data_.day;

      if (!dataatual) {
        dadosFiltrados.voos.remove(element);
      }
    }

    atualizarDadosRelatorioGeral();
    atualizarDadosBoisPeDeitado();
    //atualizarDadosBoisComendoBebendo();
    atualizarDadosTabelaPiquete(idPiquete);

    loading = false;
  }

  List<DashboardContagemDTO> getContagensData() {
    List<DashboardContagemDTO> contagensData = [];

    var dadosparamostrar = [...dadosFiltrados.voos];

    if (dadosparamostrar.isEmpty) {
      for (var piquete in dados.piquetes) {
        for (var voo in piquete.voos) {
          for (var contagem in voo.contagens) {
            bool isDiaAtual = contagem.data.day == data.day &&
                contagem.data.month == data.month &&
                contagem.data.year == data.year;

            if (isDiaAtual) {
              contagensData.add(contagem);
            }
          }
        }
      }
    } else {
      for (var voo in dadosparamostrar) {
        for (var contagem in voo.contagens) {
          bool isDiaAtual = contagem.data.day == data.day &&
              contagem.data.month == data.month &&
              contagem.data.year == data.year;

          if (isDiaAtual) {
            contagensData.add(contagem);
          }
        }
      }
    }

    return contagensData;
  }

  // List<DashboardPiqueteDTO> getPiquetesData(String? idPiquete) {
  //   List<DashboardPiqueteDTO> piquetesDTO = [];

  //   var dadosparamostrar = [...dadosFiltrados.voos];

  //   if (dadosparamostrar.isEmpty) {
  //     for (var piquete in dados.piquetes) {
  //       for (var voo in piquete.voos) {
  //         for (var contagem in voo.contagens) {
  //           bool isDiaAtual = contagem.data.day == data.day &&
  //               contagem.data.month == data.month &&
  //               contagem.data.year == data.year;

  //           if (isDiaAtual) {
  //             piquetesDTO.add(piquete);
  //             break;
  //           }
  //         }
  //       }
  //     }
  //   } else {
  //     for (var voo in dadosparamostrar) {
  //       for (var contagem in voo.contagens) {
  //         bool isDiaAtual = contagem.data.day == data.day &&
  //             contagem.data.month == data.month &&
  //             contagem.data.year == data.year;

  //         for (var piquete in dados.piquetes
  //             .where((element) => element.idPiquete == idPiquete)) {
  //           if (isDiaAtual) {
  //             piquetesDTO.add(piquete);
  //             break;
  //           }
  //         }
  //       }
  //     }
  //   }

  //   return piquetesDTO;
  // }

  void atualizarDadosRelatorioGeral() {
    contagensData = getContagensData();
    double mediaQtdeBoisBebendo = 0;
    double mediaQtdeBoisComendo = 0;
    double mediaQtdeBoisPe = 0;
    double mediaQtdeBoisDeitado = 0;
    double mediaQtdeTotalBois = 0;

    if (contagensData.isNotEmpty) {
      for (var element in contagensData) {
        mediaQtdeBoisBebendo += element.qtdeBoisBebendo;
        mediaQtdeBoisComendo += element.qtdeBoisComendo;
        mediaQtdeBoisPe += element.qtdeBoisPe;
        mediaQtdeBoisDeitado += element.qtdeBoisDeitado;
      }

      mediaQtdeTotalBois = mediaQtdeBoisBebendo +
          mediaQtdeBoisComendo +
          mediaQtdeBoisPe +
          mediaQtdeBoisDeitado;
    }

    dadosRelatorioGeral = RelatorioGeralDTO(
        mediaQtdeBoisComendo.toInt(),
        mediaQtdeBoisBebendo.toInt(),
        mediaQtdeBoisDeitado.toInt(),
        mediaQtdeBoisPe.toInt(),
        mediaQtdeTotalBois.toInt());
  }

  void atualizarDadosBoisPeDeitado() {
    double mediaQtdeBoisPe = 0;
    double mediaQtdeBoisDeitado = 0;
    double mediaQtdeTotalBois = 0;

    if (contagensData.isNotEmpty) {
      for (var element in contagensData) {
        mediaQtdeBoisPe += element.qtdeBoisPe;
        mediaQtdeBoisDeitado += element.qtdeBoisDeitado;
      }
      mediaQtdeTotalBois = mediaQtdeBoisPe + mediaQtdeBoisDeitado;
    }

    dadosBoisPeDeitado = BoisPeDeitadoDTO(mediaQtdeBoisPe.toInt(),
        mediaQtdeBoisDeitado.toInt(), mediaQtdeTotalBois.toInt());
  }

  void atualizarDadosBoisComendoBebendo() {
    double mediaQtdeBoisBebendo = 0;
    double mediaQtdeBoisComendo = 0;
    double mediaQtdeBoisPe = 0;
    double mediaQtdeBoisDeitado = 0;
    double mediaQtdeTotalBois = 0;
    double mediaQtdeBoisOutros = 0;

    if (contagensData.isNotEmpty) {
      for (var element in contagensData) {
        mediaQtdeBoisBebendo += element.qtdeBoisBebendo;
        mediaQtdeBoisComendo += element.qtdeBoisComendo;
        mediaQtdeBoisPe += element.qtdeBoisPe;
        mediaQtdeBoisDeitado += element.qtdeBoisDeitado;
      }

      mediaQtdeTotalBois = mediaQtdeBoisBebendo +
          mediaQtdeBoisComendo +
          mediaQtdeBoisPe +
          mediaQtdeBoisDeitado;
      mediaQtdeBoisOutros = mediaQtdeBoisPe + mediaQtdeBoisDeitado;
    }

    dadosBoisComendoBebendo = BoisComendoBebendoDTO(
        mediaQtdeBoisComendo.toInt(),
        mediaQtdeBoisBebendo.toInt(),
        mediaQtdeTotalBois.toInt(),
        mediaQtdeBoisOutros.toInt());
  }

  void atualizarDadosTabelaPiquete(String? idPiquete) async {
    List<TabelaPiqueteDTO> novosDadosTabelaPiquete = [];

    if (dados.piquetes.isNotEmpty) {
      for (var piquete in dados.piquetes) {
        if (piquete.voos.isNotEmpty) {
          for (var voo in piquete.voos) {
            if (voo.contagens.isNotEmpty) {
              for (var contagem in voo.contagens) {
                bool isDiaAtual = contagem.data.day == data.day && contagem.data.month == data.month && contagem.data.year == data.year;

                if (isDiaAtual){
                  final qtdeBois = contagem.qtdeBoisBebendo + contagem.qtdeBoisComendo + contagem.qtdeBoisDeitado + contagem.qtdeBoisPe;

                  TabelaPiqueteDTO tabelaPiqueteDTO = TabelaPiqueteDTO(
                    piquete.nomePiquete,
                    qtdeBois,
                    1,
                    contagem.data,
                    contagem.idContagem,
                    contagem.qtdeBoisPe,
                    contagem.qtdeBoisDeitado,
                    contagem.qtdeBoisBebendo,
                    contagem.qtdeBoisComendo
                  );
                  novosDadosTabelaPiquete.add(tabelaPiqueteDTO);
                }
              }
            }
          }
        }
      } 
    }

    // List<DashboardPiqueteDTO> piquetesData = getPiquetesData(idPiquete);
  
    // for (var piquete in ) {
    //   int qtdeBoisPe = 0;
    //   int qtdeBoisDeitado = 0;
    //   int qtdeBoisComendo = 0;
    //   int qtdeBoisBebendo = 0;
    //   int qtdeBois = 0;
    //   String idUltimaContagem = "";

    //   if (piquete.voos.isNotEmpty) {
    //     for (var voo in piquete.voos) {
    //       if (voo.contagens.isNotEmpty) {
    //         for(var contagem in voo.contagens) {
    //           print(contagem.data);
    //           print(contagem.idContagem);
    //           print(contagem.qtdeBoisBebendo);
    //           print(contagem.qtdeBoisComendo);
    //           print(contagem.qtdeBoisDeitado);
    //           print(contagem.qtdeBoisPe);
    //         }
    //   //       qtdeBoisPe = piquete.voos.average(
    //   //         (voo) => voo.contagens.average((contagem) => contagem.qtdeBoisPe));
    //   //       qtdeBoisDeitado = piquete.voos.average((voo) =>
    //   //           voo.contagens.average((contagem) => contagem.qtdeBoisDeitado));
    //   //       qtdeBoisComendo = piquete.voos.average((voo) =>
    //   //           voo.contagens.average((contagem) => contagem.qtdeBoisComendo));
    //   //       qtdeBoisBebendo = piquete.voos.average((voo) =>
    //   //           voo.contagens.average((contagem) => contagem.qtdeBoisBebendo));
    //   //       qtdeBois = piquete.voos.average((voo) => voo.contagens.average(
    //   //         (contagem) =>
    //   //           contagem.qtdeBoisBebendo +
    //   //           contagem.qtdeBoisComendo +
    //   //           contagem.qtdeBoisDeitado +
    //   //           contagem.qtdeBoisPe));
    //   //       idUltimaContagem = piquete.voos.last.contagens.last.idContagem;
    //       }
        // }
      // }

    //   var tabelaPiqueteDTO = TabelaPiqueteDTO(
    //       piquete.nomePiquete,
    //       qtdeBois,
    //       piquete.voos.length,
    //       data,
    //       idUltimaContagem,
    //       qtdeBoisPe,
    //       qtdeBoisDeitado,
    //       qtdeBoisComendo,
    //       qtdeBoisBebendo);

    //   novosDadosTabelaPiquete.add(tabelaPiqueteDTO);
    // }

    dadosTabelaPiquete = novosDadosTabelaPiquete;
  }
}
