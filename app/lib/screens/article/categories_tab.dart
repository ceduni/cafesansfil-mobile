// products_tab.dart
import 'package:flutter/material.dart';
import 'package:app/models/Cafe.dart';

class CategoriesTab extends StatelessWidget {
  final List<MenuItem> categories;

  const CategoriesTab({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(categories[index].name),
          // Add more details or actions if needed.
        );
      },
    );
  }
}
