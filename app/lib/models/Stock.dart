import 'dart:convert';

class Stock {
  final String id;
  final String itemName;
  final String category;
  final String description;
  final String imageUrl;
  final String fournisseur;
  int quantity;

  Stock({
    required this.id,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.description,
    required this.imageUrl,
    required this.fournisseur,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    print("DEBUG - converting json to stock:");
    return Stock(
      id: json['_id']?.toString() ?? 'ID_INCONNU',
      itemName: json['item_name'] ?? 'ITEM_INCONNU',
      category: json['category_id']?.toString() ?? 'Catégorie inconnue',
      quantity: json['quantity']!= null ? int.tryParse(json['quantity'].toString()) ?? 0 : 0,
      description: json['description'] ?? 'Pas de description',
      imageUrl: json['imageUrl'] ?? '',
      fournisseur: json['fournisseur'] ?? 'Aucun fournisseur',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'category': category,
      'quantity': quantity,
      'description': description,
      'imageUrl': imageUrl,
      'fournisseur': fournisseur,
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
