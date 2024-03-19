// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_principal_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DashboardPrincipalController
    on _DashboardPrincipalControllerBase, Store {
  late final _$graficoTotalBoisDTOAtom = Atom(
      name: '_DashboardPrincipalControllerBase.graficoTotalBoisDTO',
      context: context);

  @override
  GraficoTotalBoisDTO get graficoTotalBoisDTO {
    _$graficoTotalBoisDTOAtom.reportRead();
    return super.graficoTotalBoisDTO;
  }

  @override
  set graficoTotalBoisDTO(GraficoTotalBoisDTO value) {
    _$graficoTotalBoisDTOAtom.reportWrite(value, super.graficoTotalBoisDTO, () {
      super.graficoTotalBoisDTO = value;
    });
  }

  late final _$atualizarDTOAsyncAction = AsyncAction(
      '_DashboardPrincipalControllerBase.atualizarDTO',
      context: context);

  @override
  Future<void> atualizarDTO(String fazendaId) {
    return _$atualizarDTOAsyncAction.run(() => super.atualizarDTO(fazendaId));
  }

  @override
  String toString() {
    return '''
graficoTotalBoisDTO: ${graficoTotalBoisDTO}
    ''';
  }
}
