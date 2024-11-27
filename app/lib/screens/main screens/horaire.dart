import 'package:app/config.dart';
import 'package:app/provider/shift_provider.dart';
import 'package:app/screens/side%20bar/side_bar.dart';
import 'package:app/widgets/time_planner_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Horaire extends StatefulWidget {
  const Horaire({super.key});

  @override
  State<Horaire> createState() => _HoraireState();
}

class _HoraireState extends State<Horaire> {
  @override
  void initState() {
    super.initState();
    // Fetch all shifts on initialization.
    Provider.of<ShiftProvider>(context, listen: false).fetchAllShifts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horaire'),
      ),
      body: TimePlannerWidget(),
      drawer: Sidebar(), // Include your side bar
    );
  }
}
