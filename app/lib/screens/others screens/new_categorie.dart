import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/cafe_provider.dart';

class NewCategoryPage extends StatefulWidget {
  const NewCategoryPage({super.key});

  @override
  _NewCategoryPageState createState() => _NewCategoryPageState();
}

class _NewCategoryPageState extends State<NewCategoryPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Map<String, bool> selectedItems = {};

  @override
  void initState() {
    super.initState();
    final cafeProvider = Provider.of<CafeProvider>(context, listen: false);

    //listes des items not checked
    for (var item in cafeProvider.getMenuItems) {
      selectedItems[item.itemId] = false;
    }
  }

  void _saveCategory() {
    String newCategoryName = _controller.text;
    String newDescription = _descriptionController.text.trim();

    if (newCategoryName.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(" Le nom de la catégorie est requise")),
          );
          return;
    }

    //Get items checked
    List<String> selectedItemsIds = selectedItems.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

        Provider.of<CafeProvider>(context, listen: false).addNewCategory(
          newCategoryName, newDescription, selectedItemsIds);
          Navigator.pop(context); //retour page categorie
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvelle catégorie"),
        actions: [
          IconButton(
            onPressed: _saveCategory,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Nom de la catégorie",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description de la catégorie"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Sélectionner les items à ajouter à cette catégorie",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Consumer<CafeProvider>(
                builder: (context, cafeProvider, child) {
                  List menuItems = cafeProvider.getMenuItems;

                  return menuItems.isEmpty
                      ? const Center(child: Text("Aucun produit trouvé"))
                      :ListView.builder(
                        itemCount: menuItems.length,
                        itemBuilder: (context, index) {
                          var item = menuItems[index];
                          return CheckboxListTile(
                            title: Text(item.name),
                            subtitle: Text("\$${item.price.toStringAsFixed(2)}"),
                            value: selectedItems[item.itemId] ?? false,
                            onChanged: (value) {
                              setState(() {
                                selectedItems[item.itemId] = value ?? false;
                              });
                            },
                          );
                        },
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
