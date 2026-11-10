# GitHub Actions y avisos de Sabix Cliente

## Qué ejecuta

`.github/workflows/flutter-ci.yml` comprueba cada push y pull request, incluso
si está en borrador, con Flutter 3.44.6. Crea `.env` desde el fixture ficticio,
resuelve dependencias y ejecuta `flutter analyze` y `flutter test`.
Las pruebas se ejecutan aunque falle el análisis. Un fallo en cualquiera
mantiene el job de comprobaciones en rojo; no se ocultan los avisos existentes.

Un segundo job publica el resultado de ambos comandos, rama, commit, PR
cuando corresponde y enlace a la ejecución en Slack y como comentario Trello.
Se comprueban también los fallos de instalación o dependencias: los comandos
que no llegaron a ejecutarse aparecen como `skipped`.

Los avisos no despliegan la app ni vigilan errores de usuarios en producción.
Un push a main verifica ese código, con el mismo fixture de pruebas. No genera
una compilación de producción ni cambia el .env de las computadoras del equipo.

## Activar las conexiones

En GitHub: **Settings → Secrets and variables → Actions → New repository secret**.
No introducir estos valores en Flutter, en archivos del repositorio o en el PR.

| Nombre exacto | Valor que guarda el propietario |
| --- | --- |
| `SLACK_WEBHOOK_URL` | Webhook del canal elegido en Carlos Alberto Hernandez Rivera |
| `TRELLO_API_KEY` | API key de la aplicación de Trello |
| `TRELLO_API_TOKEN` | Token Trello con lectura y escritura para comentar tarjetas |

### Slack

1. Abrir https://api.slack.com/apps y seleccionar o crear la app de Sabix
   en el espacio **Carlos Alberto Hernandez Rivera**.
2. Activar **Incoming Webhooks** y elegir **Add New Webhook to Workspace**.
3. Seleccionar el canal acordado (por ejemplo `#desarrollo`) y autorizarlo.
4. Copiar la URL directamente al secreto `SLACK_WEBHOOK_URL` en GitHub.

El webhook determina el canal; no se usa un nombre de canal configurable en
el código. La conexión de Trello a Slack ya existente no crea automáticamente
este webhook para GitHub. Si faltan permisos, el administrador debe autorizarlo.

### Trello

1. Abrir https://trello.com/apps/admin y seleccionar o crear la aplicación
   de Sabix. En **Trello Auth**, obtener la API key.
2. Generar un token para la cuenta que puede acceder a SABIX_Delivery con
   permisos `read,write`. Elegir su vigencia y renovar el secreto al caducar.
3. Guardar key y token por separado en los secretos indicados.

Los permisos del token aplican a la cuenta: no equivale a un token limitado
a un solo tablero. El script comprueba que cada tarjeta pertenezca a
SABIX_Delivery (`wmXiYYHQ`) antes de escribir. No usa recursos de Academix.

Guías oficiales:
- https://docs.slack.dev/messaging/sending-messages-using-incoming-webhooks/
- https://developer.atlassian.com/cloud/trello/guides/rest-api/authorization/

## Asociar una tarjeta

En la descripción de cada PR, escribir una línea con su enlace real:

```text
Trello: https://trello.com/c/XXXXXXXX/nombre-de-la-tarjeta
```

`XXXXXXXX` es el código de ocho caracteres del enlace, no un ID del tablero.
Usar una sola tarjeta por PR. La plantilla de PR recuerda esta asociación.
Al editar la descripción se vuelven a ejecutar las comprobaciones y los avisos.

Para un push sin PR, incluir esa misma línea en el mensaje del último commit
del push. Tras integrar un PR, se recupera su tarjeta desde GitHub.
Si no hay asociación, Slack sí recibe el resultado y Trello se omite con un
aviso visible: no se adivina una tarjeta ni se crea una por cada ejecución.
Si el push ya tiene un PR abierto para ese commit, sus avisos se delegan al
evento pull_request para evitar el duplicado habitual. Las reejecuciones
manuales y las ediciones del PR pueden volver a enviar avisos.

## Secretos y permisos

- Las pruebas no reciben secretos de Slack/Trello.
- Los PR desde forks ejecutan las comprobaciones pero no el job de avisos.
- Las ramas y PR dentro de este repositorio se consideran del equipo con
  acceso de escritura; revisar quién tiene esos permisos.
- El job de avisos usa un token GitHub de solo lectura, no descarga artefactos
  de pruebas y no ejecuta el código Flutter.
- Slack usa texto plano para no convertir nombres de ramas en menciones.
- El script no imprime credenciales ni respuestas que pudieran contenerlas;
  rechaza redirecciones para evitar reenviar encabezados de autenticación.
- Un fallo de Slack no impide intentar Trello, y viceversa. El job queda en
  rojo si falla un envío o falta su secreto; no presenta el envío como exitoso.

## Verificación y estado de esta rama

1. Guardar los tres secretos.
2. Asociar una tarjeta real a la descripción del PR #25.
3. Revisar **Actions → Sabix Flutter CI** o las comprobaciones del PR.
4. Confirmar el mensaje de Slack y el comentario en la tarjeta asociada.

El workflow puede ejecutarse desde esta rama sin integrarla a main mediante
push o pull_request. Se omiten los eventos de eliminación de ramas. Para
verificar un cambio es necesario que la rama siga existiendo.

La ejecución se inicia mediante
el evento push o pull_request. El botón **Run workflow** puede no aparecer
hasta que el archivo exista en la rama predeterminada; no hace falta integrar
para probarlo. Mientras permanezca solo en esta rama no protege todos los
cambios de main ni se instala automáticamente en otras ramas antiguas.

El análisis inicial detectó 100 avisos existentes (8 warnings y 92 info), por
lo que el estado rojo de analyze es esperado hasta corregirlos en otro cambio.
Las 32 pruebas Flutter pasaron localmente en el cambio anterior.

Pruebas locales del envío, sin red ni credenciales reales:

```text
python -m unittest discover -s .github/scripts -p test_notify.py -v
```
