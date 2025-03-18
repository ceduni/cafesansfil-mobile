import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:app/config.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/provider/stock_provider.dart';
import 'package:app/screens/side%20bar/side_bar.dart';
import 'products_tab.dart';
import 'stock_tab.dart';
import 'categories_tab.dart';

class Article extends StatefulWidget {
    const Article({Key? key}) : super(key: key);

    @override
    State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> with SingleTickerProviderStateMixin {
    late TabController _tabController;

    @override
    void initState() {
        super.initState();
        _tabController = TabController(length: 3, vsync: this);
        fetchData();
    }

    Future<void> fetchData() async {
        await Provider.of<StockProvider>(context, listen: false).fetchStock();
        if (!mounted) return;
        await Provider.of<CafeProvider>(context, listen: false).fetchCafe(Config.cafeSlug);
        await Provider.of<CafeProvider>(context, listen: false).fetchCategory(Config.cafeSlug);
    }

    @override
    void dispose() {
        _tabController.dispose();
        super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
        drawer: const Sidebar(),
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.pagesTitles_articleTitle),
            surfaceTintColor: Config.specialBlue,
            bottom: TabBar(
            controller: _tabController,
            tabs: const [
                Tab(icon: Icon(Icons.fastfood), text: 'Produits'),
                Tab(icon: Icon(Icons.category), text: 'Catégories'),
                Tab(icon: Icon(Icons.store), text: 'Stock'),
            ],
            ),
        ),
        body: Consumer2<StockProvider, CafeProvider>(
            builder: (context, stockProvider, cafeProvider, child) {
            if (stockProvider.isLoading || cafeProvider.isLoading) {
                return Center(
                child: CircularProgressIndicator(color: Config.specialBlue),
                );
            } else if (stockProvider.hasError || cafeProvider.hasError) {
                return Center(
                child: Text('Error: ${stockProvider.errorMessage ?? cafeProvider.errorMessage}'),
                );
            } else {
                return TabBarView(
                controller: _tabController,
                children: [
                    ProductsTab(menuItems: cafeProvider.getMenuItems),
                    CategoriesTab(),
                    StockTab(stocks: stockProvider.Stocks),
                ],
                );
            }
            },
        ),
      
        );
    }


    }

