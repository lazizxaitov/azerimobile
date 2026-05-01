import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';

import '../../routing/app_router.dart';
import '../../theme/app_gradients.dart';
import '../../widgets/app_bottom_nav_bar.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F3),
      body: SafeArea(
        top: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Container(
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
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 54,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.orderSuccessTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.orders,
                              (route) => false,
                            ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.goToOrder,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.home,
                              (route) => false,
                            ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.continueShopping,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedTab: AppBottomTab.menu,
        onMenuTap: () => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
        onProfileTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
      ),
    );
  }
}
