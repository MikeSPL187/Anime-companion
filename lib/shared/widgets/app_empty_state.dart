import 'package:flutter/material.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.text,
    this.supportingText,
    this.actionLabel,
    this.onAction,
    this.textAlign = TextAlign.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    super.key,
  });

  final String text;
  final String? supportingText;
  final String? actionLabel;
  final VoidCallback? onAction;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final supporting = supportingText;
    final action = actionLabel;
    final actionCallback = onAction;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            text,
            textAlign: textAlign,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (supporting != null) ...[
            const SizedBox(height: 8),
            Text(
              supporting,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (action != null && actionCallback != null) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: actionCallback, child: Text(action)),
          ],
        ],
      ),
    );
  }
}
