import 'package:flutter/material.dart';

import '../trypx_colors.dart';

/// Rounded card container.
class TrypXCard extends StatelessWidget {
  const TrypXCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderAccent,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? borderAccent;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(16);
    return Material(
      color: TrypXColors.cardNavy,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: borderAccent != null
                ? Border.all(color: borderAccent!)
                : null,
          ),
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
