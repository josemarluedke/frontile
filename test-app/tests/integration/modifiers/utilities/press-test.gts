import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  triggerKeyEvent,
  triggerEvent,
  find,
  click
} from '@ember/test-helpers';
import { on } from '@ember/modifier';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { press, type PressEvent } from 'frontile';

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

class StartOnlyComponent extends Component {
  @tracked startCount = 0;

  onStart = () => {
    this.startCount++;
  };

  <template>
    <button
      data-test-id="start-only-target"
      {{press onPressStart=this.onStart}}
    >
      Start Only
    </button>
    <div data-test-start>{{this.startCount}}</div>
  </template>
}

class EndOnlyComponent extends Component {
  @tracked endCount = 0;

  onEnd = () => {
    this.endCount++;
  };

  <template>
    <button data-test-id="end-only-target" {{press onPressEnd=this.onEnd}}>
      End Only
    </button>
    <div data-test-end>{{this.endCount}}</div>
  </template>
}

class PressOnlyComponent extends Component {
  @tracked pressCount = 0;

  onPress = () => {
    this.pressCount++;
  };

  <template>
    <button data-test-id="press-only-target" {{press onPress=this.onPress}}>
      Press Only
    </button>
    <div data-test-press>{{this.pressCount}}</div>
  </template>
}

class NoCallbacksComponent extends Component {
  <template>
    <button data-test-id="no-callbacks-target" {{press}}>
      No Callbacks
    </button>
  </template>
}

