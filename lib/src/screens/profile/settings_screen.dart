import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';

import '../../routing/app_router.dart';
import '../../state/app_preferences.dart';
import '../../state/app_state.dart';
import '../../theme/app_gradients.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'ru';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final saved = await AppPreferences.getLanguage();
    if (!mounted || saved == null) return;
    setState(() => _language = saved);
  }

  void _selectLanguage(String value) {
    if (_language == value) return;
    setState(() => _language = value);
    AppPreferences.setLanguage(value);
    AppStateScope.of(context).setLocale(Locale(value));
  }

  @override
  Widget build(BuildContext context) {
    const pageBg = Color(0xFFF8F7F3);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppTopBar(title: l10n.settingsTitle, showCartButton: false),
            Expanded(
              child: Container(
                color: pageBg,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.languageTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _LanguageOption(
                            label: l10n.languageRussian,
                            selected: _language == 'ru',
                            onTap: () => _selectLanguage('ru'),
                          ),
                          const SizedBox(height: 10),
                          _LanguageOption(
                            label: l10n.languageUzbek,
                            selected: _language == 'uz',
                            onTap: () => _selectLanguage('uz'),
                          ),
                          const SizedBox(height: 10),
                          _LanguageOption(
                            label: l10n.languageEnglish,
                            selected: _language == 'en',
                            onTap: () => _selectLanguage('en'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedTab: AppBottomTab.profile,
        onMenuTap: () => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
        onProfileTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.profile),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.primary : null,
          color: selected ? null : const Color(0xFFF8F7F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0x66D1B47A) : const Color(0x33000000),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.black : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black.withValues(alpha: selected ? 1 : 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
