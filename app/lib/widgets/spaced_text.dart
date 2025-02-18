import 'package:flutter/material.dart';

class SpacedText extends StatelessWidget {
    final String text;
    final TextStyle? style;
    final double? spaceBefore;  // Optional argument for space before the text

    const SpacedText({
        required this.text,
        this.style,
        this.spaceBefore,  // Make spaceBefore optional
    });

    @override
    Widget build(BuildContext context) {
        final TextStyle defaultStyle = TextStyle(fontWeight: FontWeight.normal);

        // Conditionally add space before the text if spaceBefore is provided
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                if (spaceBefore != null) SizedBox(height: spaceBefore!), // Adds space only if spaceBefore is not null
                Text(text, style: style ?? defaultStyle),
        ],
        );
    }
}
