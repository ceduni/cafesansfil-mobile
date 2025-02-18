// stock_tab.dart
import 'package:flutter/material.dart';
import 'package:app/models/Stock.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class StockTab extends StatelessWidget {
  final List<Stock> stocks;

  const StockTab({Key? key, required this.stocks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        final stock = stocks[index];
        return ListTile(
          title: Text(stock.itemName),
          subtitle: Text('${AppLocalizations.of(context)!.quantity_text}: ${stock.quantity}'),
        );
      },
    );
  }
}
