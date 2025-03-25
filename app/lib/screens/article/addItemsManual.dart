import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/Stock.dart';
import 'package:app/provider/stock_provider.dart';
import 'package:app/models/fournisseur.dart';

class AddItemsManual extends StatefulWidget {
  const AddItemsManual({Key? key}) : super(key: key);


  @override
  AddItemsManualState createState() => AddItemsManualState();
}

class AddItemsManualState extends State<AddItemsManual> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String? selectedFournisseur;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

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

    Stock newStock = Stock(
      id: DateTime.now().toString(), // Generate a unique ID
      itemName: _nameController.text,
      description: _descriptionController.text,
      quantity: int.parse(_quantityController.text),
      imageUrl: _imageUrlController.text,
      fournisseur: selectedFournisseur ?? "Aucun", 
      category: '',
    );

    try {
      // Call the provider to add stock
      await Provider.of<StockProvider>(context, listen: false).addStockItem(newStock);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Stock ajouté avec succès."),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context); // Close the screen after saving
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom du produit'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
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

            // Fournisseur Selection (Dropdown)
            Consumer<StockProvider>(
              builder: (context, stockProvider, child) {
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Fournisseur"),
                  value: selectedFournisseur,
                  items: stockProvider.fournisseurs.map((fournisseur) {
                    return DropdownMenuItem<String>(
                      value: fournisseur.name,
                      child: Text(fournisseur.name),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedFournisseur = value;
                    });
                  },
                );
              },
            ),
          ],
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

          