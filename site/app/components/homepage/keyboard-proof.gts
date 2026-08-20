import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { Listbox } from 'frontile';

/**
 * Demonstrates the accessibility claim instead of asserting it.
 *
 * The Listbox below is the shipped component with no extra wiring. The readout
 * reports what the visitor's own keystrokes did and reflects the ARIA state
 * Frontile put on the DOM — so "full keyboard navigation" and "proper ARIA" are
 * things the page shows rather than adjectives it lists.
 *
 * The readout is deliberately NOT a live region. The Listbox already announces
 * the active option through `aria-activedescendant`; adding a polite region
 * that echoes every keystroke would double-narrate the one demo on this page
 * whose point is that the component's own ARIA is correct. It is a visual
 * explainer for sighted users, so it is hidden from assistive tech.
 */

const items: string[] = [
  'Ember Octane',
  'Glimmer components',
  'Template tag (.gts)',
  'Glint type checking',
  'Tailwind Variants'
];

const NAMED_KEYS: Record<string, string> = {
  ArrowDown: 'ArrowDown → move to next option',
  ArrowUp: 'ArrowUp → move to previous option',
  Home: 'Home → jump to first option',
  End: 'End → jump to last option',
  Enter: 'Enter → select the active option',
  ' ': 'Space → select the active option',
  Escape: 'Escape → clear the active option'
};

export default class KeyboardProof extends Component {
  items = items;

  @tracked lastKey = 'Focus the list, then use the arrow keys.';
  @tracked selectedKeys: string[] = ['Glint type checking'];

  get selectedLabel(): string {
    return this.selectedKeys[0] ?? 'nothing';
  }

  @action
  handleKeyDown(event: KeyboardEvent): void {
    const described = NAMED_KEYS[event.key];

    if (described) {
      this.lastKey = described;
    } else if (event.key.length === 1) {
      this.lastKey = `"${event.key}" → typeahead to a matching option`;
    }
  }

  @action
  handleSelectionChange(keys: string[]): void {
    this.selectedKeys = keys;
  }

  <template>
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 items-start">
      <div class="rounded-lg border border-neutral-soft bg-surface-app p-2">
        {{! The listener goes on the Listbox's own <ul role="listbox">, which it
            splats attributes onto — not on a wrapper div, which would be an
            interaction bound to a non-interactive element. }}
        <Listbox
          {{on "keydown" this.handleKeyDown}}
          @isKeyboardEventsEnabled={{true}}
          @intent="primary"
          @items={{this.items}}
          @selectionMode="single"
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.handleSelectionChange}}
        />
      </div>

      <div>
        <p
          class="font-label text-label-2xs text-neutral-firm uppercase mb-2"
        >What just happened</p>
        <p
          class="font-code text-code-sm text-neutral-strong min-h-12"
          aria-hidden="true"
        >{{this.lastKey}}</p>

        <p class="font-body text-body-sm text-neutral-firm mt-4">
          Selected:
          <span class="text-neutral-strong">{{this.selectedLabel}}</span>. The
          list manages
          <code
            class="font-code text-code-sm text-primary-firm"
          >aria-activedescendant</code>, roving focus, typeahead, and
          <code
            class="font-code text-code-sm text-primary-firm"
          >aria-selected</code>
          itself — none of that is wired up on this page.
        </p>
      </div>
    </div>
  </template>
}
