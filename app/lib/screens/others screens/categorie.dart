import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/screens/others%20screens/categorie_detail.dart';
import 'package:app/screens/others%20screens/new_categorie.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      body: Consumer<CafeProvider>(
        builder: (context, cafeProvider, child) {
          List<String> categories = cafeProvider.getMenuItems
              .expand((item) => item.categories) // Get categories from menu items
              .toSet()
              .toList(); // 

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two columns
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2,
            ),
            itemCount: categories.length ,
            itemBuilder: (context, index) {
              String category = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDetailPage(categoryName: category),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),

                  child: Center(
                    child: Text(
                      category,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewCategoryPage()),
          );
        },
        backgroundColor: Colors.grey,
        child: const Icon(Icons.add,color: Colors.white),
      ),
    );
  }
}
