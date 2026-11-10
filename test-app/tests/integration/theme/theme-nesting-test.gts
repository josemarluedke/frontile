import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find } from '@ember/test-helpers';

// Every test renders a case next to references that sit under a single,
// unambiguous theme, and compares computed styles -- never literal colors.
// Each test also asserts that the case differs from the opposite-theme
// reference, so it cannot pass because both sides fell back to one value.
//
// Probes (the literal classes must stay in this file so Tailwind generates
// them):
//   token probe:   <div class="bg-surface-canvas" data-probe>
//   variant probe: <div class="bg-neutral-subtle dark:bg-danger" data-vprobe>
//   radio probe:   <input type="radio" class="checked-bg-radio" checked>
//   power-select:  <div class="ember-power-select-trigger">

function style(selector: string): CSSStyleDeclaration {
  const el = find(selector);
  if (!el) {
    throw new Error(`No element matches ${selector}`);
  }
  return getComputedStyle(el);
}

function bg(selector: string): string {
  return style(selector).backgroundColor;
}

module('Integration | theme nesting', function (hooks) {
  setupRenderingTest(hooks);

  test('light inside dark resolves light tokens', async function (assert) {
    await render(
      <template>
        <div class="dark" data-case>
          <div class="light"><div
              class="bg-surface-canvas"
              data-probe
            ></div></div>
        </div>
        <div class="light" data-ref>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
        <div class="dark" data-opposite>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-ref] [data-probe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-opposite] [data-probe]')
    );
  });

  test('dark inside light resolves dark tokens', async function (assert) {
    await render(
      <template>
        <div class="light" data-case>
          <div class="dark"><div
              class="bg-surface-canvas"
              data-probe
            ></div></div>
        </div>
        <div class="dark" data-ref>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
        <div class="light" data-opposite>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-ref] [data-probe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-opposite] [data-probe]')
    );
  });

  test('three levels resolve the innermost', async function (assert) {
    await render(
      <template>
        <div class="dark" data-case>
          <div class="light">
            <div class="dark"><div
                class="bg-surface-canvas"
                data-probe
              ></div></div>
          </div>
        </div>
        <div class="dark" data-ref>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
        <div class="light" data-opposite>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-ref] [data-probe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-opposite] [data-probe]')
    );
  });

  test('inverse inside light-inside-dark is dark', async function (assert) {
    await render(
      <template>
        <div class="dark" data-case>
          <div class="light">
            <div class="theme-inverse">
              <div class="bg-surface-canvas" data-probe></div>
            </div>
          </div>
        </div>
        <div class="dark" data-ref>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
        <div class="light" data-opposite>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-ref] [data-probe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-opposite] [data-probe]')
    );
  });

  test('inverse inside dark-inside-light is light', async function (assert) {
    await render(
      <template>
        <div class="light" data-case>
          <div class="dark">
            <div class="theme-inverse">
              <div class="bg-surface-canvas" data-probe></div>
            </div>
          </div>
        </div>
        <div class="light" data-ref>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
        <div class="dark" data-opposite>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-ref] [data-probe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-opposite] [data-probe]')
    );
  });

  test('double inverse returns to the outer theme', async function (assert) {
    await render(
      <template>
        <div class="light" data-case>
          <div class="theme-inverse">
            <div class="theme-inverse">
              <div class="bg-surface-canvas" data-probe></div>
            </div>
          </div>
        </div>
        <div class="light" data-ref>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
        <div class="dark" data-opposite>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-ref] [data-probe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-opposite] [data-probe]')
    );
  });

  test('an unthemed root resolves the default (light) theme', async function (assert) {
    // The test container sits under an <html> with no theme class, so the
    // bare probe gets the default (light) theme from `:root`.
    await render(
      <template>
        <div data-case>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
        <div class="light" data-ref>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
        <div class="dark" data-opposite>
          <div class="bg-surface-canvas" data-probe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-ref] [data-probe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-probe]'),
      bg('[data-opposite] [data-probe]')
    );
  });

  test('dark variant does not leak into a nested light', async function (assert) {
    await render(
      <template>
        <div class="dark" data-case>
          <div class="light">
            <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
          </div>
        </div>
        <div class="light" data-ref>
          <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
        </div>
        <div class="dark" data-opposite>
          <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-vprobe]'),
      bg('[data-ref] [data-vprobe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-vprobe]'),
      bg('[data-opposite] [data-vprobe]')
    );
  });

  test('dark variant applies inside a nested dark', async function (assert) {
    await render(
      <template>
        <div class="light" data-case>
          <div class="dark">
            <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
          </div>
        </div>
        <div class="dark" data-ref>
          <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
        </div>
        <div class="light" data-opposite>
          <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-vprobe]'),
      bg('[data-ref] [data-vprobe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-vprobe]'),
      bg('[data-opposite] [data-vprobe]')
    );
  });

  test('dark variant applies inside inverse of light', async function (assert) {
    await render(
      <template>
        <div class="light" data-case>
          <div class="theme-inverse">
            <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
          </div>
        </div>
        <div class="dark" data-ref>
          <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
        </div>
        <div class="light" data-opposite>
          <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-vprobe]'),
      bg('[data-ref] [data-vprobe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-vprobe]'),
      bg('[data-opposite] [data-vprobe]')
    );
  });

  test('dark variant resolves three levels', async function (assert) {
    await render(
      <template>
        <div class="dark" data-case>
          <div class="light">
            <div class="dark">
              <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
            </div>
          </div>
        </div>
        <div class="dark" data-ref>
          <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
        </div>
        <div class="light" data-opposite>
          <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-vprobe]'),
      bg('[data-ref] [data-vprobe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-vprobe]'),
      bg('[data-opposite] [data-vprobe]')
    );
  });

  test('dark variant follows inverse inside dark-inside-light', async function (assert) {
    await render(
      <template>
        <div class="light" data-case>
          <div class="dark">
            <div class="theme-inverse">
              <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
            </div>
          </div>
        </div>
        <div class="light" data-ref>
          <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
        </div>
        <div class="dark" data-opposite>
          <div class="bg-neutral-subtle dark:bg-danger" data-vprobe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-vprobe]'),
      bg('[data-ref] [data-vprobe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-vprobe]'),
      bg('[data-opposite] [data-vprobe]')
    );
  });

  test('dark variant ignores the dark class on its own element', async function (assert) {
    // A `dark:` utility keys off the element's ancestors, not the element
    // itself: on an element that carries `.dark` under a light ancestor it does
    // not apply, so the probe keeps its base utility (resolved in dark tokens,
    // since the element itself is `.dark`). The opposite -- the same element
    // under a dark ancestor -- does apply it.
    await render(
      <template>
        <div class="light" data-case>
          <div class="dark bg-neutral-subtle dark:bg-danger" data-vprobe></div>
        </div>
        <div class="dark" data-ref>
          <div class="bg-neutral-subtle" data-vprobe></div>
        </div>
        <div class="dark" data-opposite>
          <div class="dark bg-neutral-subtle dark:bg-danger" data-vprobe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-vprobe]'),
      bg('[data-ref] [data-vprobe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-vprobe]'),
      bg('[data-opposite] [data-vprobe]')
    );
  });

  test('light variant applies inside a nested light', async function (assert) {
    await render(
      <template>
        <div class="dark" data-case>
          <div class="light">
            <div class="bg-neutral-subtle light:bg-danger" data-lprobe></div>
          </div>
        </div>
        <div class="light" data-ref>
          <div class="bg-neutral-subtle light:bg-danger" data-lprobe></div>
        </div>
        <div class="dark" data-opposite>
          <div class="bg-neutral-subtle light:bg-danger" data-lprobe></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-lprobe]'),
      bg('[data-ref] [data-lprobe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-lprobe]'),
      bg('[data-opposite] [data-lprobe]')
    );
  });

  test('neither variant applies with four themed ancestors', async function (assert) {
    // Pins the documented limit in `index.css`: the variants enumerate up to
    // three themed ancestors. At four, neither `dark:` nor `light:` applies,
    // so the probe shows its plain utility in the nearest theme's tokens.
    await render(
      <template>
        <div class="dark" data-case>
          <div class="light">
            <div class="dark">
              <div class="light">
                <div
                  class="bg-neutral-subtle dark:bg-danger light:bg-success"
                  data-dprobe
                ></div>
              </div>
            </div>
          </div>
        </div>
        <div class="light" data-ref>
          <div class="bg-neutral-subtle" data-dprobe></div>
        </div>
        <div class="light" data-opposite>
          <div
            class="bg-neutral-subtle dark:bg-danger light:bg-success"
            data-dprobe
          ></div>
        </div>
      </template>
    );

    assert.strictEqual(
      bg('[data-case] [data-dprobe]'),
      bg('[data-ref] [data-dprobe]')
    );
    assert.notStrictEqual(
      bg('[data-case] [data-dprobe]'),
      bg('[data-opposite] [data-dprobe]')
    );
  });

  test('dark radio icon does not leak into a nested light', async function (assert) {
    await render(
      <template>
        <div class="dark" data-case>
          <div class="light">
            <input
              type="radio"
              class="checked-bg-radio"
              checked
              data-radio
              aria-label="case"
            />
          </div>
        </div>
        <div class="light" data-ref>
          <input
            type="radio"
            class="checked-bg-radio"
            checked
            data-radio
            aria-label="ref"
          />
        </div>
        <div class="dark" data-opposite>
          <input
            type="radio"
            class="checked-bg-radio"
            checked
            data-radio
            aria-label="opposite"
          />
        </div>
      </template>
    );

    const image = (s: string) => style(s).backgroundImage;
    assert.strictEqual(
      image('[data-case] [data-radio]'),
      image('[data-ref] [data-radio]')
    );
    assert.notStrictEqual(
      image('[data-case] [data-radio]'),
      image('[data-opposite] [data-radio]')
    );
  });

  test('dark radio icon applies inside a nested dark', async function (assert) {
    await render(
      <template>
        <div class="light" data-case>
          <div class="dark">
            <input
              type="radio"
              class="checked-bg-radio"
              checked
              data-radio
              aria-label="case"
            />
          </div>
        </div>
        <div class="dark" data-ref>
          <input
            type="radio"
            class="checked-bg-radio"
            checked
            data-radio
            aria-label="ref"
          />
        </div>
        <div class="light" data-opposite>
          <input
            type="radio"
            class="checked-bg-radio"
            checked
            data-radio
            aria-label="opposite"
          />
        </div>
      </template>
    );

    const image = (s: string) => style(s).backgroundImage;
    assert.strictEqual(
      image('[data-case] [data-radio]'),
      image('[data-ref] [data-radio]')
    );
    assert.notStrictEqual(
      image('[data-case] [data-radio]'),
      image('[data-opposite] [data-radio]')
    );
  });

  test('dark power-select surface does not leak into a nested light', async function (assert) {
    await render(
      <template>
        <div class="dark" data-case>
          <div class="light">
            <div class="ember-power-select-trigger" data-ps></div>
          </div>
        </div>
        <div class="light" data-ref>
          <div class="ember-power-select-trigger" data-ps></div>
        </div>
        <div class="dark" data-opposite>
          <div class="ember-power-select-trigger" data-ps></div>
        </div>
      </template>
    );

    assert.strictEqual(bg('[data-case] [data-ps]'), bg('[data-ref] [data-ps]'));
    assert.notStrictEqual(
      bg('[data-case] [data-ps]'),
      bg('[data-opposite] [data-ps]')
    );
  });

  test('dark power-select surface applies inside a nested dark', async function (assert) {
    await render(
      <template>
        <div class="light" data-case>
          <div class="dark">
            <div class="ember-power-select-trigger" data-ps></div>
          </div>
        </div>
        <div class="dark" data-ref>
          <div class="ember-power-select-trigger" data-ps></div>
        </div>
        <div class="light" data-opposite>
          <div class="ember-power-select-trigger" data-ps></div>
        </div>
      </template>
    );

    assert.strictEqual(bg('[data-case] [data-ps]'), bg('[data-ref] [data-ps]'));
    assert.notStrictEqual(
      bg('[data-case] [data-ps]'),
      bg('[data-opposite] [data-ps]')
    );
  });

  test('color-scheme follows the nearest theme', async function (assert) {
    await render(
      <template>
        <div class="dark" data-case>
          <div class="light"><div data-scheme></div></div>
        </div>
        <div class="dark" data-opposite>
          <div data-scheme></div>
        </div>
      </template>
    );

    assert.strictEqual(style('[data-case] [data-scheme]').colorScheme, 'light');
    assert.strictEqual(
      style('[data-opposite] [data-scheme]').colorScheme,
      'dark'
    );
  });
});
