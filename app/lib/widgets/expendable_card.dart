import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/navbar_provider.dart';

class ExpandableAlertCard extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onNavigate;

  const ExpandableAlertCard({
    Key? key,
    required this.title,
    required this.message,
    required this.buttonText,
    this.onNavigate,
  }) : super(key: key);

  @override
  _ExpandableAlertCardState createState() => _ExpandableAlertCardState();
}

class _ExpandableAlertCardState extends State<ExpandableAlertCard> with SingleTickerProviderStateMixin {
  bool isVisible = true;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // Single controller for both slide and fade animations.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  void _dismiss() {
    _controller.forward().then((_) {
      setState(() {
        isVisible = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Card(
          color: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            collapsedIconColor: Colors.white,
            iconColor: Colors.white,
            title: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Navigation button.
                        TextButton(
                          onPressed: () {
                            if (widget.onNavigate != null) {
                              widget.onNavigate!();
                            } else {
                              // For example, if this alert should navigate to tab 1:
                              Provider.of<BottomNavProvider>(context, listen: false)
                                  .updateIndex(1);
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: Text(widget.buttonText),
                        ),
                        const SizedBox(width: 8),
                        // Dismiss button.
                        TextButton(
                          onPressed: _dismiss,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: const Text("Dismiss"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
