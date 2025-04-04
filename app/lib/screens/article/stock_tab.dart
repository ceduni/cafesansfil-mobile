import 'package:flutter/material.dart';
import 'package:app/models/Stock.dart';
import 'package:app/screens/article/addItemsManual.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class StockTab extends StatefulWidget {
  final List<Stock> stocks;

  const StockTab({Key? key, required this.stocks}) : super(key: key);

  @override
  _StockTabState createState() => _StockTabState();
}

class _StockTabState extends State<StockTab> {
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }
//barcode scanner
  Future<void> _scanBarcodeOpenForm() async {
    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text("Scanner un code-barres"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
    ),
  );
  String barcode = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", "Annuler", true, ScanMode.BARCODE);

  if (barcode != "-1") {
    Map<String, dynamic>? productDetails = await fetchProductDetails(barcode);
    
    if (productDetails != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddItemsManual(initialData: productDetails),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produit non trouvé."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
Future<Map<String, dynamic>?> fetchProductDetails(String barcode) async {
  final apiUrl = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
  try {
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["status"] == 1) {
        final product = data["product"];
        return {
          "name": product["product_name"] ?? "",
          "description": product["generic_name"] ?? "",
          "imageUrl": product["image_url"] ?? "",
          "category": product["categories"]?.split(",").first ?? "",
        };
      }
    }
  } catch (e) {
    print("Erreur de récupération: $e");
  }

  return null;
}

//recu scanner

  void _navigateToAddItemsManual() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItemsManual()),
    );
  }

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: GestureDetector(
        onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(child:
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,),
          ),
        ],
      ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.stocks.length,
        itemBuilder: (context, index) {
          final stock = widget.stocks[index];
          return ListTile(
            title: Text(stock.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Quantité: ${stock.quantity}"),
          );
        },
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (_isMenuOpen)
            Positioned(
              bottom: 70, 
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMenuItem(
                    label: 'Scan codebar',
                    icon: Icons.qr_code_scanner,
                    backgroundColor: Colors.blue,
                    onTap: _scanBarcodeOpenForm,
                  ),
                  _buildMenuItem(
                    label: 'Scan reçu',
                    icon: Icons.receipt,
                    backgroundColor: Colors.blue,
                    onTap: () {
                      print("Scan reçu selected");
                    },
                  ),
                  _buildMenuItem(
                    label: 'Entrée manuelle',
                    icon: Icons.edit,
                    backgroundColor: Colors.blue,
                    onTap: _navigateToAddItemsManual,
                  ),
                ],
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _isMenuOpen ? Icons.close : Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
