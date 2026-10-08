import 'package:flutter/material.dart';

import '../trypx_colors.dart';

/// Labelled text field for the dark theme.
class TrypXTextField extends StatefulWidget {
  const TrypXTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.singleLine = true,
    this.trailing,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? placeholder;
  final bool singleLine;
  final Widget? trailing;

  @override
  State<TrypXTextField> createState() => _TrypXTextFieldState();
}

class _TrypXTextFieldState extends State<TrypXTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant TrypXTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: TrypXColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          maxLines: widget.singleLine ? 1 : null,
          style: const TextStyle(color: TrypXColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: const TextStyle(color: TrypXColors.textTertiary),
            filled: true,
            fillColor: TrypXColors.navyContainerHigh,
            suffixIcon: widget.trailing,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: TrypXColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: TrypXColors.primaryOrange),
            ),
          ),
        ),
      ],
    );
  }
}
