import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:azeri/l10n/app_localizations.dart';

import '../routing/app_router.dart';
import '../state/app_state.dart';
import '../state/app_preferences.dart';
import '../theme/app_theme.dart';

class AzeriApp extends StatefulWidget {
  const AzeriApp({super.key});

  @override
  State<AzeriApp> createState() => _AzeriAppState();
}

class _AzeriAppState extends State<AzeriApp> {
  final AppState _appState = AppState();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _appState.startAutoRefresh(interval: const Duration(seconds: 30));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadLanguage();
      _loadAuthorization();
    });
  }

  Future<void> _loadLanguage() async {
    final saved = await AppPreferences.getLanguage();
    if (!mounted) return;
    if (saved != null) {
      _appState.setLocale(Locale(saved));
    }
  }

  Future<void> _loadAuthorization() async {
    final authorized = await AppPreferences.getAuthorized();
    final customerId = await AppPreferences.getCustomerId();
    final hasCustomer = customerId != null && customerId > 0;
    if (!authorized && hasCustomer) {
      _appState.setAuthorized(true);
    } else {
      _appState.setAuthorized(authorized);
    }
    if (!hasCustomer) return;
    await _appState.loadCustomerBundle(customerId);
  }


  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      appState: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          return MaterialApp(
            title: 'Azeri',
            theme: AppTheme.light(),
            navigatorKey: _navigatorKey,
            builder: (context, child) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            locale: _appState.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
