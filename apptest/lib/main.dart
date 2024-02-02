import 'package:apptest/screens/login_screen.dart';
import 'package:apptest/screens/portfolio_screen.dart';
import 'package:apptest/screens/stock_position_screen.dart';
import 'package:flutter/material.dart';

import 'providers/init_screen.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const InitScreen(), // LoginScreen(),
      routes: {
        LoginScreen.routeName: (ctx) => const LoginScreen(),
        PortfolioScreen.routeName: (ctx) => const PortfolioScreen(),
        StockPositionScreen.routeName: (context) => const StockPositionScreen(),
      },
    );
  }
}
