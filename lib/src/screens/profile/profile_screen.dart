import 'package:flutter/material.dart';

import '../../routing/app_router.dart';
import 'package:azeri/l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../state/app_preferences.dart';
import '../../theme/app_gradients.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/outlined_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const Color _accentColor = Color(0xFFDEC089);
  static const String _mockPassword = '123456';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _didLoad = false;

  Future<void> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0x33222222)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            onConfirm();
                          },
                          child: Text(
                            confirmLabel,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.changePasswordTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedTextField(
                      hintText: AppLocalizations.of(context)!.oldPassword,
                      controller: oldController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    OutlinedTextField(
                      hintText: AppLocalizations.of(context)!.newPassword,
                      controller: newController,
                      obscureText: true,
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorText!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 42,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (oldController.text.trim() !=
                              ProfileScreen._mockPassword) {
                            setDialogState(
                              () => errorText =
                                  AppLocalizations.of(context)!.oldPasswordWrong,
                            );
                            return;
                          }
                          if (newController.text.trim().isEmpty) {
                            setDialogState(
                              () => errorText =
                                  AppLocalizations.of(context)!.enterNewPassword,
                            );
                            return;
                          }
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.passwordUpdated,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.confirm,
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await AppStateScope.of(context).loadCustomerProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    const pageBg = Color(0xFFF8F7F3);
    final state = AppStateScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final customer = state.customer;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: l10n.profileLabel, showCartButton: false),
            Expanded(
              child: Container(
                color: pageBg,
                child: state.isAuthorized
                    ? Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                16,
                                18,
                                12,
                              ),
                              children: [
                                _ProfileCard(
                                  name: customer?.name ?? l10n.nameHint,
                                  phone: customer?.phone ?? l10n.phoneHint,
                                  email: '',
                                ),
                                const SizedBox(height: 14),
                                _ActionButton(
                                  label: l10n.changePassword,
                                  icon: Icons.lock_outline,
                                  onTap: () =>
                                      _showChangePasswordDialog(context),
                                ),
                                const SizedBox(height: 10),
                                _ActionButton(
                                  label: l10n.myAddresses,
                                  icon: Icons.location_on_outlined,
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.addresses),
                                ),
                                const SizedBox(height: 10),
                                _ActionButton(
                                  label: l10n.myOrders,
                                  icon: Icons.receipt_long_outlined,
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.orders),
                                ),
                                const SizedBox(height: 10),
                                _ActionButton(
                                  label: l10n.myBonuses,
                                  icon: Icons.card_giftcard,
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.bonuses),
                                ),
                                const SizedBox(height: 10),
                                _ActionButton(
                                  label: l10n.settingsTitle,
                                  icon: Icons.settings_outlined,
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.settings),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                            child: Column(
                              children: [
                                _ActionButton(
                                  label: l10n.logout,
                                  icon: Icons.logout,
                                  onTap: () => _showConfirmDialog(
                                    context,
                                    title: l10n.logoutConfirmTitle,
                                    message: l10n.logoutConfirmMessage,
                                    confirmLabel: l10n.logoutConfirmButton,
                                    confirmColor: ProfileScreen._accentColor,
                                    onConfirm: () {
                                      AppStateScope.of(
                                        context,
                                      ).setAuthorized(false);
                                      AppPreferences.setAuthorized(false);
                                      AppPreferences.setCustomerId(null);
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        AppRoutes.login,
                                        (route) => false,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _DangerButton(
                                  label: l10n.deleteAccount,
                                  onTap: () => _showConfirmDialog(
                                    context,
                                    title: l10n.deleteConfirmTitle,
                                    message: l10n.deleteConfirmMessage,
                                    confirmLabel: l10n.deleteConfirmButton,
                                    confirmColor: const Color(0xFFD32F2F),
                                    onConfirm: () {
                                      AppStateScope.of(
                                        context,
                                      ).setAuthorized(false);
                                      AppPreferences.setAuthorized(false);
                                      AppPreferences.setCustomerId(null);
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        AppRoutes.login,
                                        (route) => false,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _UnauthorizedView(
                        message: l10n.unauthorizedMessage,
                        loginLabel: l10n.loginButton,
                        registerLabel: l10n.registerButton,
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
        onProfileTap: () {},
      ),
    );
  }
}

class _UnauthorizedView extends StatelessWidget {
  const _UnauthorizedView({
    required this.message,
    required this.loginLabel,
    required this.registerLabel,
  });

  final String message;
  final String loginLabel;
  final String registerLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRoutes.login),
                  child: Text(
                    loginLabel,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.register),
              child: Text(
                registerLabel,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.phone,
    required this.email,
  });

  final String name;
  final String phone;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            phone,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = ProfileScreen._accentColor;
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: Color(0xFFD32F2F)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
