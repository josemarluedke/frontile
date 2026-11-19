// PROTOTYPE: layout regions. Not a test of the prototype: these pin down what
// the existing `Portal` + `PortalTarget` pair does when used as the region
// mechanism as it is, which is why the prototype does not use it.
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, settled } from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { Portal, PortalTarget } from 'frontile';

module('Integration | Experiment | Portal as a region', function (hooks) {
  setupRenderingTest(hooks);

  test('a target written before the source is filled in the first pass', async function (assert) {
    let firstPass = '';
    const probe = (): void => {
      firstPass = find('[data-test-navbar]')?.textContent?.trim() ?? '';
    };
    await render(
      <template>
        <div data-test-layout>
          <header data-test-navbar><PortalTarget @for="actions" /></header>
          <main><Portal @target="actions">Actions</Portal></main>
        </div>
        {{(probe)}}
      </template>
    );

    assert.strictEqual(firstPass, 'Actions');
  });

  test('a target written after the source is missed, and the content goes to the default container', async function (assert) {
    await render(
      <template>
        <div data-test-layout>
          <main><Portal @target="aside">Details</Portal></main>
          <aside data-test-aside><PortalTarget @for="aside" /></aside>
        </div>
      </template>
    );

    assert.dom('[data-test-aside]').hasText('', 'the aside target is empty');
    assert.strictEqual(
      find('[data-test-layout]')!.textContent!.trim(),
      '',
      'the content is not in the layout at all'
    );
    assert.true(
      document
        .getElementById('ember-testing')!
        .textContent!.includes('Details'),
      'it fell through to the default container'
    );
  });

  test('a target that appears later is never found', async function (assert) {
    const open = cell(false);
    await render(
      <template>
        <div data-test-layout>
          <main><Portal @target="aside">Details</Portal></main>
          {{#if open.current}}
            <aside data-test-aside><PortalTarget @for="aside" /></aside>
          {{/if}}
        </div>
      </template>
    );

    open.current = true;
    await settled();

    assert
      .dom('[data-test-aside]')
      .hasText('', 'opening the aside shows nothing');
  });

  test('a target that is rebuilt loses the content', async function (assert) {
    const wide = cell(true);
    await render(
      <template>
        <div data-test-layout>
          {{#if wide.current}}
            <aside data-test-aside="inline"><PortalTarget
                @for="aside"
              /></aside>
          {{else}}
            <div data-test-aside="drawer"><PortalTarget @for="aside" /></div>
          {{/if}}
          <main><Portal @target="aside">Details</Portal></main>
        </div>
      </template>
    );

    assert.dom('[data-test-aside="inline"]').hasText('Details');

    wide.current = false;
    await settled();

    assert
      .dom('[data-test-aside="drawer"]')
      .hasText('', 'the content did not follow to the new target');
    assert.false(
      document
        .getElementById('ember-testing')!
        .textContent!.includes('Details'),
      'it is gone from the page'
    );
  });
});
