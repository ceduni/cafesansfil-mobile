import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:app/models/Cafe.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/services/StockService.dart';
import 'package:app/screens/article/editMenuItem.dart';

class ProductsTab extends StatelessWidget {
  final List<MenuItem> menuItems;

  const ProductsTab({Key? key, required this.menuItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemMenuList(menuItems);
  }

  Widget ItemMenuList(List<MenuItem> menuItems) {
    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        MenuItem menuItem = menuItems[index];
        return Slidable(
          key: ValueKey(menuItem.itemId),
          endActionPane: ActionPane(
            extentRatio: 0.25,
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  _showDeleteConfirmationDialog(context, menuItem);
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            leading: menuItem.imageUrl.isNotEmpty
                ? Image.network(
                    menuItem.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          ),
                        );
                      }
                    },
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return const Icon(Icons.broken_image);
                    },
                  )
                : const Icon(Icons.image_not_supported),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    menuItem.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '\$${menuItem.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle: Text(
              menuItem.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              _navigateToEditMenuItem(context, menuItem);
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, MenuItem item) {
    String itemName = item.name;
    String cafeSlug =
        Provider.of<CafeProvider>(context, listen: false).selectedCafe!.slug;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete $itemName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final stockService = StockService();
                  await stockService.removeMenuItem(cafeSlug, item.slug);

                  Provider.of<CafeProvider>(context, listen: false)
                      .fetchCafe(cafeSlug);
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$itemName deleted successfully')),
                  );
                  Navigator.of(context).pop(); // Dismiss the dialog
                } catch (e) {
                  // Handle error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete $itemName')),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditMenuItem(BuildContext context, MenuItem menuItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMenuItemScreen(menuItem: menuItem),
      ),
    );
  }
}
