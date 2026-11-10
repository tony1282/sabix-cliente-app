"""Publica resultados de CI. Credenciales solo en variables de entorno.

No ejecuta contenido de commits/PR ni descarga artefactos del job de pruebas.
"""

import json
import os
from pathlib import Path
import re
import sys
from urllib.error import HTTPError, URLError
from urllib.parse import quote, urlparse
from urllib.request import HTTPRedirectHandler, Request, build_opener


class IntegrationError(Exception):
    """Error seguro para el registro; nunca incluye URLs ni respuestas secretas."""


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def request(url, *, method='GET', headers=None, payload=None, plain=False):
    data = None if payload is None else json.dumps(payload).encode('utf-8')
    req = Request(url, data=data, method=method, headers={
        'Content-Type': 'application/json', **(headers or {}),
    })
    try:
        with build_opener(NoRedirect).open(req, timeout=25) as response:
            text = response.read().decode('utf-8')
        return text if plain else json.loads(text)
    except HTTPError as error:
        raise IntegrationError(f'HTTP {error.code}; revisar permisos y credenciales.') from None
    except (URLError, TimeoutError, ValueError, OSError):
        raise IntegrationError('Error de conexión o respuesta no válida.') from None


def card_link(text):
    """Exige una referencia explícita; no interpreta enlaces arbitrarios como tareas."""
    links = re.findall(
        r'^\s*Trello:\s*https://trello\.com/c/([A-Za-z0-9]{8})(?=[/\s)]|$)',
        text or '', re.MULTILINE | re.IGNORECASE,
    )
    unique = list(dict.fromkeys(links))
    if len(unique) > 1:
        raise IntegrationError('Usar una sola línea Trello: con una tarjeta por PR o commit.')
    return unique[0] if unique else None


def context(env, event, call=request):
    if event.get('deleted'):
        return None
    repo = env['GITHUB_REPOSITORY']
    github_headers = {
        'Authorization': f'Bearer {env["GH_TOKEN"]}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
    }
    if env['GITHUB_EVENT_NAME'] == 'pull_request':
        pr = event['pull_request']
        return {
            'branch': pr['head']['ref'], 'sha': pr['head']['sha'],
            'pr': pr['number'], 'card': card_link(pr.get('body')),
        }
    sha = env['GITHUB_SHA']
    prs = call(
        f'https://api.github.com/repos/{repo}/commits/{sha}/pulls?per_page=100',
        headers=github_headers,
    )
    # Un push de una rama con PR abierto ya tendrá su propio evento PR.
    open_prs = [pr for pr in prs if pr['state'] == 'open'
                and pr['head']['sha'] == sha]
    if env['GITHUB_EVENT_NAME'] == 'push' and open_prs:
        return None
    merged = [pr for pr in prs if pr.get('merged_at')]
    cards = [card_link(pr.get('body')) for pr in merged]
    cards = list(dict.fromkeys(card for card in cards if card))
    if len(cards) > 1:
        raise IntegrationError('El commit está asociado a varias tarjetas; revisar su asociación.')
    message = (event.get('head_commit') or {}).get('message', '')
    return {
        'branch': env['GITHUB_REF_NAME'], 'sha': sha,
        'pr': merged[0]['number'] if merged else None,
        'card': cards[0] if cards else card_link(message),
    }


def result_text(env, ctx):
    result = env.get('CI_RESULT', 'unknown')
    run = (f'https://github.com/{env["GITHUB_REPOSITORY"]}/actions/runs/'
           f'{env["GITHUB_RUN_ID"]}')
    pr = f' | PR #{ctx["pr"]}' if ctx['pr'] else ''
    # Texto plano: evita menciones y formato aportados por nombres de ramas.
    branch = re.sub(r'[\r\n]', ' ', ctx['branch'])[:180]
    return (f'Sabix Cliente — CI: {result}\n'
            f'Rama: {branch}{pr} | Commit: {ctx["sha"][:12]}\n'
            f'flutter analyze: {env.get("ANALYZE_RESULT") or "skipped"}\n'
            f'flutter test: {env.get("TEST_RESULT") or "skipped"}\n'
            f'{run}')


def send_slack(env, text, call=request):
    webhook = env.get('SLACK_WEBHOOK_URL', '')
    parsed = urlparse(webhook)
    if (parsed.scheme != 'https' or parsed.netloc != 'hooks.slack.com'
            or not parsed.path.startswith('/services/') or parsed.query or parsed.fragment):
        raise IntegrationError('Falta SLACK_WEBHOOK_URL o no es un webhook válido de Slack.')
    payload = {
        'text': 'Resultado de CI de Sabix Cliente',
        'blocks': [{'type': 'section', 'text': {'type': 'plain_text', 'text': text}}],
        'unfurl_links': False, 'unfurl_media': False,
    }
    if call(webhook, method='POST', payload=payload, plain=True).strip() != 'ok':
        raise IntegrationError('Slack no confirmó el envío.')


def send_trello(env, card, text, call=request):
    key, token = env.get('TRELLO_API_KEY', ''), env.get('TRELLO_API_TOKEN', '')
    if not key or not token:
        raise IntegrationError('Faltan TRELLO_API_KEY o TRELLO_API_TOKEN.')
    # Los secretos viajan en encabezados, nunca en URLs o registros.
    headers = {'Authorization':
               f'OAuth oauth_consumer_key="{quote(key, safe="")}", oauth_token="{quote(token, safe="")}"'}
    base = 'https://api.trello.com/1'
    board = call(f'{base}/boards/{env["TRELLO_BOARD"]}?fields=id', headers=headers)
    task = call(f'{base}/cards/{card}?fields=idBoard', headers=headers)
    if task['idBoard'] != board['id']:
        raise IntegrationError('La tarjeta no pertenece al tablero SABIX_Delivery; envío bloqueado.')
    call(f'{base}/cards/{card}/actions/comments', method='POST',
         headers=headers, payload={'text': text})


def main(env=None, call=request):
    env = os.environ if env is None else env
    summary = []
    failures = 0
    try:
        event = json.loads(Path(env['GITHUB_EVENT_PATH']).read_text(encoding='utf-8'))
        ctx = context(env, event, call)
    except (IntegrationError, KeyError, ValueError, OSError):
        print('::error::No se pudo determinar la asociación del evento; no se enviaron avisos.')
        return 1
    if ctx is None:
        print('Evento omitido: rama eliminada o push con PR abierto que tendrá sus propios avisos.')
        return 0
    text = result_text(env, ctx)
    for name, send in [
        ('Slack', lambda: send_slack(env, text, call)),
        ('Trello', lambda: send_trello(env, ctx['card'], text, call)),
    ]:
        if name == 'Trello' and not ctx['card']:
            summary.append('Trello: omitido; falta la línea Trello: con el enlace de una tarjeta.')
            print('::notice::' + summary[-1])
            continue
        try:
            send()
            summary.append(f'{name}: envío confirmado.')
        except IntegrationError as error:
            failures += 1
            summary.append(f'{name}: {error}')
            print('::error::' + summary[-1])
    if env.get('GITHUB_STEP_SUMMARY'):
        with open(env['GITHUB_STEP_SUMMARY'], 'a', encoding='utf-8') as output:
            output.write('## Avisos de CI\n\n' + '\n'.join(f'- {s}' for s in summary) + '\n')
    return int(failures > 0)


if __name__ == '__main__':
    sys.exit(main())
