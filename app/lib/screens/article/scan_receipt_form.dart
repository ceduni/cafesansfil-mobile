import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:app/screens/article/add_multiple_items.dart';
import 'package:app/screens/article/add_items_manual.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ScanReceiptForm extends StatefulWidget {
  const ScanReceiptForm({super.key});

  @override
  State<ScanReceiptForm> createState() => _ScanReceiptFormState();
}

class _ScanReceiptFormState extends State<ScanReceiptForm> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scanReceiptAndOpenForm());
  }

  Future<void> _scanReceiptAndOpenForm() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isScanning = true;
    });

    final String? scannedText = await scanTextFromImage(image.path);
    if (scannedText != null) {
      List<Map<String, dynamic>> items = await parseReceiptAndFetchMultipleDetails(scannedText);

      setState(() {
        _isScanning = false;
      });

      if (items.length == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddItemsManual(initialData: items.first),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddMultipleItemsForm(initialItemsData: items),
          ),
        );
      }
    } else {
      setState(() {
        _isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Aucun texte détecté."),
        backgroundColor: Colors.red,
      ));
      Navigator.pop(context);
    }
  }

  Future<String?> scanTextFromImage(String imagePath) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final InputImage inputImage = InputImage.fromFilePath(imagePath);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      print("Erreur de reconnaissance OCR: $e");
      return null;
    } finally {
      textRecognizer.close();
    }
  }

  Future<List<Map<String, dynamic>>> parseReceiptAndFetchMultipleDetails(String scannedText) async {
    List<Map<String, dynamic>> items = [];
    List<String> lines = scannedText.split('\n');

    for (String line in lines) {
      if (line.contains(RegExp(r'(\d+)\s*(pcs|g|kg|l|ml|oz|x)', caseSensitive: false))) {
        String? quantity = RegExp(r'(\d+)').firstMatch(line)?.group(1);
        String productName = line.replaceAll(RegExp(r'(\d+)\s*(pcs|g|kg|l|ml|oz|x)', caseSensitive: false), '').trim();

        final Map<String, dynamic>? productDetails = await fetchProductDetailsFromName(productName);

        items.add({
          "name": productDetails?["name"] ?? productName,
          "description": productDetails?["description"] ?? "",
          "imageUrl": productDetails?["imageUrl"] ?? "",
          "category": productDetails?["category"] ?? "",
          "quantity": quantity ?? "1",
        });
      }
    }

    return items;
  }

  Future<Map<String, dynamic>?> fetchProductDetailsFromName(String productName) async {
    if (productName.isEmpty) return null;
    final Uri url = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$productName&search_simple=1&json=1');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["products"] != null && data["products"].isNotEmpty) {
          final product = data["products"][0];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner un reçu"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _isScanning
            ? const CircularProgressIndicator()
            : const Text("Scanner le reçu"),
      ),
    );
  }
}
