import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/models/Cafe.dart';


class CategoryDetailPage extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const CategoryDetailPage({super.key, required this.categoryName, required this.categoryId});

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  bool isEditing = false;
  late TextEditingController _controller;
  late TextEditingController _descriptionController;
  Map<String, bool> selectedItems = {};

  @override
  void initState() {
    super.initState();
    final cafeProvider = Provider.of<CafeProvider>(context, listen: false);

    //Get category data
    _controller = TextEditingController(text: widget.categoryName);
    _descriptionController = TextEditingController(
        text: "Description de la catégorie ${widget.categoryName}");

    //Get selected items
    for (var item in cafeProvider.getMenuItems) {
      final inCategorie = item.categories.any((cat) => cat.id == widget.categoryId);
      selectedItems[item.itemId] = inCategorie;
    }
  }
  void _toggleEdit() async{
    setState(() {
      isEditing = !isEditing;
    });

    if (!isEditing) {
      // Save changes
      var cafeProvider = Provider.of<CafeProvider>(context, listen: false);
      Categories oldCategory = cafeProvider.categoryNames.firstWhere(
      (cat) => cat.name == widget.categoryName,
    orElse: () => Categories(id: widget.categoryId, name: widget.categoryName, description: _descriptionController.text),
);

Categories newCategory = cafeProvider.categoryNames.firstWhere(
    (cat) => cat.name == _controller.text,
    orElse: () => Categories(id: oldCategory.id, name: _controller.text, description: _descriptionController.text),
);
cafeProvider.updateCategoryDetails(
  oldCategory: oldCategory,
  newCategory: newCategory,
  newDescription: _descriptionController.text,
);
      //Save selected items in category
      List<String> selectedItemsIds =  selectedItems.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      cafeProvider.updateCategoryItems(selectedItemsIds, newCategory);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Catégorie mise à jour avec succès"),
          backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isEditing
        ? const Text("Edit Category")
        : Text(widget.categoryName),
        actions: [
            IconButton(icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isEditing
            ? TextField(controller: _controller,
            decoration: const InputDecoration(labelText: "nom de la categorie"),)
            : Text(widget.categoryName,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            isEditing
            ? TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Description de la catégorie"),)
            : Text(_descriptionController.text, style: const TextStyle (fontSize: 16),),
            const SizedBox(height: 20),

            const Text("Produits dans la catégorie:",
            style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            Expanded(
              child: Consumer<CafeProvider>(
                builder: (context, cafeProvider, child) {
                  final menuItems = cafeProvider.getMenuItems;

                  if(menuItems.isEmpty){
                    const Center(child: Text("Pas de produits dans la catégorie"));
                  }
                  return ListView.builder(
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            final item = menuItems[index];
                            final inCategory = item.categories.any((cat) => cat.id == widget.categoryId);
                            
                            return isEditing
                              ? CheckboxListTile(
                                title: Text(item.name),
                                subtitle: Text("\$${item.price.toStringAsFixed(2)}"),
                                value: selectedItems[item.itemId]??false,
                                onChanged: (bool? isChecked){
                                  setState(() {
                                    selectedItems[item.itemId] = isChecked??false;
                                  });
                                },
                              )
                              : inCategory
                              ? ListTile(
                                title: Text(item.name),
                                subtitle: Text("\$${item.price.toStringAsFixed(2)}"),
                              )
                              :Container();
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
