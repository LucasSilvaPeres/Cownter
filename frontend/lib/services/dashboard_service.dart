import "dart:convert";

import "package:http/http.dart" as http;

class DashboardContagemDTO {
  final String idContagem;
  final int qtdeBoisDeitado;
  final int qtdeBoisPe;
  final int qtdeBoisComendo;
  final int qtdeBoisBebendo;
  final DateTime data;

  DashboardContagemDTO(this.idContagem, this.qtdeBoisDeitado, this.qtdeBoisPe,
      this.qtdeBoisComendo, this.qtdeBoisBebendo, this.data);
}

class DashboardVooDTO {
  final String idVoo;
  final DateTime data;
  final List<DashboardContagemDTO> contagens;

  DashboardVooDTO(this.idVoo, this.data, this.contagens);
}

class DashboardPiqueteDTO {
  final String idPiquete;
  final String nomePiquete;
  final List<DashboardVooDTO> voos;

  DashboardPiqueteDTO(this.idPiquete, this.nomePiquete, this.voos);
}

class DashboardDTO {
  final String idFazenda;
  final String nomeFazenda;
  final List<DashboardPiqueteDTO> piquetes;

  DashboardDTO(this.idFazenda, this.nomeFazenda, this.piquetes);
}

class DashboardService {
  final String _url;

  DashboardService(this._url);

  Future<List<DashboardContagemDTO>> instanciarContagens(
      List<dynamic> json) async {
    List<DashboardContagemDTO> contagens = [];

    for (var contagemJson in json) {
      DashboardContagemDTO contagem = DashboardContagemDTO(
          contagemJson["id"],
          contagemJson["qtde_bois_deitado"],
          contagemJson["qtde_bois_em_pe"],
          contagemJson["qtde_bois_comendo"],
          contagemJson["qtde_bois_bebendo"],
          DateTime.parse(contagemJson["data"]));

      contagens.add(contagem);
    }

    return contagens;
  }

  Future<List<DashboardVooDTO>> instanciarVoos(List<dynamic> json) async {
    List<DashboardVooDTO> voos = [];

    for (var vooJson in json) {
      List<DashboardContagemDTO> contagens =
          await instanciarContagens(vooJson["contagens"]);

      DashboardVooDTO voo = DashboardVooDTO(
          vooJson["id"], DateTime.parse(vooJson["data"]), contagens);

      voos.add(voo);
    }

    return voos;
  }

  Future<List<DashboardPiqueteDTO>> instanciarPiquetes(
      List<dynamic> json) async {
    List<DashboardPiqueteDTO> piquetes = [];

    for (var piqueteJson in json) {
      List<DashboardVooDTO> voos = await instanciarVoos(piqueteJson["voos"]);

      DashboardPiqueteDTO piquete =
          DashboardPiqueteDTO(piqueteJson["id"], piqueteJson["nome"], voos);

      piquetes.add(piquete);
    }

    return piquetes;
  }

  Future<DashboardDTO> instanciarDashboard(Map<String, dynamic> json) async {
    var piquetes = await instanciarPiquetes(json["piquetes"]);

    return DashboardDTO(json["id"], json["nome"], piquetes);
  }

  Future<DashboardDTO> fetchDadosFazenda(String fazendaId) async {
    Uri uri = Uri.parse("$_url/fazendas/$fazendaId/");

    var response = await http.get(uri);

    Map<String, dynamic> json = await jsonDecode(response.body);

    DashboardDTO dto = await instanciarDashboard(json);

    return dto;
  }
}
