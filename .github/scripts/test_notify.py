import contextlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('notify', Path(__file__).with_name('notify.py'))
notify = importlib.util.module_from_spec(spec)
spec.loader.exec_module(notify)


class NotifyTests(unittest.TestCase):
    def setUp(self):
        self.env = {
            'GITHUB_REPOSITORY': 'tony1282/sabix-cliente-app',
            'GITHUB_EVENT_NAME': 'pull_request', 'GH_TOKEN': 'dummy-github-token',
            'GITHUB_SHA': 'a' * 40, 'GITHUB_REF_NAME': 'test/ci',
            'GITHUB_RUN_ID': '123', 'CI_RESULT': 'failure',
            'ANALYZE_RESULT': 'failure', 'TEST_RESULT': 'success',
            'TRELLO_BOARD': 'wmXiYYHQ', 'TRELLO_API_KEY': 'dummy-key',
            'TRELLO_API_TOKEN': 'dummy-token',
            'SLACK_WEBHOOK_URL': 'https://hooks.slack.com/services/dummy/test/value',
        }
        self.pr = {'number': 25, 'body': 'Trello: https://trello.com/c/AbCd1234/tarea',
                   'head': {'ref': 'test/ci', 'sha': 'b' * 40}}

    def test_explicit_card_reference_only(self):
        self.assertEqual(notify.card_link(self.pr['body']), 'AbCd1234')
        for text in ['https://trello.com/c/AbCd1234',
                     'Trello: https://evil.example/c/AbCd1234',
                     'Trello: https://trello.com/b/wmXiYYHQ',
                     'Trello: https://trello.com/c/AbCd12345', None]:
            self.assertIsNone(notify.card_link(text))

    def test_multiple_cards_rejected(self):
        with self.assertRaises(notify.IntegrationError):
            notify.card_link(self.pr['body'] + '\nTrello: https://trello.com/c/ZyXw9876')

    def test_pr_uses_head_commit_and_card(self):
        result = notify.context(self.env, {'pull_request': self.pr})
        self.assertEqual(result, {'branch': 'test/ci', 'sha': 'b' * 40,
                                 'pr': 25, 'card': 'AbCd1234'})

    def test_push_open_pr_avoids_duplicate_messages(self):
        self.env['GITHUB_EVENT_NAME'] = 'push'
        pr = dict(self.pr, state='open', head={'sha': 'a' * 40})
        self.assertIsNone(notify.context(self.env, {}, lambda *a, **k: [pr]))

    def test_push_uses_commit_reference_without_pr(self):
        self.env['GITHUB_EVENT_NAME'] = 'push'
        result = notify.context(self.env, {'head_commit': {'message': self.pr['body']}},
                                lambda *a, **k: [])
        self.assertEqual(result['card'], 'AbCd1234')

    def test_merged_pr_connects_production_push_to_card(self):
        self.env['GITHUB_EVENT_NAME'] = 'push'
        merged = dict(self.pr, state='closed', merged_at='2026-11-10')
        result = notify.context(self.env, {}, lambda *a, **k: [merged])
        self.assertEqual(result['pr'], 25)
        self.assertEqual(result['card'], 'AbCd1234')

    def test_deleted_branch_never_sends_notifications(self):
        self.env['GITHUB_EVENT_NAME'] = 'push'
        self.assertIsNone(notify.context(
            self.env, {'deleted': True, 'head_commit': None},
            lambda *a, **k: self.fail('Network called for deleted branch'),
        ))

    def test_slack_payload_reports_both_checks_as_plain_text(self):
        captured = []
        text = notify.result_text(self.env, notify.context(self.env, {'pull_request': self.pr}))
        def call(url, **kwargs):
            captured.append(kwargs['payload'])
            return 'ok'
        notify.send_slack(self.env, text, call)
        section = captured[0]['blocks'][0]['text']
        self.assertEqual(section['type'], 'plain_text')
        self.assertIn('flutter analyze: failure', section['text'])
        self.assertIn('flutter test: success', section['text'])
        self.assertIn('/actions/runs/123', section['text'])

    def test_bad_slack_destination_never_receives_secret(self):
        self.env['SLACK_WEBHOOK_URL'] = 'https://evil.example/services/token'
        with self.assertRaises(notify.IntegrationError):
            notify.send_slack(self.env, 'test', lambda *a, **k: self.fail('Network called'))

    def test_trello_checks_board_and_posts_comment_with_header_auth(self):
        calls = []
        def call(url, **kwargs):
            calls.append((url, kwargs))
            if '/boards/' in url:
                return {'id': 'sabix-board-id'}
            if kwargs.get('method') != 'POST':
                return {'idBoard': 'sabix-board-id'}
            return {'id': 'comment-id'}
        notify.send_trello(self.env, 'AbCd1234', 'CI failure', call)
        url, params = calls[-1]
        self.assertTrue(url.endswith('/cards/AbCd1234/actions/comments'))
        self.assertEqual(params['payload'], {'text': 'CI failure'})
        self.assertIn('oauth_token="dummy-token"', params['headers']['Authorization'])
        self.assertNotIn('dummy-token', url)

    def test_card_from_other_board_is_not_modified(self):
        def call(url, **kwargs):
            self.assertNotEqual(kwargs.get('method'), 'POST')
            return {'id': 'sabix'} if '/boards/' in url else {'idBoard': 'other-board'}
        with self.assertRaises(notify.IntegrationError):
            notify.send_trello(self.env, 'AbCd1234', 'result', call)

    def test_slack_failure_does_not_prevent_trello_comment(self):
        calls = []
        def call(url, **kwargs):
            calls.append(url)
            if url.startswith('https://hooks.slack.com/'):
                raise notify.IntegrationError('HTTP 403; revisar permisos y credenciales.')
            if '/boards/' in url:
                return {'id': 'sabix'}
            return {'idBoard': 'sabix'}
        with tempfile.TemporaryDirectory() as temp:
            event = Path(temp) / 'event.json'
            event.write_text(json.dumps({'pull_request': self.pr}), encoding='utf-8')
            self.env['GITHUB_EVENT_PATH'] = str(event)
            with contextlib.redirect_stdout(io.StringIO()) as output:
                result = notify.main(self.env, call)
            self.assertEqual(result, 1)
            self.assertTrue(any(url.endswith('/actions/comments') for url in calls))
            self.assertNotIn('dummy-token', output.getvalue())

    def test_missing_secrets_are_reported_without_network(self):
        self.env['SLACK_WEBHOOK_URL'] = ''
        self.env['TRELLO_API_TOKEN'] = ''
        for action in [lambda: notify.send_slack(self.env, 'text'),
                       lambda: notify.send_trello(self.env, 'AbCd1234', 'text')]:
            with self.assertRaises(notify.IntegrationError):
                action()


if __name__ == '__main__':
    unittest.main()
