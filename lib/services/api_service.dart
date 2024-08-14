import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;
  String? _bearerToken;

  ApiService(this.baseUrl);

  void setBearerToken(String token) {
    _bearerToken = token;
  }

  Future<dynamic> request({
    required String endpoint,
    required Map<String, dynamic> payload,
    required String method,
    bool requireAuth = false,
  }) async {
    var url = Uri.parse('$baseUrl/$endpoint');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (requireAuth && _bearerToken != null) {
      headers['Authorization'] = 'Bearer $_bearerToken';
    }

    http.Response response;
    if (method == 'POST') {
      response =
          await http.post(url, body: json.encode(payload), headers: headers);
    } else if (method == 'GET') {
      response = await http.get(url, headers: headers);
    } else {
      throw Exception('HTTP method not supported');
    }

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
    }
    return null;
  }
}
