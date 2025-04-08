import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) =>_scanReceiptandOpenForm());
  }

  Future<void> _scanReceiptandOpenForm() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image ==null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isScanning = true;
    });

    final String? scannedText = await scanTextFromImage(image.path);
    if (scannedText != null) {
      Map<String, dynamic> productDetails =  await parseReceiptAndFetchDetails(scannedText);
      
      setState(() {
        _isScanning = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddItemsManual(initialData: productDetails),
        ),
      );
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
    final textReconignizer = TextRecognizer(script: TextRecognitionScript.latin);
    final InputImage inputImage = InputImage.fromFilePath(imagePath);

    try{
      final RecognizedText recognizedText = await textReconignizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      print("Erreur de reconnaissance OCR: $e");
      return null;
    } finally { textReconignizer.close(); }
  }

  Future<Map<String, dynamic>> parseReceiptAndFetchDetails(String scannedText) async {
    List<String> lines = scannedText.split('\n');
    String? productName;
    String? quantity;

    for (String line in lines) {
      if (line.contains(RegExp(r'(\d+)\s*(pcs|g|kg|l|ml|oz|x)', caseSensitive: false))) {
        quantity = RegExp(r'(\d+)').firstMatch(line)?.group(1);
        productName = line.replaceAll(RegExp(r'(\d+)\s*(pcs|g|kg|l|ml|oz|x)'), '').trim();
        break;
      }
    }

    final String name = productName ?? "Produit non trouvé";
    final Map<String, dynamic>? productDetails = await fetchProductDetailsFromName(name);

    return{
      "name": productDetails?["name"] ?? name,
      "description": productDetails?["description"] ?? "",
      "imageUrl": productDetails?["imageUrl"] ?? "",
      "category": productDetails?["category"] ?? "",
      "quantity": quantity ?? "",
    };
  }

  Future<Map<String, dynamic>?> fetchProductDetailsFromName(String productName) async {
    if (productName.isEmpty) return null;
    final Uri url = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$productName&search_simple=1&json=1');
      
    try {
      final response = await http.get(url);
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