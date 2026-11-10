import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, find, findAll, render, waitUntil } from '@ember/test-helpers';
import { array, hash } from '@ember/helper';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchSwatch from 'test-app/components/workbench/swatch';
import { parseColor } from 'test-app/utils/workbench/color';

function el(selector: string): Element {
  const found = find(selector);
  if (!found) {
    throw new Error(`No element matches ${selector}`);
  }
  return found;
}

function fill(selector: string): string {
  return getComputedStyle(el(`${selector} [data-swatch-fill]`)).backgroundColor;
}

function text(selector: string): string {
  return (el(selector).textContent ?? '').trim();
}

module('Integration | workbench | primitives', function (hooks) {
  setupRenderingTest(hooks);

  let originalUrl: string;
  let hadDark: boolean;
  hooks.beforeEach(function () {
    originalUrl = window.location.href;
    hadDark = document.documentElement.classList.contains('dark');
  });
  hooks.afterEach(function () {
    window.history.replaceState(window.history.state, '', originalUrl);
    document.documentElement.classList.toggle('dark', hadDark);
  });

  module('card', function () {
    test('card renders chips that link to sections', async function (assert) {
      await render(
        <template>
          <WorkbenchCard
            @id="c"
            @title="Card title"
            @description="Card description"
            @sections={{array
              (hash id="a" label="Alpha")
              (hash id="b" label="Beta")
            }}
          >
            <p data-test-body>Body</p>
          </WorkbenchCard>
        </template>
      );

      assert.dom('[data-workbench-card]').hasAttribute('id', 'c');
      assert.dom('[data-workbench-card]').containsText('Card title');
      assert.dom('[data-workbench-card]').containsText('Card description');
      assert.dom('[data-workbench-card] [data-test-body]').exists();
      assert.deepEqual(
        findAll('[data-workbench-card] [data-workbench-chip]').map((a) => [
          a.getAttribute('href'),
          (a.textContent ?? '').trim()
        ]),
        [
          ['#c-a', 'Alpha'],
          ['#c-b', 'Beta']
        ]
      );
    });

    test('copy link writes the card URL', async function (assert) {
      const clipboard = navigator.clipboard;
      const written: string[] = [];
      Object.defineProperty(clipboard, 'writeText', {
        configurable: true,
        value: (value: string) => {
          written.push(value);
          return Promise.resolve();
        }
      });

      try {
        await render(
          <template>
            <WorkbenchCard
              @id="c"
              @title="T"
              @description="D"
              @sections={{array}}
            />
          </template>
        );
        await click('[data-workbench-copy-link]');

        assert.strictEqual(written.length, 1, 'wrote once');
        assert.ok(
          written[0]?.endsWith('#c'),
          `URL ends #c (got ${written[0]})`
        );
        assert.ok(
          written[0]?.startsWith(window.location.origin),
          'URL is absolute'
        );
        assert.dom('[data-workbench-copy-fallback]').doesNotExist();
      } finally {
        delete (clipboard as unknown as Record<string, unknown>)['writeText'];
      }
    });

    test('copy link falls back when the clipboard rejects', async function (assert) {
      const clipboard = navigator.clipboard;
      Object.defineProperty(clipboard, 'writeText', {
        configurable: true,
        value: () => Promise.reject(new Error('denied'))
      });

      try {
        await render(
          <template>
            <WorkbenchCard
              @id="c"
              @title="T"
              @description="D"
              @sections={{array}}
            />
          </template>
        );
        await click('[data-workbench-copy-link]');
        await waitUntil(() => find('[data-workbench-copy-fallback]'), {
          timeout: 2000
        });

        const input = el('[data-workbench-copy-fallback]') as HTMLInputElement;
        assert.ok(input.value.endsWith('#c'), `shows the URL (${input.value})`);
        assert.strictEqual(document.activeElement, input, 'input is focused');
        assert.strictEqual(input.selectionStart, 0, 'selection starts at 0');
        assert.strictEqual(
          input.selectionEnd,
          input.value.length,
          'whole URL is selected'
        );
      } finally {
        delete (clipboard as unknown as Record<string, unknown>)['writeText'];
      }
    });
  });

  module('section', function () {
    test('section opens on matching hash', async function (assert) {
      window.history.replaceState(window.history.state, '', '#s1');

      await render(
        <template>
          <WorkbenchSection @id="s1" @title="One" @open={{false}}>
            <p>content</p>
          </WorkbenchSection>
          <WorkbenchSection @id="s2" @title="Two" @open={{false}}>
            <p>content</p>
          </WorkbenchSection>
        </template>
      );

      assert.dom('details#s1').hasTagName('details');
      assert.dom('details#s1').hasAttribute('open', '', 'matching hash opens');
      assert
        .dom('details#s2')
        .doesNotHaveAttribute('open', 'others stay closed');
      assert.dom('details#s1 summary').containsText('One');
    });

    test('section opens when the hash changes to it', async function (assert) {
      await render(
        <template>
          <WorkbenchSection
            @id="s2"
            @title="Two"
            @subtitle="Sub"
            @open={{false}}
          >
            <p>content</p>
          </WorkbenchSection>
        </template>
      );
      assert.dom('details#s2').doesNotHaveAttribute('open');
      assert.dom('details#s2 summary').containsText('Sub');

      window.location.hash = '#s2';
      await waitUntil(() => (find('details#s2') as HTMLDetailsElement).open, {
        timeout: 2000
      });
      assert.dom('details#s2').hasAttribute('open');
    });

    test('section is open by default', async function (assert) {
      await render(
        <template>
          <WorkbenchSection @id="s3" @title="Three"><p
            >content</p></WorkbenchSection>
        </template>
      );
      assert.dom('details#s3').hasAttribute('open');
    });
  });

  module('panes', function () {
    test('panes render captions and yield the scheme', async function (assert) {
      await render(
        <template>
          <WorkbenchPanes @inverse={{true}} as |scheme|>
            <span data-test-scheme>{{scheme}}</span>
          </WorkbenchPanes>
        </template>
      );

      assert.deepEqual(
        findAll('[data-test-scheme]').map((e) => e.textContent),
        ['light', 'dark', 'inverse']
      );
      assert.dom('[data-workbench-pane="light"]').hasClass('light');
      assert.dom('[data-workbench-pane="dark"]').hasClass('dark');
      assert
        .dom('.light > .theme-inverse [data-test-scheme]')
        .hasText('inverse');
      assert.strictEqual(
        text('[data-workbench-pane="light"] [data-pane-caption]'),
        'LIGHT'
      );
      assert.strictEqual(
        text('[data-workbench-pane="dark"] [data-pane-caption]'),
        'DARK'
      );
      assert.strictEqual(
        text('[data-workbench-pane="inverse"] [data-pane-caption]'),
        'INVERSE'
      );
    });

    test('panes omit inverse unless asked', async function (assert) {
      await render(
        <template>
          <WorkbenchPanes as |scheme|><span
              data-test-scheme
            >{{scheme}}</span></WorkbenchPanes>
        </template>
      );
      assert.deepEqual(
        findAll('[data-test-scheme]').map((e) => e.textContent),
        ['light', 'dark']
      );
    });

    test('panes keep light under a dark root', async function (assert) {
      document.documentElement.classList.add('dark');

      await render(
        <template>
          <WorkbenchPanes @inverse={{true}} as |scheme|>
            <WorkbenchSwatch
              @token="primary-mild"
              data-test-swatch={{scheme}}
            />
          </WorkbenchPanes>
          <div class="light">
            <WorkbenchSwatch @token="primary-mild" data-test-ref-light />
          </div>
          <div class="dark">
            <WorkbenchSwatch @token="primary-mild" data-test-ref-dark />
          </div>
        </template>
      );

      const light = fill('[data-test-swatch="light"]');
      const dark = fill('[data-test-swatch="dark"]');

      assert.strictEqual(
        light,
        fill('[data-test-ref-light]'),
        'LIGHT pane is light'
      );
      assert.notStrictEqual(light, dark, 'LIGHT and DARK panes differ');
      assert.strictEqual(
        dark,
        fill('[data-test-ref-dark]'),
        'DARK pane is dark'
      );
      assert.strictEqual(
        fill('[data-test-swatch="inverse"]'),
        dark,
        'INVERSE under a light pane renders dark'
      );
      assert.strictEqual(
        el('[data-test-swatch="light"]').getAttribute('data-swatch-hex'),
        el('[data-test-ref-light]').getAttribute('data-swatch-hex'),
        'reported hex matches the reference'
      );
    });
  });

  module('swatch', function () {
    test('swatch composites translucent levels', async function (assert) {
      await render(
        <template>
          <WorkbenchPanes as |scheme|>
            <WorkbenchSwatch
              @token="primary-soft"
              data-test-swatch={{scheme}}
            />
          </WorkbenchPanes>
        </template>
      );

      const sel = '[data-test-swatch="light"]';
      assert.ok(
        parseColor(fill(sel)).a < 1,
        'precondition: primary-soft is translucent'
      );
      assert.strictEqual(text(`${sel} [data-swatch-level]`), 'soft');
      assert.dom(`${sel} [data-swatch-hex]`).hasText(/^#[0-9a-f]{6}$/);
      assert.dom(`${sel} [data-swatch-ratio]`).hasText(/^\d+\.\d:1$/);
      assert.dom(`${sel} [data-swatch-sample]`).hasText('Aa');
    });

    test('swatch flags low contrast', async function (assert) {
      await render(
        <template>
          {{! template-lint-disable no-inline-styles }}
          <div style="--color-x: #ffffff; --color-on-x: #eeeeee">
            <WorkbenchSwatch @token="x" data-test-low />
          </div>
          <div style="--color-y: #ffffff; --color-on-y: #000000">
            <WorkbenchSwatch @token="y" data-test-high />
          </div>
          <div style="--color-y: #ffffff; --color-z: #eeeeee">
            <WorkbenchSwatch @token="y" @onToken="z" data-test-explicit />
          </div>
        </template>
      );

      assert.dom('[data-test-low]').hasAttribute('data-low-contrast');
      assert.dom('[data-test-low] [data-swatch-hex]').hasText('#ffffff');
      assert.dom('[data-test-low] [data-swatch-ratio]').hasText('1.2:1');
      assert.dom('[data-test-high]').doesNotHaveAttribute('data-low-contrast');
      assert.dom('[data-test-high] [data-swatch-ratio]').hasText('21.0:1');
      assert.dom('[data-test-explicit]').hasAttribute('data-low-contrast');
    });
  });

  module('specimen', function () {
    test('specimen labels its block and measures the first child', async function (assert) {
      await render(
        <template>
          <WorkbenchSpecimen @label="Small" @measure={{true}}>
            {{! template-lint-disable no-inline-styles }}
            <div
              style="font-size: 13px; line-height: 18px; font-weight: 600; letter-spacing: 1px; padding: 4px 6px; gap: 3px; border-radius: 5px; height: 20px; display: flex;"
            >x</div>
          </WorkbenchSpecimen>
          <WorkbenchSpecimen @label="Plain" data-test-plain>
            <div>y</div>
          </WorkbenchSpecimen>
        </template>
      );

      const label = el('[data-workbench-specimen] [data-specimen-label]');
      assert.strictEqual(label.textContent?.trim(), 'Small');
      assert.strictEqual(getComputedStyle(label).textTransform, 'uppercase');

      const m = (key: string) =>
        text(`[data-workbench-specimen] [data-measure="${key}"]`);
      assert.strictEqual(m('fontSize'), '13px');
      assert.strictEqual(m('lineHeight'), '18px');
      assert.strictEqual(m('fontWeight'), '600');
      assert.strictEqual(m('letterSpacing'), '1px');
      assert.strictEqual(m('padding'), '4px 6px');
      assert.strictEqual(m('gap'), '3px');
      assert.strictEqual(m('borderRadius'), '5px');
      assert.strictEqual(m('height'), '20px');

      assert.dom('[data-test-plain] [data-measure]').doesNotExist();
    });
  });
});
