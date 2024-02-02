import 'dart:convert';

import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'access_control_provider.dart';
import 'request_control_provider.dart';

class StocksProvider {
  String aapl;
  String name;
  int quantity;
  double? averagePrice;
  String? lastPrice;
  String currency;
  String type;
  String logoUrl;
  String? description;
  String? website;
  String? sector;
  String? industry;
  String? phoneNumber;
  String? address;
  String? ipoDate;

  StocksProvider({
    required this.aapl,
    required this.name,
    this.quantity = 0,
    required this.averagePrice,
    required this.lastPrice,
    required this.currency,
    required this.type,
    required this.logoUrl,
    required this.description,
    required this.website,
    required this.sector,
    required this.industry,
    required this.phoneNumber,
    required this.address,
    required this.ipoDate,
  });

  factory StocksProvider.fromJson(Map<String, dynamic> json) {
    return StocksProvider(
      aapl: json['ticker'] ?? '',
      name: json['name'] ?? '',
      quantity: (json['quantity'] is int) ? json['quantity'] : 0,
      averagePrice: (json['average_price'] is int) ? json['average_price'].toDouble() : json['average_price'],
      lastPrice: json['last_price'] ?? '',
      currency: json['currency'] ?? '',
      type: json['type'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      description: json['description'] ?? '',
      website: json['website'] ?? '',
      sector: json['sector'] ?? '',
      industry: json['industry'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      ipoDate: json['ipo_date'] ?? '',
    );
  }

  factory StocksProvider.fromDetailedJson(Map<String, dynamic> json) {
    return StocksProvider(
      aapl: json['ticker'] ?? '',
      name: json['name'] ?? '',
      averagePrice: (json['average_price'] is int) ? json['average_price'].toDouble() : json['average_price'],
      lastPrice: json['last_price'] ?? '',
      currency: json['currency'] ?? '',
      type: json['type'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      description: json['description'] ?? '',
      website: json['website'] ?? '',
      sector: json['sector'] ?? '',
      industry: json['industry'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      ipoDate: json['ipo_date'] ?? '',
    );
  }

  static Future<RequestControlProvider> getStock(String symbol) async {
    bool requestSuccess = true;
    bool connectionFailed = false;
    String? errorMsg;
    StocksProvider? stocksContent;

    final accessControl = AccessControlProvider();
    String token = await accessControl.token;

    final url = Uri.https(
      accessControl.path,
      'api/symbol/$symbol',
    );

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
          stocksContent = StocksProvider.fromDetailedJson(responseData);
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
      response: stocksContent,
    );
  }
}
