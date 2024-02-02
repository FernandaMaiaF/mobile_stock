import 'package:apptest/screens/portfolio_screen.dart';
import 'package:flutter/material.dart';

import '../providers/login_provider.dart';
import '../providers/request_control_provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    RequestControlProvider requestResponse = await LoginProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (requestResponse.requestSuccess == true && requestResponse.response != null) {
      if (context.mounted) {
        requestResponse.showSucessDialog(context, "Login success").then((value) => Navigator.of(context).pushNamed(PortfolioScreen.routeName));
      }
    } else if (context.mounted) {
      if (requestResponse.errorMsg != null) {
        requestResponse.showErrorDialog(context, requestResponse.errorMsg);
      } else {
        requestResponse.showErrorDialog(context, "Login failed");
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Login',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              autocorrect: false,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Login is required';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
              autocorrect: false,
              controller: _passwordController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _login();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    ));
  }
}
