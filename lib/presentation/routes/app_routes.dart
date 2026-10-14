import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../../core/providers/auth_provider.dart';
import '../screens/orders/orders_list_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/products/product_detail_screen.dart'; // ← NUEVO
import '../screens/chat/chat_screen.dart';
import '../screens/chat/chat_list_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String orderDetail = '/order/:id';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String productDetail = '/product-detail'; // ← NUEVO
  static const String chatList = '/chat-list';
  static const String chat = '/chat';

  static GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Públicas
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Privadas
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: orders,
        name: 'orders',
        builder: (context, state) => const OrdersListScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: orderDetail,
        name: 'orderDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrderDetailScreen(orderId: id);
        },
        redirect: _authGuard,
      ),
      GoRoute(
        path: cart,
        name: 'cart',
        builder: (context, state) => const CartScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        redirect: _authGuard,
      ),
      // ← NUEVA RUTA PARA DETALLE DE PRODUCTO
      GoRoute(
        path: productDetail,
        name: 'productDetail',
        builder: (context, state) {
          final product = state.extra as ProductModel?;
          if (product == null) {
            return const Scaffold(
              body: Center(child: Text('Producto no encontrado')),
            );
          }
          return ProductDetailScreen(product: product);
        },
        redirect: _authGuard,
      ),
      GoRoute(
        path: chatList,
        name: 'chatList',
        builder: (context, state) => const ChatListScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: chat,
        name: 'chat',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            return const Scaffold(
              body: Center(child: Text('Conversación no encontrada')),
            );
          }
          return ChatScreen(
            conversationId: extra['conversationId'].toString(),
            orderId: extra['orderId'].toString(),
            title: extra['title'].toString(),
            jwtToken: extra['jwtToken'].toString(),
          );
        },
        redirect: _authGuard,
      ),
    ],
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isGoingToAuth = state.matchedLocation == login ||
          state.matchedLocation == register ||
          state.matchedLocation == splash;

      if (!authProvider.isAuthenticated && !isGoingToAuth) {
        return login;
      }
      return null;
    },
  );

  static String? _authGuard(BuildContext context, GoRouterState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      return login;
    }
    return null;
  }
}

// Extensiones de navegación (agregar productDetail)
extension GoRouterExtension on GoRouter {
  void goToLogin() => go(AppRouter.login);
  void goToRegister() => go(AppRouter.register);
  void goToHome() => go(AppRouter.home);
  void goToOrders() => go(AppRouter.orders);
  void goToOrderDetail(String id) => go('/order/$id');
  void goToCart() => go(AppRouter.cart);
  void goToProfile() => go(AppRouter.profile);
  void goToProductDetail(ProductModel product) => // ← NUEVO
      push(AppRouter.productDetail, extra: product);
  void goToChatList() => push(AppRouter.chatList);
  void goToChat(Map<String, dynamic> extra) => push(AppRouter.chat, extra: extra);
  void goBack() => pop();
}

extension BuildContextGoRouterExtension on BuildContext {
  void goToLogin() => go(AppRouter.login);
  void goToRegister() => go(AppRouter.register);
  void goToHome() => go(AppRouter.home);
  void goToOrders() => go(AppRouter.orders);
  void goToOrderDetail(String id) => go('/order/$id');
  void goToCart() => go(AppRouter.cart);
  void goToProfile() => go(AppRouter.profile);
  void goToProductDetail(ProductModel product) => // ← NUEVO
      push(AppRouter.productDetail, extra: product);
  void goToChatList() => push(AppRouter.chatList);
  void goToChat(Map<String, dynamic> extra) => push(AppRouter.chat, extra: extra);
}