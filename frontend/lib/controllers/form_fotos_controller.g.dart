// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_fotos_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FormFotosController on _FormFotosControllerBase, Store {
  late final _$cadastrarVooAsyncAction =
      AsyncAction('_FormFotosControllerBase.cadastrarVoo', context: context);

  @override
  Future<VooDTO> cadastrarVoo(DateTime dataVoo) {
    return _$cadastrarVooAsyncAction.run(() => super.cadastrarVoo(dataVoo));
  }

  late final _$_FormFotosControllerBaseActionController =
      ActionController(name: '_FormFotosControllerBase', context: context);

  @override
  Future<Map<String, dynamic>> enviarFoto(FotoDTO foto) {
    final _$actionInfo = _$_FormFotosControllerBaseActionController.startAction(
        name: '_FormFotosControllerBase.enviarFoto');
    try {
      return super.enviarFoto(foto);
    } finally {
      _$_FormFotosControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
