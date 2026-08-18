import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import Component from '@glimmer/component';
import { cell } from 'ember-resources';
import { ListManager } from 'frontile/utils/listManager';

// Reproduces the frame that `ListItem` in listManager.ts documents: the getter
// consumes `isActive` and then dispatches a real `focusout`, driving the real
// listener `setupItem` installed — all inside one autotracking frame. In
// production that frame belongs to Glimmer, which blurs the item as a side
// effect of its own DOM writes.
interface ProbeArgs {
  manager: ListManager;
  relatedTarget: EventTarget | null;
}

class Probe extends Component<{ Args: ProbeArgs }> {
  get consumeThenBlur(): string {
    const item = this.args.manager.atKey('a');

    if (!item) {
      throw new Error('probe could not find the registered item');
    }

    // Consume the tag, exactly as ListboxItem's `tabindex` getter does.
    const wasActive = item.isActive;

    item.el.dispatchEvent(
      new FocusEvent('focusout', {
        bubbles: true,
        relatedTarget: this.args.relatedTarget
      })
    );

    return String(wasActive);
  }

  <template>{{this.consumeThenBlur}}</template>
}

module('Integration | Utils | ListManager | render safety', function (hooks) {
  setupRenderingTest(hooks);

  const buildManager = () =>
    new ListManager({
      selectionMode: 'single',
      autoActivateMode: 'none'
    });

  test('a redundant isActive write from focusout does not invalidate a consumed tag', async function (assert) {
    const manager = buildManager();
    const showProbe = cell(false);

    // Focus landing on a real element is a genuine blur, so the listener runs
    // and writes `isActive = false` — a value the item already holds. That
    // write must not dirty the tag the same frame just consumed.
    const focusLandsHere = document.body;

    await render(
      <template>
        <ul>
          <li data-test-probe-item {{manager.setupItem key="a" textValue="a"}}>
            a
          </li>
        </ul>

        {{#if showProbe.current}}
          <Probe @manager={{manager}} @relatedTarget={{focusLandsHere}} />
        {{/if}}
      </template>
    );

    const item = manager.atKey('a');
    assert.false(item?.isActive, 'item starts inactive');

    // Render the probe only now, so `setupItem` has installed the real
    // focusout listener before the getter dispatches to it.
    showProbe.current = true;
    await settled();

    assert.dom('[data-test-probe-item]').exists('item still rendered');
    assert.false(item?.isActive, 'item remained inactive');
  });

  test('a focusout with no relatedTarget does not deactivate the item', async function (assert) {
    const manager = buildManager();
    const showProbe = cell(false);

    await render(
      <template>
        <ul>
          <li data-test-probe-item {{manager.setupItem key="a" textValue="a"}}>
            a
          </li>
        </ul>

        {{#if showProbe.current}}
          <Probe @manager={{manager}} @relatedTarget={{null}} />
        {{/if}}
      </template>
    );

    const item = manager.atKey('a');
    manager.activateItem(item);
    await settled();
    assert.true(item?.isActive, 'item is active before the blur');

    // A targetless blur is what Glimmer's own DOM mutation produces.
    // Deactivating there would be a genuine state change landing mid-render,
    // so the listener must ignore it entirely.
    showProbe.current = true;
    await settled();

    assert.dom('[data-test-probe-item]').exists('item still rendered');
    assert.true(item?.isActive, 'item stayed active through a targetless blur');
  });
});
