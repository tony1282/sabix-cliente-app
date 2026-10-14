import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/cart_provider.dart';
import 'presentation/routes/app_routes.dart';
import 'core/providers/product_provider.dart';
import 'core/services/local_storage_service.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/providers/notification_provider.dart';
import 'package:sabix_cliente_app/core/providers/order_provider.dart';
import 'package:sabix_cliente_app/core/providers/chat_provider.dart';
import 'package:sabix_cliente_app/core/services/chat_service.dart';
import 'package:sabix_cliente_app/core/network/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.init();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()..loadCart()),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(ChatService(ApiClient())),
        ),
      ],
      child: MaterialApp.router(
        title: 'Sabix Cliente',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
