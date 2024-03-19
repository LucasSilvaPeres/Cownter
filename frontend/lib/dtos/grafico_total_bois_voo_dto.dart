class GraficoTotalBoisVooDTO {
  final String id;
  final DateTime data;
  final int qtdeBoisBebendo;
  final int qtdeBoisComendo;
  final int qtdeBoisDeitado;
  final int qtdeBoisEmPe;

  const GraficoTotalBoisVooDTO(this.id, this.data, this.qtdeBoisBebendo, this.qtdeBoisComendo, this.qtdeBoisDeitado, this.qtdeBoisEmPe);
}

class GraficoTotalBoisDTO {
  final List<GraficoTotalBoisVooDTO> voos;

  const GraficoTotalBoisDTO(this.voos);
}
