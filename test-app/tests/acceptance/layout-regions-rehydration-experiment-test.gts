// PROTOTYPE: layout regions. An experiment, not a behaviour test: it runs
// Glimmer's serialize builder (what a server render uses) over the regions
// demo, then rehydrates that HTML in a second application instance, and
// records what each step produced. It runs in the browser against the real
// DOM, so it measures Glimmer, not a server DOM implementation.
import { module, test } from 'qunit';
import { settled } from '@ember/test-helpers';
import { run } from '@ember/runloop';
import Application from 'test-app/app';
import config from 'test-app/config/environment';
import {
  mockMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';

function text(root: Element, selector: string): string {
  return ((root.querySelector(selector) as HTMLElement | null)?.innerText ?? '')
    .replace(/\s+/g, ' ')
    .trim();
}

async function boot(
  root: Element,
  renderMode: 'serialize' | 'rehydrate'
): Promise<{ destroy(): void; go(url: string): Promise<void> }> {
  const app = Application.create({ ...config.APP, autoboot: false });
  const instance = await app.visit('/regions-demo/orders/7', {
    rootElement: root,
    _renderMode: renderMode
  } as never);
  await settled();
  return {
    destroy: () => run(app, 'destroy'),
    go: async (url: string) => {
      await (
        instance.lookup('service:router') as {
          transitionTo(url: string): Promise<unknown>;
        }
      ).transitionTo(url);
      await settled();
    }
  };
}

module(
  'Acceptance | Experiment | regions serialize and rehydrate',
  function (hooks) {
    let media: MatchMediaMock | undefined;
    let roots: Element[] = [];

    hooks.beforeEach(function () {
      media = mockMatchMedia(1200);
    });

    hooks.afterEach(function () {
      media?.restore();
      roots.forEach((root) => root.remove());
      roots = [];
    });

    function makeRoot(): HTMLElement {
      const root = document.createElement('div');
      document.getElementById('ember-testing')!.append(root);
      roots.push(root);
      return root;
    }

    test('serialized HTML has the regions filled, and rehydration adopts it', async function (assert) {
      const server = makeRoot();
      const first = await boot(server, 'serialize');
      const html = server.innerHTML;
      assert.strictEqual(
        text(server, '[data-test-actions]'),
        'Refund order 7',
        'serialized: the navbar region shows the deepest route'
      );
      assert.notStrictEqual(
        getComputedStyle(server.querySelector('[data-part="aside-toggle"]')!)
          .display,
        'none',
        'serialized: the toggle is shown'
      );
      assert.true(html.includes('<!--%+b:'), 'the HTML has serialize markers');
      assert.true(
        server.querySelector('[data-region="actions"] > script[glmr]') !== null,
        'and an in-element marker inside the region'
      );
      first.destroy();
      server.remove();

      // The "browser" receives the HTML as text, with no script run yet.
      const client = makeRoot();
      client.innerHTML = html;
      assert.strictEqual(
        text(client, '[data-test-actions]'),
        'Refund order 7',
        'static HTML, before any script: region filled, parent source hidden'
      );
      assert.notStrictEqual(
        getComputedStyle(client.querySelector('[data-part="aside-toggle"]')!)
          .display,
        'none',
        'static HTML: the toggle is shown'
      );
      const serverButton = client.querySelector('[data-test-action="refund"]');
      const serverRegion = client.querySelector('[data-region="actions"]');
      const serverPage = client.querySelector('[data-test-page="order"]');

      const second = await boot(client, 'rehydrate');
      assert.strictEqual(
        text(client, '[data-test-actions]'),
        'Refund order 7',
        'rehydrated: still right'
      );
      assert.strictEqual(
        client.querySelectorAll('[data-test-action="refund"]').length,
        1,
        'rehydrated: the region content is not duplicated'
      );
      assert.strictEqual(
        client.querySelectorAll('[data-region="actions"]').length,
        1,
        'rehydrated: one region element'
      );
      assert.strictEqual(
        client.querySelector('[data-region="actions"]'),
        serverRegion,
        'rehydrated: the region element is the one from the server HTML'
      );
      assert.strictEqual(
        client.querySelector('[data-test-action="refund"]'),
        serverButton,
        'rehydrated: so is its content, adopted rather than rebuilt'
      );
      assert.strictEqual(
        client.querySelector('[data-test-page="order"]'),
        serverPage,
        'rehydrated: and the page'
      );
      await second.go('/regions-demo/orders');
      assert.strictEqual(
        text(client, '[data-test-actions]'),
        'New order',
        'rehydrated region content is live: it follows a route change'
      );
      second.destroy();
    });
  }
);
