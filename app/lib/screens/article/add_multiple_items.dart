import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/Stock.dart';
import 'package:app/provider/stock_provider.dart';
import 'package:app/models/fournisseur.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddMultipleItemsForm extends StatefulWidget {
  final List<Map<String, dynamic>> initialItemsData;

  const AddMultipleItemsForm({super.key, required this.initialItemsData});

  @override
  State<AddMultipleItemsForm> createState() => AddMultipleItemsFormState();
}

class AddMultipleItemsFormState extends State<AddMultipleItemsForm> {
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> descriptionControllers = [];
  List<TextEditingController> quantityControllers = [];
  List<TextEditingController> imageUrlControllers = [];
  List<TextEditingController> fournisseurControllers = [];
  List<String?> selectedFournisseurs = [];

  @override
  void initState() {
    super.initState();
    for (var item in widget.initialItemsData) {
      nameControllers.add(TextEditingController(text: item["name"] ?? ""));
      descriptionControllers.add(TextEditingController(text: item["description"] ?? ""));
      quantityControllers.add(TextEditingController(text: item["quantity"] ?? ""));
      imageUrlControllers.add(TextEditingController(text: item["imageUrl"] ?? ""));
      fournisseurControllers.add(TextEditingController());
      selectedFournisseurs.add(null);
    }
  }

  @override
  void dispose() {
    for (var controller in [...nameControllers, ...descriptionControllers, ...quantityControllers, ...imageUrlControllers, ...fournisseurControllers]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveAllItems() async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    for (int i = 0; i < nameControllers.length; i++) {
      final name = nameControllers[i].text;
      final description = descriptionControllers[i].text;
      final quantityText = quantityControllers[i].text;
      final imageUrl = imageUrlControllers[i].text;
      final fournisseur = fournisseurControllers[i].text;

      if (name.isEmpty || quantityText.isEmpty || int.tryParse(quantityText) == null) {
        continue;
      }

      if (!stockProvider.fournisseurs.any((f) => f.name == fournisseur)) {
        stockProvider.setFournisseurs([
          ...stockProvider.fournisseurs,
          Fournisseur(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: fournisseur,
            contactPerson: '',
            email: '',
            phone: '',
            address: '',
            website: '',
            productsSupplied: [],
          ),
        ]);
      }

      Stock stock = Stock(
        id: DateTime.now().toString(),
        itemName: name,
        description: description,
        quantity: int.parse(quantityText),
        imageUrl: imageUrl,
        fournisseur: fournisseur,
        category: "Aucune",
      );

      await stockProvider.addStockItem(stock);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Articles enregistrés."), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fournisseurs = Provider.of<StockProvider>(context).fournisseurs.map((f) => f.name).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Ajout de plusieurs articles")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: nameControllers.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameControllers[index],
                    decoration: const InputDecoration(labelText: 'Nom du produit'),
                  ),
                  TextField(
                    controller: descriptionControllers[index],
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  TextField(
                    controller: quantityControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantité'),
                  ),
                  TextField(
                    controller: imageUrlControllers[index],
                    decoration: const InputDecoration(labelText: 'Image URL'),
                  ),
                  const SizedBox(height: 12),
                  TypeAheadField<String>(
                    suggestionsCallback: (pattern) => fournisseurs.where((f) => f.toLowerCase().contains(pattern.toLowerCase())).toList(),
                    builder: (context, controller, focusNode) {
                      controller.text = fournisseurControllers[index].text;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Fournisseur',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => fournisseurControllers[index].text = value,
                      );
                    },
                    itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
                    onSelected: (suggestion) {
                      fournisseurControllers[index].text = suggestion;
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAllItems,
        icon: const Icon(Icons.save),
        label: const Text("Tout enregistrer"),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
