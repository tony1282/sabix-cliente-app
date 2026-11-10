import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabix_cliente_app/presentation/widgets/custom_button.dart';

void main() {
  for (final outlined in [false, true]) {
    group(outlined ? 'Botón con borde' : 'Botón principal', () {
      testWidgets('ejecuta la acción al pulsarlo', (tester) async {
        var presses = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                text: 'Iniciar Sesión',
                isOutlined: outlined,
                onPressed: () => presses++,
              ),
            ),
          ),
        );
        await tester.tap(find.text('Iniciar Sesión'));
        expect(presses, 1);
      });

      testWidgets('muestra carga e impide nuevas acciones', (tester) async {
        var presses = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                text: 'Iniciar Sesión',
                isOutlined: outlined,
                isLoading: true,
                onPressed: () => presses++,
              ),
            ),
          ),
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Iniciar Sesión'), findsNothing);
        await tester.tap(find.byType(CustomButton));
        expect(presses, 0);
      });

      testWidgets('permanece deshabilitado sin acción disponible', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                text: 'Continuar',
                isOutlined: outlined,
                onPressed: null,
              ),
            ),
          ),
        );
        final button = tester.widget<ButtonStyleButton>(
          find.byType(outlined ? OutlinedButton : ElevatedButton),
        );
        expect(button.enabled, isFalse);
      });
    });
  }
}
