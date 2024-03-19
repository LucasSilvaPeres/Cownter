import 'package:cownter/dtos/grafico_total_bois_voo_dto.dart';
import 'package:cownter/services/voo_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobx/mobx.dart';
part 'dashboard_principal_controller.g.dart';

class DashboardPrincipalController = _DashboardPrincipalControllerBase with _$DashboardPrincipalController;

abstract class _DashboardPrincipalControllerBase with Store {
  @observable
  GraficoTotalBoisDTO graficoTotalBoisDTO = const GraficoTotalBoisDTO([]);

  @action
  Future<void> atualizarDTO(String fazendaId) async {
    final String url = dotenv.env["COWNTER_API_URL"] ?? "";

    final VooService vooService = VooService(url);

    final voosJson = await vooService.listarQtdeBoisVooFazenda(fazendaId);

    final List<GraficoTotalBoisVooDTO> voosDTO = [];

    for (var dataVoo in voosJson.keys) {
      final DateTime data = DateTime.parse(dataVoo);
      final String id = voosJson[dataVoo]["id"];
      final int qtdeBoisBebendo = voosJson[dataVoo]["qtde_bois_bebendo"];
      final int qtdeBoisComendo = voosJson[dataVoo]["qtde_bois_comendo"];
      final int qtdeBoisDeitado = voosJson[dataVoo]["qtde_bois_deitado"];
      final int qtdeBoisEmPe = voosJson[dataVoo]["qtde_bois_em_pe"];

      voosDTO.add(GraficoTotalBoisVooDTO(id, data, qtdeBoisBebendo, qtdeBoisComendo, qtdeBoisDeitado, qtdeBoisEmPe));
    }

    graficoTotalBoisDTO = GraficoTotalBoisDTO(voosDTO);
  }
}