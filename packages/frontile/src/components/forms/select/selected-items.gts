import { concat, fn } from '@ember/helper';
import type { TOC } from '@ember/component/template-only';
import type { ModifierLike } from '@glint/template';
import type { SlotsToClasses, SelectSlots } from '@frontile/theme';
import { Chip } from '../../buttons/chip';
import type {
  ResolvedSelectChipOptions,
  SelectClasses,
  SelectedItem,
  SelectedItemBlockArg
} from './types';

/**
 * The selection rendered as text: one string, so a `<span>` holding it stays a
 * single text node.
 */
const joinTextValues = (items: SelectedItem[]): string =>
  items.map((item) => item.textValue).join(', ');

/**
 * Maps the internal {@link SelectedItem} projection onto what the `:item`
 * block here -- and, through it, the Select's `:selectedItem` block -- is
 * handed: `{ item, key, label }`, the same shape the `:item` block of the
 * listbox yields, so markup moves between the two unchanged.
 *
 * `item` is `unknown` at this level (it comes off the registered option
 * nodes), so it is typed `never` to stay assignable to the consumer's own `T`
 * when Select re-yields it. It is optional either way: an option written in
 * block form has no collection entry behind it.
 */
const toBlockArg = (item: SelectedItem): SelectedItemBlockArg<never> => ({
  item: item.item as never,
  key: item.key,
  label: item.textValue
});

/** Whether a comma separator is needed before this selection. */
const isNotFirst = (index: number): boolean => index > 0;

interface SelectedTextSignature {
  Args: {
    /** The selection, in item order. */
    items: SelectedItem[];

    /**
     * Whether the `:item` block is the consumer's own content rather than the
     * fallback the Select fills it with.
     *
     * A block cannot be passed conditionally in Glimmer, so the Select always
     * supplies one; this is how the plain presentation stays *exactly* what it
     * was -- the whole selection as one joined string in a single text node --
     * instead of becoming a per-item loop that merely renders the same
     * characters.
     */
    hasCustomContent?: boolean;
  };
  Blocks: {
    /** Content for one selected option, in place of its text. */
    item: [SelectedItemBlockArg<never>];
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
    {{#if @hasCustomContent}}
      {{#each @items key="key" as |item index|}}
        {{~#if (isNotFirst index)}}, {{/if~}}
        {{~yield (toBlockArg item) to="item"~}}
      {{/each}}
    {{else}}
      {{joinTextValues @items}}
    {{/if}}
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
  Blocks: {
    /**
     * The body of one chip, in place of the option's text. The chip chrome --
     * its appearance, its dot and its close button -- is not the block's to
     * replace, so it stays put around whatever is rendered here.
     */
    item: [SelectedItemBlockArg<never>];
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
 *
 * The close button's title is built from `textValue`, never from the block, so
 * a chip whose body is purely graphical is still announced as "Remove <label>".
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
        {{yield (toBlockArg item) to="item"}}
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
