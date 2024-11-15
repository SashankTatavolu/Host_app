// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'api_service.dart';
// import '../models/login_request.dart';
// import '../models/login_response.dart';

// class AuthService {
//   ApiService apiService = ApiService('http://127.0.0.1:5000/api/users');
//   final storage = const FlutterSecureStorage();

//   Future<void> setToken(String token) async {
//     await storage.write(key: 'access_token', value: token);
//   }

//   Future<String?> getToken() async {
//     return await storage.read(key: 'access_token');
//   }

//   Future<LoginResponse?> authenticateUser(LoginRequest loginRequest) async {
//     var responseJson = await apiService.request(
//       endpoint: 'login',
//       payload: loginRequest.toJson(),
//       method: 'POST',
//       requireAuth: false,
//     );

//     if (responseJson != null) {
//       var loginResponse = LoginResponse.fromJson(responseJson);
//       await setToken(loginResponse.accessToken); // Store the token securely
//       return loginResponse;
//     }
//     return null;
//   }
// }

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthService {
  ApiService apiService = ApiService('https://canvas.iiit.ac.in/lc/api/users');
  final storage = const FlutterSecureStorage();

  Future<void> setToken(String token) async {
    await storage.write(key: 'access_token', value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<void> setUsername(String username) async {
    await storage.write(key: 'username', value: username);
  }

  Future<String?> getUsername() async {
    return await storage.read(key: 'username');
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
      await setUsername(loginRequest.username); // Store the username securely
      return loginResponse;
    }
    return null;
  }

  Future<void> clearStorage() async {
    await storage.deleteAll();
  }
}
