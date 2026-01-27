import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_gradients.dart';
import '../state/app_state.dart';
import 'app_icon.dart';
import 'brand_logo.dart';

enum AppBottomTab { menu, profile }

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedTab,
    required this.onMenuTap,
    required this.onProfileTap,
    this.gapWidth = 60,
  });

  final AppBottomTab selectedTab;
  final VoidCallback onMenuTap;
  final VoidCallback onProfileTap;
  final double gapWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        decoration: const BoxDecoration(
          gradient: AppGradients.primary,
          boxShadow: [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 18,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: _BottomItem(
                  icon: Icons.home_outlined,
                  label: AppLocalizations.of(context)!.menuLabel,
                  selected: selectedTab == AppBottomTab.menu,
                  onTap: onMenuTap,
                  assetPath: 'assets/icons/menu.svg',
                ),
              ),
            ),
            SizedBox(width: gapWidth),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showAboutDialog(context),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: BrandLogo(height: 34),
              ),
            ),
            SizedBox(width: gapWidth),
            Expanded(
              child: Center(
                child: _BottomItem(
                  icon: Icons.person_outline,
                  label: AppLocalizations.of(context)!.profileLabel,
                  selected: selectedTab == AppBottomTab.profile,
                  onTap: onProfileTap,
                  assetPath: 'assets/icons/profile.svg',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = AppStateScope.of(context).settings;
    final cafeName = settings?.cafeName.trim().isNotEmpty == true
        ? settings!.cafeName
        : l10n.appTitle;
    final phone = settings?.phone.trim() ?? '';
    final address = settings?.address.trim() ?? '';
    final hours = settings?.workHours.trim() ?? '';
    final instagram = settings?.instagram?.trim() ?? '';
    final telegram = settings?.telegram?.trim() ?? '';

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
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
              children: [
                const BrandLogo(height: 90),
                const SizedBox(height: 12),
                Text(
                  l10n.aboutTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.aboutDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 10),
                _AboutLine(label: l10n.aboutCafeName, value: cafeName),
                if (address.isNotEmpty)
                  _AboutLine(label: l10n.aboutAddress, value: address),
                if (phone.isNotEmpty)
                  _AboutLine(label: l10n.aboutPhone, value: phone),
                if (hours.isNotEmpty)
                  _AboutLine(label: l10n.aboutHours, value: hours),
                const SizedBox(height: 14),
                _SocialTiles(
                  instagram: instagram,
                  telegram: telegram,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AboutLine extends StatelessWidget {
  const _AboutLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialTiles extends StatelessWidget {
  const _SocialTiles({
    required this.instagram,
    required this.telegram,
  });

  final String instagram;
  final String telegram;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];
    if (instagram.isNotEmpty) {
      tiles.add(
        _SocialTile(
          label: AppLocalizations.of(context)!.aboutInstagram,
          icon: Icons.camera_alt_outlined,
          onTap: () => _launchUrl(_instagramUrl(instagram)),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF58529),
              Color(0xFFDD2A7B),
              Color(0xFF8134AF),
              Color(0xFF515BD4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: Colors.white,
          iconColor: Colors.white,
        ),
      );
    }
    if (telegram.isNotEmpty) {
      tiles.add(
        _SocialTile(
          label: AppLocalizations.of(context)!.aboutTelegram,
          icon: Icons.send_outlined,
          onTap: () => _launchUrl(_telegramUrl(telegram)),
          color: const Color(0xFF2AABEE),
          textColor: Colors.white,
          iconColor: Colors.white,
        ),
      );
    }
    if (tiles.isEmpty) return const SizedBox.shrink();
    return Row(
      children: tiles
          .map(
            (tile) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: tile,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _SocialTile extends StatelessWidget {
  const _SocialTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.gradient,
    this.textColor,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Gradient? gradient;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color ?? Colors.white,
            gradient: gradient,
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: iconColor ?? Colors.black),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (url.isEmpty) return;
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

String _instagramUrl(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  final handle = value.startsWith('@') ? value.substring(1) : value;
  return 'https://instagram.com/$handle';
}

String _telegramUrl(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  final handle = value.startsWith('@') ? value.substring(1) : value;
  return 'https://t.me/$handle';
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.assetPath,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    const color = Colors.black;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              assetPath: assetPath ?? '',
              size: 26,
              color: color,
              fallback: icon,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
