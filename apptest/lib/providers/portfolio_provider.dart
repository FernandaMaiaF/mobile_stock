import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'request_control_provider.dart';
import 'access_control_provider.dart';
import 'stocks_provider.dart';

class PortfolioProvider {
  double? currentValue;
  double? initialInvestment;
  List<StocksProvider>? positions;

  PortfolioProvider({this.currentValue, this.initialInvestment, this.positions});

  factory PortfolioProvider.fromJson(Map<String, dynamic> json) {
    List<StocksProvider> positionsList = [];

    json['positions'].forEach((value) {
      positionsList.add(StocksProvider.fromJson(value));
    });
    return PortfolioProvider(
      currentValue: (json['current_value'] is int) ? json['current_value'].toDouble() : json['current_value'],
      initialInvestment: (json['initial_investment'] is int) ? json['initial_investment'].toDouble() : json['initial_investment'],
      positions: positionsList,
    );
  }
  static Future<RequestControlProvider> getPortfolio() async {
    bool requestSuccess = true;
    bool connectionFailed = false;
    String? errorMsg;
    PortfolioProvider? portfolioContent;

    final accessControl = AccessControlProvider();
    String token = await accessControl.token;

    final url = Uri.https(accessControl.path, '/api/portfolio');

    if (kDebugMode) print('Requesting: $url');
    try {
      final response = await http.get(url, headers: {
        'Authorization': token,
      });

      if (kDebugMode) print('Response status: ${response.statusCode}');
      if (kDebugMode) print('Response body: ${response.body}');

      final responseData = json.decode(response.body);
      if (kDebugMode) print('Error messgage: ${responseData['error']}');

      if (response.statusCode == 200) {
        requestSuccess = true;
        if (responseData != null) {
          portfolioContent = PortfolioProvider.fromJson(responseData);
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
      response: portfolioContent,
    );
  }
}
