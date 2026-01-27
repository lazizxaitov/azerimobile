import 'package:flutter/material.dart';
import 'package:azeri/l10n/app_localizations.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/catalog/category_products_screen.dart';
import '../screens/catalog/product_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/orders/order_success_screen.dart';
import '../screens/profile/addresses_screen.dart';
import '../screens/profile/bonuses_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../models/category_args.dart';

final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const category = '/category';
  static const product = '/product';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const orderDetail = '/order-detail';
  static const orderSuccess = '/order-success';
  static const profile = '/profile';
  static const addresses = '/addresses';
  static const bonuses = '/bonuses';
  static const settings = '/settings';
}

final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute<void>(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute<void>(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute<void>(builder: (_) => const RegisterScreen());
      case AppRoutes.home:
        return MaterialPageRoute<void>(builder: (_) => const HomeScreen());
      case AppRoutes.category:
        final args = switch (settings.arguments) {
          final CategoryArgs c => c,
          final String s when s.trim().isNotEmpty => CategoryArgs(
            id: 0,
            title: s,
          ),
          _ => const CategoryArgs(id: 0, title: ''),
        };
        return MaterialPageRoute<void>(
          builder: (_) => CategoryProductsScreen(args: args),
        );
      case AppRoutes.product:
        return MaterialPageRoute<void>(
          builder: (_) => ProductScreen(args: settings.arguments),
        );
      case AppRoutes.cart:
        return MaterialPageRoute<void>(builder: (_) => const CartScreen());
      case AppRoutes.checkout:
        return MaterialPageRoute<void>(builder: (_) => const CheckoutScreen());
      case AppRoutes.orders:
        return MaterialPageRoute<void>(builder: (_) => const OrdersScreen());
      case AppRoutes.orderDetail:
        return MaterialPageRoute<void>(
          builder: (_) => OrderDetailScreen(order: settings.arguments),
        );
      case AppRoutes.orderSuccess:
        return MaterialPageRoute<void>(
          builder: (_) => const OrderSuccessScreen(),
        );
      case AppRoutes.profile:
        return MaterialPageRoute<void>(builder: (_) => const ProfileScreen());
      case AppRoutes.addresses:
        return MaterialPageRoute<void>(builder: (_) => const AddressesScreen());
      case AppRoutes.bonuses:
        return MaterialPageRoute<void>(builder: (_) => const BonusesScreen());
      case AppRoutes.settings:
        return MaterialPageRoute<void>(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute<void>(
          builder: (_) => _UnknownRouteScreen(routeName: settings.name),
        );
    }
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen({required this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Azeri')),
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.unknownRoute(
            routeName ?? '(null)',
          ),
        ),
      ),
    );
  }
}
