import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../providers/stocks_provider.dart';
import '../providers/request_control_provider.dart';
import '../widgets/loading_widget.dart';

class StockPositionArguments {
  final StocksProvider position;
  StockPositionArguments({required this.position});
}

class StockPositionScreen extends StatefulWidget {
  static const routeName = '/stocks';
  const StockPositionScreen({super.key});

  @override
  State<StockPositionScreen> createState() => _StockPositionScreenState();
}

class _StockPositionScreenState extends State<StockPositionScreen> {
  var _isLoading = false;
  StocksProvider? stock;
  StocksProvider? position;

  @override
  void didChangeDependencies() {
    _loadRequiredData();
    super.didChangeDependencies();
  }

  Future<void> _loadRequiredData() async {
    setState(() {
      _isLoading = true;
    });
    StockPositionArguments? args = ModalRoute.of(context)!.settings.arguments as StockPositionArguments?;
    setState(() {
      position = args!.position;
    });
    RequestControlProvider requestResponse = await StocksProvider.getStock(args!.position.aapl);

    if (requestResponse.requestSuccess == false) {
      if (mounted) requestResponse.showErrorDialog(context, requestResponse.errorMsg);
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        stock = requestResponse.response;
      });
      inspect(stock);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  // Function to launch the URL
  void _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white10,
        elevation: 0,
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.black,
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: _isLoading == true
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: () => _loadRequiredData(),
              child: SingleChildScrollView(
                child: (stock == null)
                    ? const Center(child: Text('No data'))
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  stock!.name,
                                  style: const TextStyle(fontSize: 30),
                                ),
                                Text(
                                  stock!.aapl,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(stock!.description ?? ''),
                            ),
                            ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Your position: ${position!.quantity} stocks(\$${position!.averagePrice!.toStringAsFixed(2)})'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Last price: ${stock!.quantity} stocks(${stock!.currency})'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Adress: ${stock!.address}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      const Text('Website: '),
                                      GestureDetector(
                                        onTap: () => (stock!.website != null) ? _launchURL(stock!.website!) : null,
                                        child: Text(
                                          stock!.website ?? '',
                                          style: const TextStyle(
                                            decoration: TextDecoration.underline,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Phone: ${stock!.phoneNumber}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Sector: ${stock!.sector}'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
    );
  }
}
