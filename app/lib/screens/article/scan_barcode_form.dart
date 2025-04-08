import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:app/screens/article/add_items_manual.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanBarcodeForm extends StatefulWidget {
  const ScanBarcodeForm({super.key});

  @override
  State<ScanBarcodeForm> createState() => _ScanBarcodeFormState();
}

class _ScanBarcodeFormState extends State<ScanBarcodeForm> {
  bool _isScanning = true;

  Future<Map<String, dynamic>?> _fetchProductDetails(String barcode) async {
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
      debugPrint("Erreur de récupération: $e");
    }
    return null;
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null || barcode == "-1") return;

    setState(() {
      _isScanning = false;
    });

    final productDetails = await _fetchProductDetails(barcode);
    if (!mounted) return;

    if (productDetails != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddItemsManual(initialData: productDetails),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Produit non trouvé."),
        backgroundColor: Colors.red,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner un Code-barre"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates),
            onDetect: _onDetect,
          ),
          const Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Text(
              "Placez le code-barres dans l'encadré",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
