import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';

import '../../routing/app_router.dart';
import '../../formatters/uzbek_phone_input_formatter.dart';
import '../../theme/app_gradients.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/outlined_text_field.dart';
import '../../state/app_state.dart';
import '../../state/app_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  final _phoneController = TextEditingController(text: '+998 ');
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _phoneController.selection =
        TextSelection.collapsed(offset: _phoneController.text.length);
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
              child: _RegisterCard(
                obscurePassword: _obscurePassword,
                phoneController: _phoneController,
                nameController: _nameController,
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

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    if (name.isEmpty || phone.isEmpty || password.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final customer = await AppStateScope.of(context).registerCustomer(
        name: name,
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

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    required this.obscurePassword,
    required this.phoneController,
    required this.nameController,
    required this.passwordController,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final bool obscurePassword;
  final TextEditingController phoneController;
  final TextEditingController nameController;
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
            l10n.registerTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.registerSubtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedTextField(
            hintText: l10n.nameHint,
            controller: nameController,
          ),
          const SizedBox(height: 12),
          OutlinedTextField(
            hintText: l10n.phoneHint,
            keyboardType: TextInputType.phone,
            controller: phoneController,
            inputFormatters: [UzbekPhoneInputFormatter()],
          ),
          const SizedBox(height: 12),
          OutlinedTextField(
            hintText: l10n.passwordHint,
            obscureText: obscurePassword,
            controller: passwordController,
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                l10n.createAccount,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.alreadyHaveAccount,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed(
                    AppRoutes.login,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: Text(l10n.loginButton),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
