import 'package:flutter/material.dart';

// Reusable widget to group alerts by subject.
class AlertGroup extends StatelessWidget {
  final String groupTitle;
  final List<Widget> alerts;

  const AlertGroup({
    Key? key,
    required this.groupTitle,
    required this.alerts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return alerts.isEmpty
        ? const SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  groupTitle.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // List of alerts for this group.
              ...alerts,
            ],
          );
  }
}

