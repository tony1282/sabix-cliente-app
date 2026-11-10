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
El futuro workflow deberá crear este archivo temporal desde el fixture.

## Alcance

- Validaciones: campos vacíos, correo incorrecto y válido, longitud de
  contraseña, confirmación, teléfono, nombre y usuario.
- Botón compartido: pulsación, bloqueo durante carga y ausencia de acción,
  tanto en su variante principal como con borde.

Se reemplaza la prueba inicial del contador porque no corresponde a Sabix.
Estas pruebas no arrancan MyApp ni requieren red, credenciales o almacenamiento
del dispositivo. No prueban login real, pedidos ni chat. Los componentes
probados no necesitan cargar dotenv en memoria; el fixture satisface el
recurso declarado por Flutter.

GitHub Actions y los avisos Slack/Trello quedan para un cambio posterior.
