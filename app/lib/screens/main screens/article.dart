import 'package:app/config.dart';
import 'package:app/modeles/Cafe.dart';
import 'package:app/modeles/Stock.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/provider/stock_provider.dart';
import 'package:app/screens/others%20screens/editMenuItem.dart';
import 'package:app/screens/side%20bar/side_bar.dart';
import 'package:app/services/StockService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class Article extends StatefulWidget {
  const Article({super.key});

  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  int buttonASelected = 0; // 0 = menu, 1 = stock, 2= categories

  void _showAddArticleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    // Fetch the stocks from the database
    await Provider.of<StockProvider>(context, listen: false).fetchStock();
    if (!mounted) return;

    await Provider.of<CafeProvider>(context, listen: false).fetchCafe();
    if (!mounted) return;
  }

  ListView stockList(List<Stock> stocks) {
    return ListView.builder(
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        Stock stock = stocks[index];
        return ListTile(
          title: Text(stock.itemName),
          subtitle: Text(
            '${AppLocalizations.of(context)!.quantity_text}: ${stock.quantity}',
          ),
        );
      },
    );
  }

  ListView ItemMenuList(List<MenuItem> menuItems) {
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
                              color: Config.specialBlue,
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
            title: Text(menuItem.name),
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
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete $itemName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Call the  API
                try {
                  final stockService = StockService();
                  await stockService.removeMenuItem(cafeSlug, item.slug);

                  Provider.of<CafeProvider>(context, listen: false)
                      .setSelectedCafe(cafeSlug);
                  await fetch();

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
              child: Text('Delete'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pagesTitles_articleTitle),
        surfaceTintColor: Config.specialBlue,
      ),
      body: Consumer2<StockProvider, CafeProvider>(
        builder: (context, stockProvider, cafeProvider, child) {
          if (stockProvider.isLoading || cafeProvider.isLoading) {
            return Center(
                child: CircularProgressIndicator(color: Config.specialBlue));
          } else if (stockProvider.hasError || cafeProvider.hasError) {
            return Center(
                child: Text(
                    'Error: ${stockProvider.errorMessage ?? cafeProvider.errorMessage}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // --- Produit btn ---
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: buttonASelected ==0 ? 5 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                            ),
                            backgroundColor: buttonASelected==0
                                ? Config.specialBlue
                                : Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              buttonASelected = 0;
                            });
                          },
                          child: Text('Produits',
                              style: TextStyle(
                                  color: buttonASelected ==0
                                      ? Colors.white
                                      : Config.specialBlue)),
                        ),
                        // --- Stock btn ---
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: buttonASelected ==1 ? 0 : 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                            ),
                            backgroundColor: buttonASelected ==1
                                 ? Config.specialBlue
                                 : Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              buttonASelected = 1;
                            });
                          },
                          child: Text(
                            'Stock',
                            style: TextStyle(
                                color: buttonASelected==1
                                ? Colors.white
                                : Config.specialBlue,),
                          ),
                        ),
                        //---Catégories btn---
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: buttonASelected ==2 ? 5 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                            ),
                            backgroundColor: buttonASelected==2
                                ? Config.specialBlue
                                : Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              buttonASelected = 2;
                            });
                          },
                          child: Text('Catégories',
                              style: TextStyle(
                                  color: buttonASelected ==2
                                      ? Colors.white
                                      : Config.specialBlue)),
                        ),
                      ],
                    ),
                
                  const SizedBox(height: 20),
                  Expanded(
                    child: buttonASelected == 0
                        ? ItemMenuList(cafeProvider.getMenuItems)
                        : buttonASelected == 1
                            ? stockList(stockProvider.Stocks)
                            : buttonASelected == 2
                                ? stockList(stockProvider.Stocks)
                                : Container(), // Add a default case
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: buttonASelected == 1
      ? FloatingActionButton(
        onPressed: () => _showAddArticleDialog(context), //ajouter info article
        backgroundColor: Config.specialBlue,
        child: Icon(Icons.add, color: Colors.white),
      )
      : null,
    );
  }
}