import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthService {
  ApiService apiService = ApiService('http://127.0.0.1:5000/api/users');
  final storage = FlutterSecureStorage();

  Future<void> setToken(String token) async {
    await storage.write(key: 'access_token', value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<LoginResponse?> authenticateUser(LoginRequest loginRequest) async {
    var responseJson = await apiService.request(
      endpoint: 'login',
      payload: loginRequest.toJson(),
      method: 'POST',
      requireAuth: false,
    );

    if (responseJson != null) {
      var loginResponse = LoginResponse.fromJson(responseJson);
      await setToken(loginResponse.accessToken); // Store the token securely
      return loginResponse;
    }
    return null;
  }
}

