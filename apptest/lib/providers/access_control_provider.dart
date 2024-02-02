import 'package:shared_preferences/shared_preferences.dart';

class AccessControlProvider {
  String path = 'stock-server-theta.vercel.app';

  Future<String> get token async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    return token;
  }
}
