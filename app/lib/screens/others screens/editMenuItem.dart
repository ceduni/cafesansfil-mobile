import 'package:app/provider/cafe_provider.dart';
import 'package:flutter/material.dart';
import 'package:app/modeles/Cafe.dart';
import 'package:app/services/StockService.dart';
import 'package:provider/provider.dart';

class EditMenuItemScreen extends StatefulWidget {
  final MenuItem menuItem;

  const EditMenuItemScreen({Key? key, required this.menuItem})
      : super(key: key);

  @override
  _EditMenuItemScreenState createState() => _EditMenuItemScreenState();
}

class _EditMenuItemScreenState extends State<EditMenuItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.menuItem.name;
    _descriptionController.text = widget.menuItem.description;
    _imageUrlController.text = widget.menuItem.imageUrl;
    _priceController.text = widget.menuItem.price.toString();
    _tagsController.text = widget.menuItem.tags.join(', ');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _saveMenuItem() async {
    if (_priceController.text.isEmpty || _tagsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all fields'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    // Create a new MenuItem using the old one with updated values
    MenuItem updatedItem = MenuItem(
      itemId: widget.menuItem.itemId,
      name: widget.menuItem.name,
      slug: widget.menuItem.slug,
      tags: _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
      description: _descriptionController.text,
      imageUrl: _imageUrlController.text,
      price: double.parse(_priceController.text),
      inStock: widget.menuItem.inStock,
      category: widget.menuItem.category,
      options: widget.menuItem.options,
    );

    try {
      // Get the cafe slug
      Cafe? selectedCafe =
          Provider.of<CafeProvider>(context, listen: false).selectedCafe;
      String cafeSlug = selectedCafe!.slug;
      String itemSlug = widget.menuItem.slug;
      String message =
          await StockService().updateMenuItem(cafeSlug, itemSlug, updatedItem);
      Provider.of<CafeProvider>(context, listen: false)
          .setSelectedCafe(selectedCafe.cafeId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[400],
      ));
      Navigator.pop(context); // Close the screen after saving
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update menu item: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.menuItem.name;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit of $name'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMenuItem,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),*/
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: _tagsController,
              decoration:
                  const InputDecoration(labelText: 'Tags (comma separated)'),
            ),
          ],
        ),
      ),
    );
  }
}
