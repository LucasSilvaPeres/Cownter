import 'dart:typed_data';

import 'package:cownter/services/imagens_service.dart';
import 'package:cownter/services/voo_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobx/mobx.dart';
part 'contagens_voo_modal_controller.g.dart';


class ContagemVooDTO {
  final String id;
  final DateTime data;
  final int qtdeBoisEmPe;
  final int qtdeBoisBebendo;
  final int qtdeBoisDeitado;
  final int qtdeBoisComendo;
  Uint8List? imagem;

  ContagemVooDTO(this.id, this.data, this.qtdeBoisEmPe, this.qtdeBoisBebendo, this.qtdeBoisDeitado, this.qtdeBoisComendo);

  Future<void> fetchImagem() async {
    var imagemService = ImagemService(dotenv.env["COWNTER_API_URL"] ?? "");

    await imagemService.fetchArquivoImagem(id).then((v) => {
      imagem = v
    });

  }
}


class ContagensVooModalController = _ContagensVooModalControlleerBase with _$ContagensVooModalController;

abstract class _ContagensVooModalControlleerBase with Store {
  @observable
  ObservableList<ContagemVooDTO> contagens = ObservableList<ContagemVooDTO>();

  Future<void> atualizarContagens(String vooId) async {
    contagens.clear();

    var vooService = VooService(dotenv.env["COWNTER_API_URL"] ?? "");

    var json = await vooService.listarContagensVoo(vooId);

    for (var data in json) {
      var contagemVooDTO = ContagemVooDTO(
          data["id"],
          DateTime.parse(data["data"]),
          data["qtde_bois_em_pe"],
          data["qtde_bois_bebendo"],
          data["qtde_bois_deitado"],
          data["qtde_bois_comendo"],
        );

        contagemVooDTO.fetchImagem();

      contagens.add(contagemVooDTO);
    }
  }
}