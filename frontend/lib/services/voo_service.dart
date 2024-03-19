import 'dart:convert';

import 'package:cownter/dtos/voo_dto.dart';
import 'package:http/http.dart';

class VooService {
  final String _url;

  const VooService(this._url);

  Future<VooDTO> cadastrarVoo(DateTime data) async {
    String body = jsonEncode({"data": data.toString()});

    Map<String, String> headers = {"Content-Type": "application/json"};

    var uri = Uri.parse("$_url/voos/");

    Response response = await post(uri, headers: headers, body: body);

    var json = await jsonDecode(response.body);

    var vooDTO = VooDTO(json["id"], DateTime.parse(json["data"]), []);

    return vooDTO;
  }

  Future<Map<String, dynamic>> cadastarContagemVoo(List<int> foto, String nomeFoto) async {
    Uri uri = Uri.parse("$_url/voos/contagens/");

    String fotoBase64 = base64.encode(foto);

    MultipartRequest request = MultipartRequest('POST', uri);

    request.files
        .add(MultipartFile.fromBytes("foto", foto, filename: nomeFoto));

    StreamedResponse response = await request.send();

    Map<String, dynamic> json =
        await jsonDecode(await response.stream.bytesToString());

    return json;
  }

  Future<Map<String, dynamic>> listarQtdeBoisVooFazenda(String fazendaId) async {
    final Uri uri = Uri.parse("$_url/fazendas/$fazendaId/voos/qtde_bois");

    Response response = await get(uri);

    Map<String, dynamic> json = await jsonDecode(response.body);

    return json;
  }

  Future<List<dynamic>> listarContagensVoo(String vooId) async {
    final Uri uri = Uri.parse("$_url/voos/$vooId/contagens");

    Response response = await get(uri);

    List<dynamic> json = await jsonDecode(response.body);

    return json;
  }
}
