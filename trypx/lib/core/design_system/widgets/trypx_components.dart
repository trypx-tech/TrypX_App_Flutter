library;

import 'package:flutter/material.dart';
import '../trypx_colors.dart';
import '../trypx_spacing.dart';

class TrypXTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool enabled;

  const TrypXTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: TrypXColors.textSecondary,
        padding: const EdgeInsets.symmetric(vertical: TrypXSpacing.m, horizontal: TrypXSpacing.l),
        minimumSize: const Size(48, 48),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class TrypXEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const TrypXEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TrypXSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: TrypXColors.borderDefault),
            const SizedBox(height: TrypXSpacing.l),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: TrypXColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TrypXSpacing.s),
            Text(
              subtitle,
              style: const TextStyle(color: TrypXColors.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class TrypXTopBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const TrypXTopBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: TrypXColors.surfaceNavy,
      elevation: 0,
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: TrypXColors.textPrimary),
              onPressed: onBack,
              tooltip: 'Back',
            )
          : null,
      title: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index < currentStep;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? TrypXColors.secondaryCyan : TrypXColors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class TrypXStatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const TrypXStatusBadge({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TrypXSelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const TrypXSelectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TrypXSpacing.xl),
        decoration: BoxDecoration(
          color: TrypXColors.cardNavy,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? TrypXColors.secondaryCyan : TrypXColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: TrypXColors.secondaryCyan.withOpacity(0.2), blurRadius: 12)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: isSelected ? TrypXColors.secondaryCyan : TrypXColors.textSecondary),
            const SizedBox(height: TrypXSpacing.base),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: TrypXColors.textPrimary)),
            const SizedBox(height: TrypXSpacing.s),
            Text(description, style: const TextStyle(fontSize: 14, color: TrypXColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
