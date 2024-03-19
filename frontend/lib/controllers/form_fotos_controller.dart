import 'package:cownter/dtos/voo_dto.dart';
import 'package:cownter/services/voo_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobx/mobx.dart';
part 'form_fotos_controller.g.dart';

class FormFotosController = _FormFotosControllerBase with _$FormFotosController;


class FotoDTO {
  final String nomeUpload;
  String estado;
  final List<int> bytes;
  String problema;

  FotoDTO(this.nomeUpload, this.estado, this.bytes, {this.problema = ""});

  void alterarEstado(String novoEstado) {
    estado = novoEstado;
  }

  void alterarProblema(String novoProblema) {
    problema = novoProblema;
  }
}

abstract class _FormFotosControllerBase with Store {
  VooService vooService = VooService(dotenv.get("COWNTER_API_URL"));

  @action
  Future<Map<String, dynamic>> enviarFoto(FotoDTO foto) {
    return vooService.cadastarContagemVoo(foto.bytes, foto.nomeUpload);
  }

  @action
  Future<VooDTO> cadastrarVoo(DateTime dataVoo) async {
    return vooService.cadastrarVoo(dataVoo);
  }
}