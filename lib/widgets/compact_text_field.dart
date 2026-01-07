import 'package:flutter/material.dart';

class CompactTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final int? maxLines;
  final double minHeight;
  final double maxHeight;
  final bool autogrow;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry? margin;
  final void Function(String)? onChanged;

  const CompactTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.minHeight = 40, // increased from 32
    this.maxHeight = 120,
    this.autogrow = false,
    this.decoration,
    this.keyboardType,
    this.validator,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16, // increased from 12
      vertical: 12, // increased from 8
    ),
    this.margin,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : (autogrow ? null : maxLines),
        style: TextStyle(
          fontSize: 13, // increased from 11
          color: Colors.grey.shade800,
        ), // back to 11px
        keyboardType: keyboardType,
        validator: validator,
        decoration: (decoration ?? const InputDecoration()).copyWith(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 13, // increased from 11
            color: Colors.grey.shade600,
          ), // back to 11px
          labelText: labelText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          isDense: true,
          isCollapsed: true, // Add this to remove any internal spacing
          contentPadding:
              prefixIcon == null && suffixIcon == null
                  ? contentPadding
                  : const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ), // increased padding
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
