import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, triggerKeyEvent, triggerEvent } from '@ember/test-helpers';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { press } from '@frontile/utilities';

class PressTestComponent extends Component {
  @tracked startCount = 0;
  @tracked endCount = 0;
  @tracked pressCount = 0;
  @tracked upCount = 0;

  onStart = () => {
    this.startCount++;
  };

  onEnd = () => {
    this.endCount++;
  };

  onPress = () => {
    this.pressCount++;
  };

  onUp = () => {
    this.upCount++;
  };

  <template>
    <button
      data-test-id="press-target"
      {{press
        onPressStart=this.onStart
        onPressEnd=this.onEnd
        onPress=this.onPress
        onPressUp=this.onUp
      }}
    >
      Press me
    </button>
    <div data-test-start>{{this.startCount}}</div>
    <div data-test-end>{{this.endCount}}</div>
    <div data-test-press>{{this.pressCount}}</div>
    <div data-test-up>{{this.upCount}}</div>
  </template>
}

module('Integration | Modifier | press | @frontile/utilities', function (hooks) {
  setupRenderingTest(hooks);

  test('it triggers press callbacks on click', async function (assert) {
    await render(<template><PressTestComponent /></template>);

    await triggerEvent('[data-test-id="press-target"]', 'pointerdown');
    await triggerEvent('[data-test-id="press-target"]', 'pointerup');

    assert.dom('[data-test-start]').hasText('1');
    assert.dom('[data-test-end]').hasText('1');
    assert.dom('[data-test-press]').hasText('1');
    assert.dom('[data-test-up]').hasText('1');
  });

  test('it handles keyboard interaction', async function (assert) {
    await render(<template><PressTestComponent /></template>);

    await triggerKeyEvent('[data-test-id="press-target"]', 'keydown', 'Enter');
    await triggerKeyEvent('[data-test-id="press-target"]', 'keyup', 'Enter');

    assert.dom('[data-test-start]').hasText('1');
    assert.dom('[data-test-end]').hasText('1');
    assert.dom('[data-test-press]').hasText('1');
    assert.dom('[data-test-up]').hasText('1');
  });
});
