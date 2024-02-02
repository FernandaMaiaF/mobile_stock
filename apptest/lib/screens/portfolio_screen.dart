import 'package:apptest/screens/stock_position_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/portfolio_provider.dart';
import '../providers/request_control_provider.dart';
import '../widgets/loading_widget.dart';

class PortfolioScreen extends StatefulWidget {
  static const routeName = '/portfolio';
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  var _isLoading = false;
  PortfolioProvider? portfolio;
  bool boolSortUp = true;

  @override
  void didChangeDependencies() {
    _loadRequiredData();
    super.didChangeDependencies();
  }

  Future<void> _loadRequiredData() async {
    setState(() {
      _isLoading = true;
    });
    RequestControlProvider requestResponse = await PortfolioProvider.getPortfolio();
    if (requestResponse.requestSuccess == true && requestResponse.response != null) {
      setState(() {
        portfolio = requestResponse.response;
      });
    }
    if (requestResponse.requestSuccess == false) {
      if (mounted) requestResponse.showErrorDialog(context, requestResponse.errorMsg);
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        portfolio = requestResponse.response;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white10,
        elevation: 0,
        title: const Text(''),
        automaticallyImplyLeading: false,
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
                physics: const AlwaysScrollableScrollPhysics(),
                child: (portfolio == null)
                    ? const Center(child: Text('No data'))
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$ ${(portfolio!.currentValue != null) ? portfolio!.currentValue!.toStringAsFixed(2) : ''}',
                                  style: const TextStyle(fontSize: 30),
                                ),
                                Text((portfolio!.initialInvestment != null) ? portfolio!.initialInvestment!.toStringAsFixed(2) : ''),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Stocks:'),
                                TextButton.icon(
                                  icon: Icon(
                                    boolSortUp ? Icons.arrow_upward : Icons.arrow_downward,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  label: const Text('Order by: Amount of shares',
                                      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400)),
                                  onPressed: () {
                                    setState(() {
                                      if (boolSortUp) {
                                        portfolio?.positions = portfolio?.positions?..sort((a, b) => a.quantity.compareTo(b.quantity));
                                        boolSortUp = false;
                                      } else {
                                        portfolio?.positions = portfolio?.positions?..sort((a, b) => b.quantity.compareTo(a.quantity));
                                        boolSortUp = true;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          (portfolio!.positions == null)
                              ? const Center(child: Text('No data'))
                              : ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(8),
                                  separatorBuilder: (ctx, i) => const Divider(),
                                  itemCount: portfolio?.positions?.length ?? 0,
                                  itemBuilder: (ctx, i) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context)
                                            .pushNamed(StockPositionScreen.routeName,
                                                arguments: StockPositionArguments(position: portfolio!.positions![i]))
                                            .then((value) => _loadRequiredData());
                                      },
                                      child: ListTile(
                                        title: Text(
                                          portfolio!.positions![i].name,
                                        ),
                                        subtitle: Text(
                                          (portfolio!.positions![i].quantity > 0)
                                              ? '${portfolio!.positions![i].quantity} ${portfolio!.positions![i].type}'
                                              : '',
                                        ),
                                        trailing: RichText(
                                          textAlign: TextAlign.end,
                                          text: TextSpan(
                                            style: const TextStyle(color: Colors.black),
                                            children: [
                                              TextSpan(
                                                text: '\$${portfolio!.positions![i].averagePrice!.toStringAsFixed(2)}',
                                              ),
                                              TextSpan(text: '\n+\$${portfolio!.positions![i].lastPrice!} (0,00)%'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                        ],
                      ),
              ),
            ),
    );
  }
}
