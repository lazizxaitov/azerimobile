import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';

import '../../routing/app_router.dart';
import '../../formatters/uzbek_phone_input_formatter.dart';
import '../../theme/app_gradients.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/outlined_text_field.dart';
import '../../state/app_state.dart';
import '../../state/app_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+998 ';
    _phoneController.selection =
        TextSelection.collapsed(offset: _phoneController.text.length);
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final next = digits.length > 3;
    if (next == _showPassword) return;
    setState(() => _showPassword = next);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _LoginCard(
                obscurePassword: _obscurePassword,
                showPassword: _showPassword,
                phoneController: _phoneController,
                passwordController: _passwordController,
                onTogglePassword: () => setState(
                  () => _obscurePassword = !_obscurePassword,
                ),
                isSubmitting: _isSubmitting,
                onSubmit: _submit,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    if (phone.isEmpty || password.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final customer = await AppStateScope.of(context).loginCustomer(
        phone: phone,
        password: password,
      );
      await AppPreferences.setAuthorized(true);
      await AppPreferences.setCustomerId(customer.id);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.obscurePassword,
    required this.showPassword,
    required this.phoneController,
    required this.passwordController,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final bool obscurePassword;
  final bool showPassword;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Center(child: BrandLogo(height: 78)),
          const SizedBox(height: 26),
          Text(
            l10n.loginTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.loginSubtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedTextField(
            hintText: l10n.phoneHint,
            keyboardType: TextInputType.phone,
            controller: phoneController,
            inputFormatters: [UzbekPhoneInputFormatter()],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return SizeTransition(
                sizeFactor: curved,
                axisAlignment: -1,
                child: FadeTransition(opacity: curved, child: child),
              );
            },
            child: showPassword
                ? Padding(
                    key: const ValueKey('password'),
                    padding: const EdgeInsets.only(top: 12),
                    child: OutlinedTextField(
                      hintText: l10n.passwordHint,
                      obscureText: obscurePassword,
                      controller: passwordController,
                      suffixIcon: IconButton(
                        onPressed: onTogglePassword,
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                l10n.forgotPassword,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.loginButton,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      AppStateScope.of(context).setAuthorized(false);
                      AppPreferences.setAuthorized(false);
                      AppPreferences.setCustomerId(null);
                      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: Text(l10n.guestButton),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.register),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: Text(l10n.registerButton),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
