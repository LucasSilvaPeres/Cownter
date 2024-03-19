import 'package:cownter/dtos/contagem_dto.dart';

class VooDTO {
  final String id;
  final DateTime data;
  final List<ContagemDTO> contagens;

  VooDTO(this.id, this.data, this.contagens);
}