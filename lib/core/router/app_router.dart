import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_order_app/features/menu/presentation/menu_list_screen.dart';
import 'package:mobile_order_app/features/menu/presentation/customization_screen.dart';
import 'package:mobile_order_app/features/menu/presentation/option_management_screen.dart';
import 'package:mobile_order_app/features/order/presentation/cart_screen.dart';
import 'package:mobile_order_app/features/order/presentation/order_success_screen.dart';
import 'package:mobile_order_app/features/order/presentation/order_history_screen.dart';
import 'package:mobile_order_app/features/order/presentation/order_management_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          final token = state.uri.queryParameters['t'];
          return MenuListScreen(token: token);
        },
      ),
      GoRoute(
        path: '/customization',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return CustomizationScreen(
            itemName: extras['name'] as String,
            imageUrl: extras['imageUrl'] as String,
            price: extras['price'] as int,
            category: extras['category'] as String,
          );
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/order-success',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return OrderSuccessScreen(
            orderId: extras['orderId'] as String,
            orderNumber: extras['orderNumber'] as int,
            paymentMethod: extras['paymentMethod'] as String,
          );
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      // スタッフ用隠しルート (デモ目的)
      GoRoute(
        path: '/staff-management',
        builder: (context, state) => const OrderManagementScreen(),
      ),
      GoRoute(
        path: '/option-management',
        builder: (context, state) => const OptionManagementScreen(),
      ),
    ],
  );
}
