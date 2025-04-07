import 'package:app/screens/article/scanBarcodeForm.dart';
import 'package:flutter/material.dart';
import 'package:app/models/Stock.dart';
import 'package:app/screens/article/addItemsManual.dart';

class StockTab extends StatefulWidget {
  final List<Stock> stocks;

  const StockTab({Key? key, required this.stocks}) : super(key: key);

  @override
  _StockTabState createState() => _StockTabState();
}

class _StockTabState extends State<StockTab> {
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }


  void _navigateToAddItemsManual() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItemsManual()),
    );
  }

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: GestureDetector(
        onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(child:
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,),
          ),
        ],
      ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.stocks.length,
        itemBuilder: (context, index) {
          final stock = widget.stocks[index];
          return ListTile(
            title: Text(stock.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Quantité: ${stock.quantity}"),
          );
        },
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (_isMenuOpen)
            Positioned(
              bottom: 70, 
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMenuItem(
                    label: 'Scan code-barres',
                    icon: Icons.qr_code_scanner,
                    backgroundColor: Colors.blue,
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ScanBarcodeForm(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    label: 'Scan reçu',
                    icon: Icons.receipt,
                    backgroundColor: Colors.blue,
                    onTap: () {
                      print("Scan reçu selected");
                    },
                  ),
                  _buildMenuItem(
                    label: 'Entrée manuelle',
                    icon: Icons.edit,
                    backgroundColor: Colors.blue,
                    onTap: _navigateToAddItemsManual,
                  ),
                ],
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _isMenuOpen ? Icons.close : Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
