import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';

class ImagemService {
  final String _url;

  ImagemService(this._url);

  Future<Uint8List> fetchArquivoImagem(String idContagem) async {
    Uri uri = Uri.parse("$_url/contagens/$idContagem/imagem/");

    Response response = await get(uri);

    return response.bodyBytes;
  }

  Future<Map<String, dynamic>> enviarFoto(
      List<int> foto, String nomeFoto) async {
    Uri uri = Uri.parse("$_url/voos/");

    String fotoBase64 = base64.encode(foto);

    MultipartRequest request = MultipartRequest('POST', uri);

    request.files
        .add(MultipartFile.fromBytes("foto", foto, filename: nomeFoto));

    StreamedResponse response = await request.send();

    Map<String, dynamic> json =
        await jsonDecode(await response.stream.bytesToString());

    return json;
  }
}
