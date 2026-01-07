import 'package:flutter/material.dart';

class CompactButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;
  final double elevation;
  final bool isOutlined; // Added isOutlined parameter
  final bool fullWidth; // Added fullWidth parameter
  final EdgeInsetsGeometry? padding; // Added padding parameter

  const CompactButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.height = 36,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 8.0, // Increased from default value
    this.iconSize = 18, // Increased from default value
    this.fontSize = 14, // Increased from default value
    this.fontWeight = FontWeight.w500,
    this.elevation = 0,
    this.isOutlined = false, // Default to filled button
    this.fullWidth = true, // Default to full width
    this.padding, // Optional custom padding
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use provided colors or default theme colors
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.primary;
    final effectiveForegroundColor =
        foregroundColor ??
        (isOutlined ? effectiveBackgroundColor : theme.colorScheme.onPrimary);

    // Use provided padding or default horizontal padding
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 16);

    final buttonWidget =
        isOutlined
            ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: effectiveForegroundColor,
                side: BorderSide(color: effectiveBackgroundColor),
                elevation: elevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: effectivePadding,
              ),
              child: _buildButtonContent(),
            )
            : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveBackgroundColor,
                foregroundColor: effectiveForegroundColor,
                elevation: elevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: effectivePadding,
              ),
              child: _buildButtonContent(),
            );

    return SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: buttonWidget,
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        ),
      ],
    );
  }
}
