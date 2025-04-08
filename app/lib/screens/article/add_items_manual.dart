import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/Stock.dart';
import 'package:app/provider/stock_provider.dart';
import 'package:app/models/fournisseur.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AddItemsManual extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const AddItemsManual({key, this.initialData}) : super(key: key);


  @override
  AddItemsManualState createState() => AddItemsManualState();
}

class AddItemsManualState extends State<AddItemsManual> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _fournisseurController = TextEditingController();
  String? selectedFournisseur;
  String? selectedCategories;

  final List<Category> categories = [];

  @override
  void initState() {
  super.initState();
  if (widget.initialData != null) {
    _nameController.text = widget.initialData!["name"] ?? "";
    _descriptionController.text = widget.initialData!["description"] ?? "";
    _imageUrlController.text = widget.initialData!["imageUrl"] ?? "";
    selectedCategories = widget.initialData!["category"] ?? "";
    _quantityController.text = widget.initialData!['quantity'] ?? '';
  }
  if (selectedFournisseur != null) {
    _fournisseurController.text = selectedFournisseur!;
  }
}

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    _fournisseurController.dispose();
    super.dispose();
  }
//fonction utiliser scan code bar quand utilisateur deja dans le formulaire
Future<void> _scanBarcodeOpenForm() async {
  await Navigator.push(
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
  if (context.mounted) Navigator.pop(context);
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
//sauvegarder l'article
  void _saveStockItem() async {
    if (_nameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        int.tryParse(_quantityController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez remplir tous les champs correctement.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    selectedFournisseur = _fournisseurController.text;

// Add new fournisseur to the list if it doesn't exist
if (!stockProvider.fournisseurs.any((f) => f.name == selectedFournisseur)) {
  stockProvider.setFournisseurs([
    ...stockProvider.fournisseurs,
    Fournisseur(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: selectedFournisseur!,
      contactPerson: '',
      email: '',
      phone: '',
      address: '',
      website: '',
      productsSupplied: [],
    ),
  ]);
}


    Stock newStock = Stock(
      id: DateTime.now().toString(), // Generate a unique ID
      itemName: _nameController.text,
      description: _descriptionController.text,
      quantity: int.parse(_quantityController.text),
      imageUrl: _imageUrlController.text,
      fournisseur: selectedFournisseur ?? "Aucun", 
      category: selectedCategories ?? "Aucune",
    );

    try {
      // Call the provider to add stock
      await Provider.of<StockProvider>(context, listen: false).addStockItem(newStock);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Stock ajouté avec succès."),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'ajout du stock: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajout d'un nouvel article"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<StockProvider>(
          builder: (context, stockProvider, child) {
            final fournisseurNames =
                stockProvider.fournisseurs.map((f) => f.name).toList();

            return ListView(
              children: [
                ElevatedButton.icon(
              onPressed: _scanBarcodeOpenForm,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scanner un code-barres"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
                TextField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nom du produit'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                ),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantité'),
                ),
                TextField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
                const SizedBox(height: 20),
                TypeAheadField<String>(
                  suggestionsCallback: (pattern) {
                    return fournisseurNames
                        .where((name) => name
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                        .toList();
                  },
                  builder: (context, controller, focusNode) {
                    controller.text = _fournisseurController.text;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Fournisseur',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        selectedFournisseur = value;
                        _fournisseurController.text = value;
                      },
                    );
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(title: Text(suggestion));
                  },
                  onSelected: (suggestion) {
                    setState(() {
                      selectedFournisseur = suggestion;
                      _fournisseurController.text = suggestion;
                    });
                  },
                  emptyBuilder: (context) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Aucun fournisseur trouvé. Tapez pour en créer un."),
                  ),
                  decorationBuilder: (context, child) {
                    return Material(
                      type: MaterialType.card,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: child,
                    );
                  },
                  offset: const Offset(0, 12),
                  constraints: const BoxConstraints(maxHeight: 300),
                ),
              ],
            );
          },
        ),
      ),
        floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton.extended(
            onPressed: _saveStockItem,
            backgroundColor: Colors.blue,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              "Enregistrer",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

          