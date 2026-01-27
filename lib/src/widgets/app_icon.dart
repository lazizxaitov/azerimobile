import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.assetPath,
    this.size = 26,
    this.color,
    this.fallback,
    this.badgeActive = false,
    this.badgeColor = const Color(0xFF2ECC71),
  });

  final String assetPath;
  final double size;
  final Color? color;
  final IconData? fallback;
  final bool badgeActive;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = badgeActive ? badgeColor : color;

    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: effectiveColor == null
            ? null
            : ColorFilter.mode(effectiveColor, BlendMode.srcIn),
        placeholderBuilder: (_) => SizedBox(width: size, height: size),
      );
    }

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: effectiveColor,
      errorBuilder: (context, error, stackTrace) => Icon(
        fallback ?? Icons.help_outline,
        size: size,
        color: effectiveColor ?? Colors.black,
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.onPressed,
    required this.assetPath,
    required this.fallback,
    this.size = 26,
    this.badgeActive = false,
    this.badgeColor = const Color(0xFF2ECC71),
  });

  final VoidCallback onPressed;
  final String assetPath;
  final IconData fallback;
  final double size;
  final bool badgeActive;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      icon: AppIcon(
        assetPath: assetPath,
        size: size,
        color: Colors.black,
        fallback: fallback,
        badgeActive: badgeActive,
        badgeColor: badgeColor,
      ),
    );
  }
}
