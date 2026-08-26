import { concat, fn } from '@ember/helper';
import type { TOC } from '@ember/component/template-only';
import type { ModifierLike } from '@glint/template';
import type { SlotsToClasses, SelectSlots } from '@frontile/theme';
import { Chip } from '../../buttons/chip';
import type {
  ResolvedSelectChipOptions,
  SelectClasses,
  SelectedItem
} from './types';

/**
 * The selection rendered as text: one string, so a `<span>` holding it stays a
 * single text node.
 */
const joinTextValues = (items: SelectedItem[]): string =>
  items.map((item) => item.textValue).join(', ');

interface SelectedTextSignature {
  Args: {
    /** The selection, in item order. */
    items: SelectedItem[];
  };
  Element: HTMLSpanElement;
}

/**
 * The selection presented as a comma-joined string, inside the trigger.
 *
 * The text presentation and the chips presentation are the two renderings of
 * one selection, so they live in one file and read the same
 * {@link SelectedItem} projection.
 */
const SelectedText: TOC<SelectedTextSignature> = <template>
  <span ...attributes>
    {{joinTextValues @items}}
  </span>
</template>;

interface SelectedChipsSignature {
  Args: {
    /** The selection, in item order, so chips do not reorder as they are picked. */
    items: SelectedItem[];

    /**
     * Installed on the chips container. The field click forwarder reads this
     * ref to tell a chip body apart from a chip close button structurally,
     * without depending on any attribute.
     */
    containerRef: ModifierLike<{ Element: HTMLDivElement }>;

    classes: SelectClasses;
    userClasses?: SlotsToClasses<SelectSlots>;
    chipOptions: ResolvedSelectChipOptions;
    isDisabled?: boolean;

    /**
     * Whether a chip may be removed at all. When false the chip renders with no
     * close button rather than a dead one.
     */
    isRemovable: boolean;

    onRemove: (key: string) => void;
  };
  Element: HTMLDivElement;
}

/**
 * The selection presented as a row of removable {@link Chip}s beside the
 * trigger.
 *
 * The close buttons are deliberately outside the tab order
 * (`@closeButtonTabIndex="-1"`) so the trigger keeps the first Tab stop in the
 * field; Backspace on the field is the keyboard route to removal.
 */
const SelectedChips: TOC<SelectedChipsSignature> = <template>
  <div
    {{@containerRef}}
    data-test-id="selected-chips"
    class={{@classes.chipsContainer class=@userClasses.chipsContainer}}
    ...attributes
  >
    {{#each @items key="key" as |item|}}
      <Chip
        data-test-id="selected-chip"
        data-key={{item.key}}
        @class={{@classes.chip class=@userClasses.chip}}
        @appearance={{@chipOptions.appearance}}
        @intent={{@chipOptions.intent}}
        @size={{@chipOptions.size}}
        @radius={{@chipOptions.radius}}
        @withDot={{@chipOptions.withDot}}
        @isDisabled={{@isDisabled}}
        @closeButtonTitle={{concat "Remove " item.textValue}}
        @closeButtonTabIndex="-1"
        @onClose={{if @isRemovable (fn @onRemove item.key)}}
      >
        {{item.textValue}}
      </Chip>
    {{/each}}
  </div>
</template>;

export {
  SelectedChips,
  SelectedText,
  type SelectedChipsSignature,
  type SelectedTextSignature
};
