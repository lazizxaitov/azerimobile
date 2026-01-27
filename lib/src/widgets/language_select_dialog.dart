import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';

Future<void> showLanguageSelectDialog(
  BuildContext context, {
  required void Function(String, BuildContext) onSelected,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'language',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) =>
        _LanguageSelectDialog(onSelected: onSelected),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _LanguageSelectDialog extends StatelessWidget {
  const _LanguageSelectDialog({required this.onSelected});

  final void Function(String, BuildContext) onSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
        SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Color(0xFFDEC089),
                      Color(0xFFF6E8D3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectLanguage,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _LanguageButton(
                      label: AppLocalizations.of(context)!.languageRussian,
                      flag: const _FlagIcon.russia(),
                      onTap: () => onSelected('ru', context),
                    ),
                    const SizedBox(height: 10),
                    _LanguageButton(
                      label: AppLocalizations.of(context)!.languageUzbek,
                      flag: const _FlagIcon.uzbekistan(),
                      onTap: () => onSelected('uz', context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.onTap,
    required this.flag,
  });

  final String label;
  final VoidCallback onTap;
  final Widget flag;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            flag,
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _FlagIcon extends StatelessWidget {
  const _FlagIcon.russia() : _type = _FlagType.russia;
  const _FlagIcon.uzbekistan() : _type = _FlagType.uzbekistan;

  final _FlagType _type;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 20,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0x33000000)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: _type == _FlagType.russia
              ? Column(
                  children: const [
                    Expanded(child: ColoredBox(color: Colors.white)),
                    Expanded(child: ColoredBox(color: Color(0xFF1C57A5))),
                    Expanded(child: ColoredBox(color: Color(0xFFD32F2F))),
                  ],
                )
              : Column(
                  children: const [
                    Expanded(child: ColoredBox(color: Color(0xFF1E91D6))),
                    SizedBox(height: 2, child: ColoredBox(color: Color(0xFFD32F2F))),
                    Expanded(child: ColoredBox(color: Colors.white)),
                    SizedBox(height: 2, child: ColoredBox(color: Color(0xFFD32F2F))),
                    Expanded(child: ColoredBox(color: Color(0xFF2E7D32))),
                  ],
                ),
        ),
      ),
    );
  }
}

enum _FlagType { russia, uzbekistan }
