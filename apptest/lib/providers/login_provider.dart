import 'dart:convert';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'request_control_provider.dart';
import 'access_control_provider.dart';

class LoginProvider {
  String email;
  String password;

  LoginProvider(this.email, this.password);

  static Future<RequestControlProvider> login({required String email, required String password}) async {
    bool requestSuccess = true;
    bool connectionFailed = false;
    String? errorMsg;
    String? responseToken;
    final accessControl = AccessControlProvider();

    final url = Uri.https(
      accessControl.path,
      '/api/login',
    );

    if (kDebugMode) print('Requesting: $url');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (kDebugMode) print('Response status: ${response.statusCode}');
      if (kDebugMode) print('Response body: ${response.body}');

      final responseData = json.decode(response.body);
      if (kDebugMode) print('Error messgage: ${responseData['error']}');
      if (kDebugMode) print('Token: ${responseData['session-token']}');

      if (response.statusCode == 200) {
        requestSuccess = true;
        if (responseData['session-token'] != null) {
          responseToken = responseData['session-token'];
          if (responseToken != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', responseToken);
          }
        }
      } else {
        requestSuccess = false;
        if (responseData['error'] != null) {
          errorMsg = responseData['error'];
        }
      }
    } catch (e) {
      requestSuccess = false;
      connectionFailed = true;
      errorMsg = e.toString();
    }

    return RequestControlProvider(
      requestSuccess: requestSuccess,
      connectionFailed: connectionFailed,
      errorMsg: errorMsg,
      response: responseToken,
    );
  }
}
