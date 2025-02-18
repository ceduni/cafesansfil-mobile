import 'package:flutter/material.dart';
import 'package:app/config.dart';

class AsyncCard extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final Widget child;

  const AsyncCard({
    Key? key,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Config.specialBlue))
            : hasError
                ? Center(child: Text('Error: $errorMessage'))
                : child,
      ),
    );
  }
}
