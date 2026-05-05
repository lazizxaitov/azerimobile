import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class OutlinedTextField extends StatelessWidget {
  const OutlinedTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.inputFormatters,
    this.textStyle,
    this.contentPadding,
  });

  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    const radius = 16.0;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      showCursor: readOnly ? false : null,
      enableInteractiveSelection: readOnly ? false : null,
      onTap: onTap,
      inputFormatters: inputFormatters,
      style: textStyle ??
          const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
      decoration: InputDecoration(
        filled: false,
        fillColor: Colors.transparent,
        hintText: hintText,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black.withValues(alpha: 0.6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.stroke, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.stroke, width: 1.2),
        ),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
