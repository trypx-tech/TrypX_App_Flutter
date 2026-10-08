import 'package:flutter/material.dart';

import '../trypx_colors.dart';

/// Primary filled button.
class TrypXPrimaryButton extends StatelessWidget {
  const TrypXPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.fillsWidth = false,
    this.trailingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool fillsWidth;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && onPressed != null;
    final Widget button = FilledButton(
      onPressed: isEnabled ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: TrypXColors.primaryOrange,
        foregroundColor: TrypXColors.textPrimary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(text),
          if (trailingIcon != null) ...<Widget>[
            const SizedBox(width: 8),
            Icon(trailingIcon),
          ],
        ],
      ),
    );

    if (fillsWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
