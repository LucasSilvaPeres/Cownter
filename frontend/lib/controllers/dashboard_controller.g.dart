// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DashboardController on _DashboardController, Store {
  late final _$loadingAtom =
      Atom(name: '_DashboardController.loading', context: context);

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$dadosAtom =
      Atom(name: '_DashboardController.dados', context: context);

  @override
  DashboardDTO get dados {
    _$dadosAtom.reportRead();
    return super.dados;
  }

  @override
  set dados(DashboardDTO value) {
    _$dadosAtom.reportWrite(value, super.dados, () {
      super.dados = value;
    });
  }

  late final _$dadosFiltradosAtom =
      Atom(name: '_DashboardController.dadosFiltrados', context: context);

  @override
  DashboardPiqueteDTO get dadosFiltrados {
    _$dadosFiltradosAtom.reportRead();
    return super.dadosFiltrados;
  }

  @override
  set dadosFiltrados(DashboardPiqueteDTO value) {
    _$dadosFiltradosAtom.reportWrite(value, super.dadosFiltrados, () {
      super.dadosFiltrados = value;
    });
  }

  late final _$dataAtom =
      Atom(name: '_DashboardController.data', context: context);

  @override
  DateTime get data {
    _$dataAtom.reportRead();
    return super.data;
  }

  @override
  set data(DateTime value) {
    _$dataAtom.reportWrite(value, super.data, () {
      super.data = value;
    });
  }

  late final _$dadosRelatorioGeralAtom =
      Atom(name: '_DashboardController.dadosRelatorioGeral', context: context);

  @override
  RelatorioGeralDTO get dadosRelatorioGeral {
    _$dadosRelatorioGeralAtom.reportRead();
    return super.dadosRelatorioGeral;
  }

  @override
  set dadosRelatorioGeral(RelatorioGeralDTO value) {
    _$dadosRelatorioGeralAtom.reportWrite(value, super.dadosRelatorioGeral, () {
      super.dadosRelatorioGeral = value;
    });
  }

  late final _$dadosBoisTempoConfinamentoAtom = Atom(
      name: '_DashboardController.dadosBoisTempoConfinamento',
      context: context);

  @override
  List<BoisTempoConfinamentoDTO> get dadosBoisTempoConfinamento {
    _$dadosBoisTempoConfinamentoAtom.reportRead();
    return super.dadosBoisTempoConfinamento;
  }

  @override
  set dadosBoisTempoConfinamento(List<BoisTempoConfinamentoDTO> value) {
    _$dadosBoisTempoConfinamentoAtom
        .reportWrite(value, super.dadosBoisTempoConfinamento, () {
      super.dadosBoisTempoConfinamento = value;
    });
  }

  late final _$dadosBoisPeDeitadoAtom =
      Atom(name: '_DashboardController.dadosBoisPeDeitado', context: context);

  @override
  BoisPeDeitadoDTO get dadosBoisPeDeitado {
    _$dadosBoisPeDeitadoAtom.reportRead();
    return super.dadosBoisPeDeitado;
  }

  @override
  set dadosBoisPeDeitado(BoisPeDeitadoDTO value) {
    _$dadosBoisPeDeitadoAtom.reportWrite(value, super.dadosBoisPeDeitado, () {
      super.dadosBoisPeDeitado = value;
    });
  }

  late final _$dadosBoisComendoBebendoAtom = Atom(
      name: '_DashboardController.dadosBoisComendoBebendo', context: context);

  @override
  BoisComendoBebendoDTO get dadosBoisComendoBebendo {
    _$dadosBoisComendoBebendoAtom.reportRead();
    return super.dadosBoisComendoBebendo;
  }

  @override
  set dadosBoisComendoBebendo(BoisComendoBebendoDTO value) {
    _$dadosBoisComendoBebendoAtom
        .reportWrite(value, super.dadosBoisComendoBebendo, () {
      super.dadosBoisComendoBebendo = value;
    });
  }

  late final _$dadosTabelaPiqueteAtom =
      Atom(name: '_DashboardController.dadosTabelaPiquete', context: context);

  @override
  List<TabelaPiqueteDTO> get dadosTabelaPiquete {
    _$dadosTabelaPiqueteAtom.reportRead();
    return super.dadosTabelaPiquete;
  }

  @override
  set dadosTabelaPiquete(List<TabelaPiqueteDTO> value) {
    _$dadosTabelaPiqueteAtom.reportWrite(value, super.dadosTabelaPiquete, () {
      super.dadosTabelaPiquete = value;
    });
  }

  @override
  String toString() {
    return '''
loading: ${loading},
dados: ${dados},
dadosFiltrados: ${dadosFiltrados},
data: ${data},
dadosRelatorioGeral: ${dadosRelatorioGeral},
dadosBoisTempoConfinamento: ${dadosBoisTempoConfinamento},
dadosBoisPeDeitado: ${dadosBoisPeDeitado},
dadosBoisComendoBebendo: ${dadosBoisComendoBebendo},
dadosTabelaPiquete: ${dadosTabelaPiquete}
    ''';
  }
}
