import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sabix_cliente_app/core/providers/auth_provider.dart';
import 'package:sabix_cliente_app/core/providers/notification_provider.dart';
import 'package:sabix_cliente_app/models/notification_model.dart';
import 'package:sabix_cliente_app/models/user_model.dart';
import 'package:sabix_cliente_app/presentation/screens/notifications/notifications_screen.dart';

// Sustituye únicamente servicios externos; se renderiza la pantalla real.
class _Auth extends ChangeNotifier implements AuthProvider {
  @override
  UserModel? get currentUser => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Notifications extends ChangeNotifier implements NotificationProvider {
  late final markRead = Completer<bool>();
  late final markAll = Completer<bool>();
  bool visible = true;
  static const item = NotificationModel(
    id: 1,
    orderId: 42,
    type: 'order_created',
    typeDisplay: 'Pedido',
    title: 'Pedido actualizado',
    message: 'Tu pedido está listo',
  );

  @override
  List<NotificationModel> get notifications => visible ? [item] : [];
  @override
  bool get hasUnread => visible;
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  Future<void> refresh() async {}
  @override
  Future<bool> markAsRead(int id) => markRead.future;
  @override
  Future<bool> markAllAsRead() => markAll.future;

  void removeItem() {
    visible = false;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Auth auth;
  late _Notifications notifications;
  late GoRouter router;

  setUp(() {
    auth = _Auth();
    notifications = _Notifications();
    router = GoRouter(
      initialLocation: '/notifications',
      routes: [
        GoRoute(
          path: '/notifications',
          builder: (_, _) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/order/:id',
          builder: (_, state) =>
              Scaffold(body: Text('Pedido ${state.pathParameters['id']}')),
        ),
      ],
    );
  });

  tearDown(() {
    router.dispose();
    notifications.dispose();
    auth.dispose();
  });

  Future<void> showScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<NotificationProvider>.value(
            value: notifications,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('abre el pedido después de marcar la notificación', (
    tester,
  ) async {
    await showScreen(tester);
    await tester.tap(find.text('Pedido actualizado'));
    notifications.markRead.complete(true);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Pedido 42'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no navega con el contexto de una tarjeta que desapareció', (
    tester,
  ) async {
    await showScreen(tester);
    await tester.tap(find.text('Pedido actualizado'));
    notifications.removeItem();
    await tester.pumpAndSettle();
    expect(find.text('Sin notificaciones'), findsOneWidget);
    notifications.markRead.complete(true);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Pedido 42'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra el error al fallar marcar todas como leídas', (
    tester,
  ) async {
    await showScreen(tester);
    await tester.tap(find.byTooltip('Marcar todas como leídas'));
    notifications.markAll.complete(false);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudieron marcar las notificaciones como leídas'),
      findsOneWidget,
    );
  });

  testWidgets('ignora una respuesta al salir de la pantalla', (tester) async {
    await showScreen(tester);
    await tester.tap(find.byTooltip('Marcar todas como leídas'));
    router.go('/order/42');
    await tester.pumpAndSettle();
    notifications.markAll.complete(false);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Pedido 42'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