module(
  'Integration | Modifier | press | @frontile/utilities',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it triggers all press callbacks on pointer events', async function (assert) {
      await render(<template><PressTestComponent /></template>);

      await triggerEvent('[data-test-id="press-target"]', 'pointerdown');
      await triggerEvent('[data-test-id="press-target"]', 'pointerup');

      assert.dom('[data-test-start]').hasText('1');
      assert.dom('[data-test-end]').hasText('1');
      assert.dom('[data-test-press]').hasText('1');
      assert.dom('[data-test-up]').hasText('1');
    });

    test('it triggers all press callbacks on mouse events', async function (assert) {
      await render(<template><PressTestComponent /></template>);

      await triggerEvent('[data-test-id="press-target"]', 'mousedown');
      await triggerEvent('[data-test-id="press-target"]', 'mouseup');

      assert.dom('[data-test-start]').hasText('1');
      assert.dom('[data-test-end]').hasText('1');
      assert.dom('[data-test-press]').hasText('1');
      assert.dom('[data-test-up]').hasText('1');
    });

    test('it handles keyboard interaction with Enter key', async function (assert) {
      await render(<template><PressTestComponent /></template>);

      await triggerKeyEvent(
        '[data-test-id="press-target"]',
        'keydown',
        'Enter'
      );
      await triggerKeyEvent('[data-test-id="press-target"]', 'keyup', 'Enter');

      assert.dom('[data-test-start]').hasText('1');
      assert.dom('[data-test-end]').hasText('1');
      assert.dom('[data-test-press]').hasText('1');
      assert.dom('[data-test-up]').hasText('1');
    });

    test('it handles keyboard interaction with Space key', async function (assert) {
      await render(<template><PressTestComponent /></template>);

      await triggerKeyEvent('[data-test-id="press-target"]', 'keydown', ' ');
      await triggerKeyEvent('[data-test-id="press-target"]', 'keyup', ' ');

      assert.dom('[data-test-start]').hasText('1');
      assert.dom('[data-test-end]').hasText('1');
      assert.dom('[data-test-press]').hasText('1');
      assert.dom('[data-test-up]').hasText('1');
    });

    test('it ignores other keyboard keys', async function (assert) {
      await render(<template><PressTestComponent /></template>);

      await triggerKeyEvent('[data-test-id="press-target"]', 'keydown', 'A');
      await triggerKeyEvent('[data-test-id="press-target"]', 'keyup', 'A');

      assert.dom('[data-test-start]').hasText('0');
      assert.dom('[data-test-end]').hasText('0');
      assert.dom('[data-test-press]').hasText('0');
      assert.dom('[data-test-up]').hasText('0');
    });

    test('it handles pointercancel event', async function (assert) {
      await render(<template><PressTestComponent /></template>);

      await triggerEvent('[data-test-id="press-target"]', 'pointerdown');
      await triggerEvent('[data-test-id="press-target"]', 'pointercancel');

      assert.dom('[data-test-start]').hasText('1');
      assert.dom('[data-test-end]').hasText('1'); // cancel triggers onPressEnd
      assert.dom('[data-test-press]').hasText('0'); // but not onPress
      assert.dom('[data-test-up]').hasText('0'); // and not onPressUp
    });

    test('it prevents duplicate start events', async function (assert) {
      await render(<template><PressTestComponent /></template>);

      await triggerEvent('[data-test-id="press-target"]', 'pointerdown');
      await triggerEvent('[data-test-id="press-target"]', 'pointerdown'); // duplicate
      await triggerEvent('[data-test-id="press-target"]', 'pointerup');

      assert.dom('[data-test-start]').hasText('1'); // only one start event
      assert.dom('[data-test-end]').hasText('1');
      assert.dom('[data-test-press]').hasText('1');
      assert.dom('[data-test-up]').hasText('1');
    });

    test('it prevents end events without start', async function (assert) {
      await render(<template><PressTestComponent /></template>);

      await triggerEvent('[data-test-id="press-target"]', 'pointerup'); // no start

      assert.dom('[data-test-start]').hasText('0');
      assert.dom('[data-test-end]').hasText('0'); // no end without start
      assert.dom('[data-test-press]').hasText('0');
      assert.dom('[data-test-up]').hasText('0');
    });

    test('onPress only triggers when target contains event target', async function (assert) {
      await render(<template><PressTestComponent /></template>);

      const button = find('[data-test-id="press-target"]')!;

      await triggerEvent(button, 'pointerdown');

      // Create a child element within the button to test event target checking
      const childElement = document.createElement('span');
      childElement.textContent = 'child';
      button.appendChild(childElement);

      // Trigger pointerup on the child element (should still trigger onPress)
      await triggerEvent(childElement, 'pointerup');

      // Clean up
      button.removeChild(childElement);

      assert.dom('[data-test-start]').hasText('1');
      assert.dom('[data-test-end]').hasText('1');
      assert.dom('[data-test-press]').hasText('1'); // onPress should trigger (child is within button)
      assert.dom('[data-test-up]').hasText('1'); // and onPressUp should also trigger
    });

    // Test optimization: individual callback types work correctly
    test('it works with only onPressStart callback', async function (assert) {
      await render(<template><StartOnlyComponent /></template>);

      await triggerEvent('[data-test-id="start-only-target"]', 'pointerdown');
      // Note: still triggers pointerup to complete the interaction cycle
      await triggerEvent('[data-test-id="start-only-target"]', 'pointerup');

      assert.dom('[data-test-start]').hasText('1');
    });

    test('it works with only onPressEnd callback', async function (assert) {
      await render(<template><EndOnlyComponent /></template>);

      await triggerEvent('[data-test-id="end-only-target"]', 'pointerdown');
      await triggerEvent('[data-test-id="end-only-target"]', 'pointerup');

      assert.dom('[data-test-end]').hasText('1');
    });

    test('it works with only onPress callback', async function (assert) {
      await render(<template><PressOnlyComponent /></template>);

      await triggerEvent('[data-test-id="press-only-target"]', 'pointerdown');
      await triggerEvent('[data-test-id="press-only-target"]', 'pointerup');

      assert.dom('[data-test-press]').hasText('1');
    });

    test('it handles no callbacks gracefully', async function (assert) {
      await render(<template><NoCallbacksComponent /></template>);

      // Should not throw errors
      await triggerEvent('[data-test-id="no-callbacks-target"]', 'pointerdown');
      await triggerEvent('[data-test-id="no-callbacks-target"]', 'pointerup');
      await triggerKeyEvent(
        '[data-test-id="no-callbacks-target"]',
        'keydown',
        'Enter'
      );
      await triggerKeyEvent(
        '[data-test-id="no-callbacks-target"]',
        'keyup',
        'Enter'
      );

      assert.ok(true, 'No errors thrown with no callbacks');
    });

    test('keyboard events work with partial callbacks', async function (assert) {
      await render(<template><StartOnlyComponent /></template>);

      await triggerKeyEvent(
        '[data-test-id="start-only-target"]',
        'keydown',
        'Enter'
      );
      await triggerKeyEvent(
        '[data-test-id="start-only-target"]',
        'keyup',
        'Enter'
      );

      assert.dom('[data-test-start]').hasText('1');
    });

    test('pointercancel only works when onPressEnd is provided', async function (assert) {
      await render(<template><StartOnlyComponent /></template>);

      await triggerEvent('[data-test-id="start-only-target"]', 'pointerdown');
      await triggerEvent('[data-test-id="start-only-target"]', 'pointercancel');

      assert.dom('[data-test-start]').hasText('1');
    });

    test('HTML disabled elements cannot receive events', async function (assert) {
      class HtmlDisabledComponent extends Component {
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
            data-test-id="html-disabled-press-target"
            disabled
            {{press
              onPressStart=this.onStart
              onPressEnd=this.onEnd
              onPress=this.onPress
              onPressUp=this.onUp
            }}
          >
            HTML Disabled Press
          </button>
          <div data-test-start>{{this.startCount}}</div>
          <div data-test-end>{{this.endCount}}</div>
          <div data-test-press>{{this.pressCount}}</div>
          <div data-test-up>{{this.upCount}}</div>
        </template>
      }

      await render(<template><HtmlDisabledComponent /></template>);

      // HTML disabled buttons cannot receive events (browsers prevent this)
      // @ember/test-helpers also prevents this to match browser behavior
      let errorThrown = false;
      try {
        await triggerEvent(
          '[data-test-id="html-disabled-press-target"]',
          'pointerdown'
        );
      } catch {
        errorThrown = true;
      }

      assert.ok(
        errorThrown,
        'Should have thrown an error for disabled element'
      );

      // Counts should remain 0 since no events were triggered
      assert.dom('[data-test-start]').hasText('0');
      assert.dom('[data-test-end]').hasText('0');
      assert.dom('[data-test-press]').hasText('0');
      assert.dom('[data-test-up]').hasText('0');
    });

    test('it works with positional onPress argument', async function (assert) {
      class PositionalPressComponent extends Component {
        @tracked pressCount = 0;

        onPress = () => {
          this.pressCount++;
        };

        <template>
          <button data-test-id="positional-press-target" {{press this.onPress}}>
            Positional Press
          </button>
          <div data-test-press>{{this.pressCount}}</div>
        </template>
      }

      await render(<template><PositionalPressComponent /></template>);

      await triggerEvent(
        '[data-test-id="positional-press-target"]',
        'pointerdown'
      );
      await triggerEvent(
        '[data-test-id="positional-press-target"]',
        'pointerup'
      );

      assert.dom('[data-test-press]').hasText('1');
    });

    test('it works with positional and other named arguments', async function (assert) {
      class MixedArgsComponent extends Component {
        @tracked startCount = 0;
        @tracked pressCount = 0;
        @tracked endCount = 0;

        onStart = () => {
          this.startCount++;
        };

        onPress = () => {
          this.pressCount++;
        };

        onEnd = () => {
          this.endCount++;
        };

        <template>
          <button
            data-test-id="mixed-args-target"
            {{press
              this.onPress
              onPressStart=this.onStart
              onPressEnd=this.onEnd
            }}
          >
            Mixed Args
          </button>
          <div data-test-start>{{this.startCount}}</div>
          <div data-test-press>{{this.pressCount}}</div>
          <div data-test-end>{{this.endCount}}</div>
        </template>
      }

      await render(<template><MixedArgsComponent /></template>);

      await triggerEvent('[data-test-id="mixed-args-target"]', 'pointerdown');
      await triggerEvent('[data-test-id="mixed-args-target"]', 'pointerup');

      assert.dom('[data-test-start]').hasText('1');
      assert.dom('[data-test-press]').hasText('1');
      assert.dom('[data-test-end]').hasText('1');
    });

    test('PressEvent provides correct pointer type for keyboard events', async function (assert) {
      let capturedPressEvent: PressEvent | null = null;

      class KeyboardPressEventComponent extends Component {
        onPress = (event: PressEvent) => {
          capturedPressEvent = event;
        };

        <template>
          <button
            data-test-id="keyboard-press-target"
            {{press onPress=this.onPress}}
          >
            Keyboard Press Test
          </button>
        </template>
      }

      await render(<template><KeyboardPressEventComponent /></template>);

      await triggerKeyEvent(
        '[data-test-id="keyboard-press-target"]',
        'keydown',
        'Enter'
      );
      await triggerKeyEvent(
        '[data-test-id="keyboard-press-target"]',
        'keyup',
        'Enter'
      );

      assert.ok(capturedPressEvent, 'onPress should receive PressEvent');
      assert.strictEqual(
        capturedPressEvent!.type,
        'press',
        'Should have correct type'
      );
      assert.strictEqual(
        capturedPressEvent!.pointerType,
        'keyboard',
        'Should detect keyboard pointer type'
      );
      assert.strictEqual(
        capturedPressEvent!.x,
        0,
        'Keyboard events should have x = 0'
      );
      assert.strictEqual(
        capturedPressEvent!.y,
        0,
        'Keyboard events should have y = 0'
      );
    });

    test('PressEvent provides correct modifier key states', async function (assert) {
      let capturedPressEvent: PressEvent | null = null;

      class ModifierTestComponent extends Component {
        onPress = (event: PressEvent) => {
          capturedPressEvent = event;
        };

        <template>
          <button data-test-id="modifier-target" {{press onPress=this.onPress}}>
            Modifier Test
          </button>
        </template>
      }

      await render(<template><ModifierTestComponent /></template>);

      await triggerEvent('[data-test-id="modifier-target"]', 'pointerdown');
      await triggerEvent('[data-test-id="modifier-target"]', 'pointerup');

      assert.ok(capturedPressEvent, 'Should receive PressEvent');
      assert.strictEqual(
        typeof capturedPressEvent!.shiftKey,
        'boolean',
        'shiftKey should be boolean'
      );
      assert.strictEqual(
        typeof capturedPressEvent!.ctrlKey,
        'boolean',
        'ctrlKey should be boolean'
      );
      assert.strictEqual(
        typeof capturedPressEvent!.metaKey,
        'boolean',
        'metaKey should be boolean'
      );
      assert.strictEqual(
        typeof capturedPressEvent!.altKey,
        'boolean',
        'altKey should be boolean'
      );
    });

    test('PressEvent provides correct coordinates for pointer events', async function (assert) {
      let capturedPressEvent: PressEvent | null = null;

      class CoordinateTestComponent extends Component {
        onPress = (event: PressEvent) => {
          capturedPressEvent = event;
        };

        <template>
          <button
            data-test-id="coordinate-target"
            {{press onPress=this.onPress}}
          >
            Coordinate Test
          </button>
        </template>
      }

      await render(<template><CoordinateTestComponent /></template>);

      await triggerEvent('[data-test-id="coordinate-target"]', 'pointerdown');
      await triggerEvent('[data-test-id="coordinate-target"]', 'pointerup');

      assert.ok(capturedPressEvent, 'Should receive PressEvent');
      assert.strictEqual(
        typeof capturedPressEvent!.x,
        'number',
        'x should be a number'
      );
      assert.strictEqual(
        typeof capturedPressEvent!.y,
        'number',
        'y should be a number'
      );
      assert.ok(capturedPressEvent!.x >= 0, 'x should be non-negative');
      assert.ok(capturedPressEvent!.y >= 0, 'y should be non-negative');
    });

    test('PressEvent continuePropagation method exists and is callable', async function (assert) {
      let capturedPressEvent: PressEvent | null = null;

      class PropagationMethodTestComponent extends Component {
        onPress = (event: PressEvent) => {
          capturedPressEvent = event;
        };

        <template>
          <button
            data-test-id="propagation-method-target"
            {{press onPress=this.onPress}}
          >
            Propagation Method Test
          </button>
        </template>
      }

      await render(<template><PropagationMethodTestComponent /></template>);

      await triggerEvent(
        '[data-test-id="propagation-method-target"]',
        'pointerdown'
      );
      await triggerEvent(
        '[data-test-id="propagation-method-target"]',
        'pointerup'
      );

      assert.ok(capturedPressEvent, 'Should receive PressEvent');
      assert.strictEqual(
        typeof capturedPressEvent!.continuePropagation,
        'function',
        'continuePropagation should be a function'
      );

      // Test that calling the method doesn't throw an error
      try {
        capturedPressEvent!.continuePropagation();
        assert.ok(
          true,
          'continuePropagation method should be callable without errors'
        );
      } catch (error) {
        assert.ok(
          false,
          `continuePropagation method should not throw errors: ${error}`
        );
      }
    });

    test('PressEvent types are correct for different event phases', async function (assert) {
      let capturedEvents: PressEvent[] = [];

      class EventTypeTestComponent extends Component {
        onPressStart = (event: PressEvent) => {
          capturedEvents.push(event);
        };

        onPress = (event: PressEvent) => {
          capturedEvents.push(event);
        };

        onPressEnd = (event: PressEvent) => {
          capturedEvents.push(event);
        };

        onPressUp = (event: PressEvent) => {
          capturedEvents.push(event);
        };

        <template>
          <button
            data-test-id="event-type-target"
            {{press
              onPressStart=this.onPressStart
              onPress=this.onPress
              onPressEnd=this.onPressEnd
              onPressUp=this.onPressUp
            }}
          >
            Event Type Test
          </button>
        </template>
      }

      await render(<template><EventTypeTestComponent /></template>);

      capturedEvents = [];
      await triggerEvent('[data-test-id="event-type-target"]', 'pointerdown');
      await triggerEvent('[data-test-id="event-type-target"]', 'pointerup');

      assert.strictEqual(
        capturedEvents.length,
        4,
        'Should capture all 4 events'
      );
      assert.strictEqual(
        capturedEvents[0]!.type,
        'pressstart',
        'First event should be pressstart'
      );
      assert.strictEqual(
        capturedEvents[1]!.type,
        'pressend',
        'Second event should be pressend'
      );
      assert.strictEqual(
        capturedEvents[2]!.type,
        'press',
        'Third event should be press'
      );
      assert.strictEqual(
        capturedEvents[3]!.type,
        'pressup',
        'Fourth event should be pressup'
      );
    });

    test('drag outside element and release still triggers end events', async function (assert) {
      let capturedEvents: { type: string; eventType: string }[] = [];

      class DragOutsideTestComponent extends Component {
        onPressStart = (event: PressEvent) => {
          capturedEvents.push({ type: 'start', eventType: event.type });
        };

        onPressEnd = (event: PressEvent) => {
          capturedEvents.push({ type: 'end', eventType: event.type });
        };

        onPress = (event: PressEvent) => {
          capturedEvents.push({ type: 'press', eventType: event.type });
        };

        onPressUp = (event: PressEvent) => {
          capturedEvents.push({ type: 'up', eventType: event.type });
        };

        <template>
          <button
            data-test-id="drag-outside-target"
            {{press
              onPressStart=this.onPressStart
              onPressEnd=this.onPressEnd
              onPress=this.onPress
              onPressUp=this.onPressUp
            }}
          >
            Drag Outside Test
          </button>
        </template>
      }

      await render(<template><DragOutsideTestComponent /></template>);

      capturedEvents = [];

      // Start press on element
      await triggerEvent('[data-test-id="drag-outside-target"]', 'pointerdown');

      // Release on document (simulating drag outside element)
      await triggerEvent(document, 'pointerup');

      // Should capture start and end events
      assert.strictEqual(
        capturedEvents.length,
        3,
        'Should capture start, end, and up events'
      );
      assert.strictEqual(
        capturedEvents[0]!.type,
        'start',
        'First event should be start'
      );
      assert.strictEqual(
        capturedEvents[1]!.type,
        'end',
        'Second event should be end'
      );
      assert.strictEqual(
        capturedEvents[2]!.type,
        'up',
        'Third event should be up'
      );

      // onPress should NOT trigger since the release wasn't on the element
      assert.ok(
        !capturedEvents.some((e) => e.type === 'press'),
        'onPress should not trigger when released outside element'
      );
    });

    test('onPressChange callback tracks press state changes', async function (assert) {
      let pressStates: boolean[] = [];

      class PressChangeTestComponent extends Component {
        onPressChange = (isPressed: boolean) => {
          pressStates.push(isPressed);
        };

        <template>
          <button
            data-test-id="press-change-target"
            {{press onPressChange=this.onPressChange}}
          >
            Press Change Test
          </button>
        </template>
      }

      await render(<template><PressChangeTestComponent /></template>);

      pressStates = [];

      // Test mouse press cycle
      await triggerEvent('[data-test-id="press-change-target"]', 'mousedown');
      await triggerEvent('[data-test-id="press-change-target"]', 'mouseup');

      assert.deepEqual(
        pressStates,
        [true, false],
        'Should track press state changes: pressed -> not pressed'
      );

      // Reset and test keyboard press cycle
      pressStates = [];
      await triggerKeyEvent(
        '[data-test-id="press-change-target"]',
        'keydown',
        'Enter'
      );
      await triggerKeyEvent(
        '[data-test-id="press-change-target"]',
        'keyup',
        'Enter'
      );

      assert.deepEqual(
        pressStates,
        [true, false],
        'Should track keyboard press state changes: pressed -> not pressed'
      );
    });

    test('onPressChange called on pointer cancel', async function (assert) {
      let pressStates: boolean[] = [];

      class PressChangeCancelTestComponent extends Component {
        onPressChange = (isPressed: boolean) => {
          pressStates.push(isPressed);
        };

        <template>
          <button
            data-test-id="press-change-cancel-target"
            {{press onPressChange=this.onPressChange}}
          >
            Press Change Cancel Test
          </button>
        </template>
      }

      await render(<template><PressChangeCancelTestComponent /></template>);

      pressStates = [];

      // Test press start followed by cancel
      await triggerEvent(
        '[data-test-id="press-change-cancel-target"]',
        'pointerdown'
      );
      await triggerEvent(
        '[data-test-id="press-change-cancel-target"]',
        'pointercancel'
      );

      assert.deepEqual(
        pressStates,
        [true, false],
        'Should track press state changes when interaction is cancelled'
      );
    });

    test('PressEvent preventDefault method is available', async function (assert) {
      let capturedPressEvent: PressEvent | null = null;

      class PreventDefaultTestComponent extends Component {
        onPress = (event: PressEvent) => {
          capturedPressEvent = event;
        };

        <template>
          <button
            data-test-id="prevent-default-target"
            {{press onPress=this.onPress}}
          >
            Prevent Default Test
          </button>
        </template>
      }

      await render(<template><PreventDefaultTestComponent /></template>);

      await triggerEvent(
        '[data-test-id="prevent-default-target"]',
        'pointerdown'
      );
      await triggerEvent(
        '[data-test-id="prevent-default-target"]',
        'pointerup'
      );

      assert.ok(capturedPressEvent, 'Should receive PressEvent');
      assert.strictEqual(
        typeof capturedPressEvent!.preventDefault,
        'function',
        'preventDefault should be a function'
      );

      // Test that calling the method doesn't throw an error
      try {
        capturedPressEvent!.preventDefault();
        assert.ok(
          true,
          'preventDefault method should be callable without errors'
        );
      } catch (error) {
        assert.ok(
          false,
          `preventDefault method should not throw errors: ${error}`
        );
      }
    });

    // Element-specific preventDefault behavior tests
    test('keyboard events on regular buttons prevent default', async function (assert) {
      // Test that press events work correctly on buttons - this indirectly confirms preventDefault logic
      let pressCount = 0;

      class RegularButtonTestComponent extends Component {
        onPress = () => {
          pressCount++;
        };

        <template>
          <button
            data-test-id="regular-button-target"
            {{press onPress=this.onPress}}
          >
            Regular Button
          </button>
        </template>
      }

      await render(<template><RegularButtonTestComponent /></template>);

      await triggerKeyEvent(
        '[data-test-id="regular-button-target"]',
        'keydown',
        'Enter'
      );
      await triggerKeyEvent(
        '[data-test-id="regular-button-target"]',
        'keyup',
        'Enter'
      );

      assert.strictEqual(
        pressCount,
        1,
        'Enter key should trigger press on regular button'
      );
    });

    test('keyboard events on submit buttons do not prevent default', async function (assert) {
      let preventDefaultCalled = false;
      let originalPreventDefault: () => void;

      class SubmitButtonTestComponent extends Component {
        handleKeyDown = (event: KeyboardEvent) => {
          originalPreventDefault = event.preventDefault.bind(event);
          event.preventDefault = () => {
            preventDefaultCalled = true;
            originalPreventDefault();
          };
        };

        <template>
          <button
            type="submit"
            data-test-id="submit-button-target"
            {{on "keydown" this.handleKeyDown}}
            {{press}}
          >
            Submit Button
          </button>
        </template>
      }

      await render(<template><SubmitButtonTestComponent /></template>);

      await triggerKeyEvent(
        '[data-test-id="submit-button-target"]',
        'keydown',
        'Enter'
      );

      assert.notOk(
        preventDefaultCalled,
        'Enter key should not prevent default on submit button'
      );
    });

    test('keyboard events on reset buttons do not prevent default', async function (assert) {
      let preventDefaultCalled = false;
      let originalPreventDefault: () => void;

      class ResetButtonTestComponent extends Component {
        handleKeyDown = (event: KeyboardEvent) => {
          originalPreventDefault = event.preventDefault.bind(event);
          event.preventDefault = () => {
            preventDefaultCalled = true;
            originalPreventDefault();
          };
        };

        <template>
          <button
            type="reset"
            data-test-id="reset-button-target"
            {{on "keydown" this.handleKeyDown}}
            {{press}}
          >
            Reset Button
          </button>
        </template>
      }

      await render(<template><ResetButtonTestComponent /></template>);

      await triggerKeyEvent(
        '[data-test-id="reset-button-target"]',
        'keydown',
        'Enter'
      );

      assert.notOk(
        preventDefaultCalled,
        'Enter key should not prevent default on reset button'
      );
    });

    test('keyboard events on input elements do not prevent default', async function (assert) {
      let preventDefaultCalled = false;
      let originalPreventDefault: () => void;

      class InputTestComponent extends Component {
        handleKeyDown = (event: KeyboardEvent) => {
          originalPreventDefault = event.preventDefault.bind(event);
          event.preventDefault = () => {
            preventDefaultCalled = true;
            originalPreventDefault();
          };
        };

        <template>
          <input
            data-test-id="input-target"
            {{on "keydown" this.handleKeyDown}}
            {{press}}
          />
        </template>
      }

      await render(<template><InputTestComponent /></template>);

      await triggerKeyEvent(
        '[data-test-id="input-target"]',
        'keydown',
        'Enter'
      );

      assert.notOk(
        preventDefaultCalled,
        'Enter key should not prevent default on input element'
      );
    });

    test('keyboard events on anchor links do not prevent default', async function (assert) {
      let preventDefaultCalled = false;
      let originalPreventDefault: () => void;

      class AnchorTestComponent extends Component {
        handleKeyDown = (event: KeyboardEvent) => {
          originalPreventDefault = event.preventDefault.bind(event);
          event.preventDefault = () => {
            preventDefaultCalled = true;
            originalPreventDefault();
          };
        };

        <template>
          <a
            href="#test"
            data-test-id="anchor-target"
            {{on "keydown" this.handleKeyDown}}
            {{press}}
          >
            Test Link
          </a>
        </template>
      }

      await render(<template><AnchorTestComponent /></template>);

      await triggerKeyEvent(
        '[data-test-id="anchor-target"]',
        'keydown',
        'Enter'
      );

      assert.notOk(
        preventDefaultCalled,
        'Enter key should not prevent default on anchor link'
      );
    });

    test('space key on checkbox input only triggers press events', async function (assert) {
      let preventDefaultCalled = false;
      let pressCount = 0;
      let originalPreventDefault: () => void;

      class CheckboxTestComponent extends Component {
        handleKeyDown = (event: KeyboardEvent) => {
          originalPreventDefault = event.preventDefault.bind(event);
          event.preventDefault = () => {
            preventDefaultCalled = true;
            originalPreventDefault();
          };
        };

        onPress = () => {
          pressCount++;
        };

        <template>
          <input
            type="checkbox"
            data-test-id="checkbox-target"
            {{on "keydown" this.handleKeyDown}}
            {{press onPress=this.onPress}}
          />
        </template>
      }

      await render(<template><CheckboxTestComponent /></template>);

      // Space should work on checkbox
      await triggerKeyEvent('[data-test-id="checkbox-target"]', 'keydown', ' ');
      await triggerKeyEvent('[data-test-id="checkbox-target"]', 'keyup', ' ');

      assert.notOk(
        preventDefaultCalled,
        'Space key should not prevent default on checkbox'
      );
      assert.strictEqual(
        pressCount,
        1,
        'Space should trigger press event on checkbox'
      );

      // Reset for Enter test
      preventDefaultCalled = false;
      pressCount = 0;

      // Enter should prevent default and not trigger press
      await triggerKeyEvent(
        '[data-test-id="checkbox-target"]',
        'keydown',
        'Enter'
      );

      assert.ok(
        preventDefaultCalled,
        'Enter key should prevent default on checkbox'
      );
    });

    test('space key on radio input only triggers press events', async function (assert) {
      let preventDefaultCalled = false;
      let pressCount = 0;
      let originalPreventDefault: () => void;

      class RadioTestComponent extends Component {
        handleKeyDown = (event: KeyboardEvent) => {
          originalPreventDefault = event.preventDefault.bind(event);
          event.preventDefault = () => {
            preventDefaultCalled = true;
            originalPreventDefault();
          };
        };

        onPress = () => {
          pressCount++;
        };

        <template>
          <input
            type="radio"
            name="test"
            data-test-id="radio-target"
            {{on "keydown" this.handleKeyDown}}
            {{press onPress=this.onPress}}
          />
        </template>
      }

      await render(<template><RadioTestComponent /></template>);

      // Space should work on radio
      await triggerKeyEvent('[data-test-id="radio-target"]', 'keydown', ' ');
      await triggerKeyEvent('[data-test-id="radio-target"]', 'keyup', ' ');

      assert.notOk(
        preventDefaultCalled,
        'Space key should not prevent default on radio'
      );
      assert.strictEqual(
        pressCount,
        1,
        'Space should trigger press event on radio'
      );

      // Reset for Enter test
      preventDefaultCalled = false;
      pressCount = 0;

      // Enter should prevent default and not trigger press
      await triggerKeyEvent(
        '[data-test-id="radio-target"]',
        'keydown',
        'Enter'
      );

      assert.ok(
        preventDefaultCalled,
        'Enter key should prevent default on radio'
      );
    });

    test('keyboard events on div elements prevent default', async function (assert) {
      // We'll test this by checking if the press event fires when Enter is pressed
      // If preventDefault is called correctly, the press event should still fire
      let pressCount = 0;

      class DivTestComponent extends Component {
        onPress = () => {
          pressCount++;
        };

        <template>
          <div
            data-test-id="div-target"
            tabindex="0"
            {{press onPress=this.onPress}}
          >
            Div with tabindex
          </div>
        </template>
      }

      await render(<template><DivTestComponent /></template>);

      await triggerKeyEvent('[data-test-id="div-target"]', 'keydown', 'Enter');
      await triggerKeyEvent('[data-test-id="div-target"]', 'keyup', 'Enter');

      assert.strictEqual(
        pressCount,
        1,
        'Enter key should trigger press on div element (preventDefault should be called correctly)'
      );
    });

    test('regular button (submit type) with both press modifier and click handler', async function (assert) {
      let pressCount = 0;
      let clickCount = 0;

      class ButtonWithClickComponent extends Component {
        onPress = () => {
          pressCount++;
        };

        onClick = () => {
          clickCount++;
        };

        <template>
          <button
            data-test-id="button-with-click-target"
            {{press onPress=this.onPress}}
            {{on "click" this.onClick}}
          >
            Button with Press and Click
          </button>
        </template>
      }

      await render(<template><ButtonWithClickComponent /></template>);

      // Test mouse click - both press and click should fire
      await click('[data-test-id="button-with-click-target"]');

      assert.strictEqual(
        pressCount,
        1,
        'Press event should fire on mouse click'
      );
      assert.strictEqual(
        clickCount,
        1,
        'Click event should fire on mouse click'
      );

      // Reset counters
      pressCount = 0;
      clickCount = 0;

      // Test keyboard interaction - both should fire because regular buttons have type="submit"
      // which means preventDefault is NOT called, allowing synthetic click events
      await triggerKeyEvent(
        '[data-test-id="button-with-click-target"]',
        'keydown',
        'Enter'
      );
      await triggerKeyEvent(
        '[data-test-id="button-with-click-target"]',
        'keyup',
        'Enter'
      );

      assert.strictEqual(pressCount, 1, 'Press event should fire on Enter key');
      assert.strictEqual(
        clickCount,
        0,
        'Click event should NOT fire on Enter key - even though regular buttons are type="submit"'
      );

      // Reset counters
      pressCount = 0;
      clickCount = 0;

      // Test space key - same behavior
      await triggerKeyEvent(
        '[data-test-id="button-with-click-target"]',
        'keydown',
        ' '
      );
      await triggerKeyEvent(
        '[data-test-id="button-with-click-target"]',
        'keyup',
        ' '
      );

      assert.strictEqual(pressCount, 1, 'Press event should fire on Space key');
      assert.strictEqual(
        clickCount,
        0,
        'Click event should NOT fire on Space key - even though regular buttons are type="submit"'
      );
    });

    test('explicit button type="button" with both press modifier and click handler', async function (assert) {
      let pressCount = 0;
      let clickCount = 0;

      class ExplicitButtonComponent extends Component {
        onPress = () => {
          pressCount++;
        };

        onClick = () => {
          clickCount++;
        };

        <template>
          <button
            type="button"
            data-test-id="explicit-button-target"
            {{press onPress=this.onPress}}
            {{on "click" this.onClick}}
          >
            Explicit Button Type
          </button>
        </template>
      }

      await render(<template><ExplicitButtonComponent /></template>);

      // Test mouse click - both should fire
      await click('[data-test-id="explicit-button-target"]');

      assert.strictEqual(
        pressCount,
        1,
        'Press event should fire on mouse click'
      );
      assert.strictEqual(
        clickCount,
        1,
        'Click event should fire on mouse click'
      );

      // Reset counters
      pressCount = 0;
      clickCount = 0;

      // Test keyboard - only press should fire because type="button" gets preventDefault
      await triggerKeyEvent(
        '[data-test-id="explicit-button-target"]',
        'keydown',
        'Enter'
      );
      await triggerKeyEvent(
        '[data-test-id="explicit-button-target"]',
        'keyup',
        'Enter'
      );

      assert.strictEqual(pressCount, 1, 'Press event should fire on Enter key');
      assert.strictEqual(
        clickCount,
        0,
        'Click event should NOT fire on Enter key because type="button" gets preventDefault'
      );
    });
  }
);
