import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/portfolio_screen.dart';

import 'access_control_provider.dart';

class InitScreen extends StatefulWidget {
  static const routeName = '/init';

  const InitScreen({Key? key}) : super(key: key);

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) _loadRequiredData();
    super.didChangeDependencies();
  }

  Future<void> _loadRequiredData() async {
    final accessControl = AccessControlProvider();
    String token = await accessControl.token;

    setState(() {
      _isInit = false;
    });
    if (token.isNotEmpty) {
      if (kDebugMode) print('token: $token');

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(PortfolioScreen.routeName, (Route<dynamic> route) => false);
    } else {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColorLight,
        body: const Center(
          child: Icon(Icons.replay_circle_filled_outlined),
        ));
  }
}
