import 'package:flutter/material.dart';
import 'package:app/config.dart';
import 'package:app/styles/dashboard_styles.dart';

class MetricCard extends StatelessWidget {
    final String title;
    final double value;

    const MetricCard({required this.title, required this.value});

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Config.specialBlueLighter,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                    ),
                ],
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(title, style: AppStyles.sectionTitle),
                    const SizedBox(height: 10.0),
                    Text('${value.toStringAsFixed(2)} \$', style: AppStyles.metricValue),
                ],
            ),
        );
    }
}