# Pruebas de Sabix Cliente

Entorno de verificación: Flutter 3.44.6 / Dart 3.12.2.

## Preparación

`pubspec.yaml` declara `.env` como recurso. En una copia limpia dedicada a
pruebas, copiar `test/fixtures/env.test` a `.env` antes de ejecutar Flutter.
No sobrescribir el `.env` de desarrollo: usar otra copia del proyecto.
El archivo generado continúa excluido de Git.

PowerShell, desde la raíz del proyecto:

```powershell
if (-not (Test-Path .env)) { Copy-Item test/fixtures/env.test .env }
flutter pub get
flutter test
flutter analyze
```

La dirección `.invalid` es ficticia. No añadir tokens de Slack, Trello ni
credenciales de producción: `.env` se empaqueta con la aplicación.
El workflow crea este archivo temporal desde el fixture.

## Alcance

- Validaciones: campos vacíos, correo incorrecto y válido, longitud de
  contraseña, confirmación, teléfono, nombre y usuario.
- Botón compartido: pulsación, bloqueo durante carga y ausencia de acción,
  tanto en su variante principal como con borde.
- Pantalla real de Notificaciones con servicios simulados: apertura de pedido,
  tarjeta eliminada durante la espera, error al marcar todas y respuesta tardía
  después de abandonar la pantalla.

Se reemplaza la prueba inicial del contador porque no corresponde a Sabix.
Estas pruebas no arrancan MyApp ni requieren red, credenciales o almacenamiento
del dispositivo. La navegación de Notificaciones se prueba sin acceder al
servidor; no prueban login real, operaciones de pedidos ni chat. Los componentes
probados no necesitan cargar dotenv en memoria; el fixture satisface el
recurso declarado por Flutter.

La configuración de GitHub Actions y los avisos Slack/Trello se explica en
[devops.md](devops.md). Los secretos deben guardarse en GitHub para activar los envíos.
