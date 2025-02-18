// products_tab.dart
import 'package:flutter/material.dart';
import 'package:app/models/Cafe.dart';

class ProductsTab extends StatelessWidget {
  final List<MenuItem> menuItems;

  const ProductsTab({Key? key, required this.menuItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(menuItems[index].name),
          // Add more details or actions if needed.
        );
      },
    );
  }
}
