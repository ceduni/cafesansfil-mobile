import 'dart:convert';

class Stock {
  final String id;
  final String itemName;
  final String category;
  int quantity;

  Stock({
    required this.id,
    required this.itemName,
    required this.category,
    required this.quantity,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    print("DEBUG - converting json to stock:");
    return Stock(
      id: json['_id']?.toString() ?? 'ID_INCONNU',
      itemName: json['item_name'] ?? 'ITEM_INCONNU',
      category: json['category_id']?.toString() ?? 'Catégorie inconnue',
      quantity: json['quantity']!= null ? int.tryParse(json['quantity'].toString()) ?? 0 : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'category': category,
      'quantity': quantity,
    };
  }

  static List<Stock> lowQuantity(List<Stock> stocks) {
    List<Stock> lowStocks = [];
    for (Stock stock in stocks) {
      if (stock.quantity < 10) {
        // Example condition for low stock
        lowStocks.add(stock);
      }
    }
    return lowStocks;
  }

  @override
  String toString() {
    final jsonMap = toJson();
    return const JsonEncoder.withIndent('  ').convert(jsonMap);
  }
}
