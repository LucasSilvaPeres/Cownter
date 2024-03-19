
class TabelaPiqueteDTO {
  final String nomePiquete;
  final int qtdeBois;
  final int qtdeBoisPe;
  final int qtdeBoisDeitado;
  final int qtdeBoisBebendo;
  final int qtdeBoisComendo;
  final int qtdeVoosRealizados;
  final DateTime dataUltimoVoo;
  final String idUltimaContagem;

  TabelaPiqueteDTO(this.nomePiquete, this.qtdeBois, this.qtdeVoosRealizados, this.dataUltimoVoo, this.idUltimaContagem, this.qtdeBoisPe, this.qtdeBoisDeitado, this.qtdeBoisBebendo, this.qtdeBoisComendo);
}