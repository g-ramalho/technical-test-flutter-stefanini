import 'package:http/http.dart' as http;

class PontoCertificadoApi {
  final String url;

  PontoCertificadoApi(this.url);

  Future<http.Response> fetchSystemTime() async {
    final Uri uri = Uri.parse(url);

    return await http.post(uri, body: {});
  }
}