// categories_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/screens/others%20screens/categorie_detail.dart';
import 'package:app/screens/others%20screens/new_categorie.dart';
import 'package:app/models/Cafe.dart';

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CafeProvider>(
        builder: (context, cafeProvider, child) {
          List<Categories> categoryNames = cafeProvider.categoryNames;
          if (categoryNames.isEmpty) {
            return const Center(
              child: Text(
                "Aucune catégorie disponible",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Deux colonnes
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2, // Ajustement de la hauteur des cases
              ),
              itemCount: categoryNames.length,
              itemBuilder: (context, index) {
                Categories category = categoryNames[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryDetailPage(categoryName: category.name, categoryId: category.id),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Arrière-plan des cases
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        category.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewCategoryPage()),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
