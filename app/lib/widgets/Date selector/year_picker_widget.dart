import 'package:app/config.dart';
import 'package:app/provider/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class YearPickerWidget extends StatefulWidget {
//   final int initialYear = DateTime.now().year;
//   final int firstYear = Config.firstYear;
//   final int lastYear = DateTime.now().year;

  YearPickerWidget();

  @override
  _YearPickerWidgetState createState() => _YearPickerWidgetState();
}

class _YearPickerWidgetState extends State<YearPickerWidget> {
    int _selectedYear = DateTime.now().year;

    void _showYearPicker(BuildContext context) async {
        final int? pickedYear = await showDialog<int>(
            context: context,
            builder: (BuildContext context) {
                return YearPickerDialog(
                    currentYear: _selectedYear,
                );
            },
        );

        if (pickedYear != null) {
            setState(() {
                _selectedYear = pickedYear;
                context.read<OrderProvider>().setCurrentYear(_selectedYear);
                context.read<OrderProvider>().updateHistogramData(_selectedYear);
                context.read<OrderProvider>().updateColorChartData(_selectedYear);
                context.read<OrderProvider>().updateTurnOverAndProfit(_selectedYear);
            });
        }
    }

    Widget styleButton({required String text}) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            decoration: BoxDecoration(
                color: Colors.white, // Couleur de fond du bouton
                borderRadius: BorderRadius.circular(100), // Coins arrondis
            ),
            child: Text(text, style: TextStyle(color: Color(0xFF222222), fontSize: 14, fontWeight: FontWeight.bold),),
        );
    }
        
    @override
    Widget build(BuildContext context) {
        return SizedBox(
            width: 200,
            child: InkWell(
            onTap: () => _showYearPicker(context),
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                children: [
                    Expanded(
                    child: Text(
                        _selectedYear.toString(),
                        style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                    ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                ],
                ),
            ),
            ),
        );
    }

}

class YearPickerDialog extends StatelessWidget {
  final int currentYear;
  final int itemCount; // Number of years to show; default is 50.

  const YearPickerDialog({
    Key? key,
    required this.currentYear,
    this.itemCount = 10,
  }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: const Text('Sélectionner une année'),
            content: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: 300, // Limit the height
                    maxWidth: MediaQuery.of(context).size.width * 0.8, // Limit the width
                ),
                child: SingleChildScrollView(
                    child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(itemCount, (index) {
                        final year = DateTime.now().year - 9 + index;
                        return GestureDetector(
                        onTap: () {
                            Navigator.of(context).pop(year);
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('$year', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
                            ),
                        ),
                        );
                    }),
                    ),
                ),
            ),
        );
    }
}

