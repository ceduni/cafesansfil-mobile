import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
    final String text;
    final bool isLoading;
    final VoidCallback onTap;

    const MyButton({
        Key? key,
        required this.text,
        this.isLoading = false,
        required this.onTap,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                    SizedBox(width: 18, height: 18, child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )),
                    SizedBox(width: 12),
                    Text("Connexion...", style: TextStyle(color: Colors.white)),
                ],
                )
            : Text(text),
        );
    }
}
