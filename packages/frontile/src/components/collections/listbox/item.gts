import Component from '@glimmer/component';
import { tracked, cached } from '@glimmer/tracking';
import { action } from '@ember/object';
import { assert } from '@ember/debug';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';
import { Divider } from '../../utilities/divider';
import { Kbd } from '../../utilities/kbd';
import type { KbdSignature } from '../../utilities/kbd';
import { guidFor } from '@ember/object/internals';
import type { TOC } from '@ember/component/template-only';
import type { ListManager, ListItem } from '../../../utils/listManager';
import { renamedArgValue } from '../../../-private/deprecated-args';

export interface ListboxItemSignature {
  Args: {
    manager: ListManager;
    key: string;
    textValue?: string;

    /**
     * The entry of `@items` this option renders, remembered on the registered
     * list item so a selection can hand it back. Bound for you on the Item
     * yielded from the `:item` block; block-form options have no such entry.
     */
    item?: unknown;

    description?: string;

    /**
     * A keyboard shortcut shown at the end of the option, rendered by `Kbd`.
     * Accepts named keys (`"mod+k"`) or a literal string (`"⌘K"`).
     */
    shortcut?: string;

    /**
     * The variant of the rendered shortcut. Defaults to `inherit`, so the
     * keycap follows the option's own colour on active and filled rows.
     *
     * @defaultValue 'inherit'
     */
    shortcutVariant?: KbdSignature['Args']['variant'];
    onClick?: () => void;
    class?: string;
    withDivider?: boolean;

    /**
     * The variant of each item.
     *
     * @defaultValue 'solid'
     */
    variant?: 'solid' | 'outline' | 'subtle';

    /**
     * @deprecated Use `variant`. `default` is now `solid`, `outlined` is
     * `outline`, and `faded` is `subtle`.
     */
    appearance?: 'default' | 'outlined' | 'faded';

    /**
     * The intent of each item
     */
    intent?:
      | 'default'
      | 'primary'
      | 'secondary'
      | 'tertiary'
      | 'success'
      | 'warning'
      | 'danger';

    type?: 'menu' | 'listbox';

    /**
     * Marks this option as the trigger for a submenu.
     *
     * It stops the option selecting: opening a submenu is not choosing
     * anything, so `onAction` and `onSelectionChange` must not fire for it.
     * The option still registers with the `ListManager` and so still takes
     * part in arrow navigation, type-ahead and the roving tab stop.
     *
     * Renders `aria-haspopup="menu"` and a trailing chevron, unless an `:end`
     * block supplies its own trailing content.
     */
    hasSubmenu?: boolean;

    /**
     * Whether this option's submenu is currently open. Only meaningful
     * alongside `@hasSubmenu`; drives `aria-expanded` and the highlighted
     * resting state via `data-submenu-open`.
     */
    isSubmenuOpen?: boolean;

    /**
     * The id of the `role="menu"` element this option opens, for
     * `aria-controls`. Only meaningful alongside `@hasSubmenu`.
     */
    submenuId?: string;
  };
  Element: HTMLLIElement;
  Blocks: {
    default: [];
    selectedIcon: [];
    start: [];
    end: [];
  };
}

class ListboxItem extends Component<ListboxItemSignature> {
  // Stable element id so consumers (e.g. Autocomplete) can reference the
  // option via aria-activedescendant.
  itemId = `${guidFor(this)}-option`;
  labelId = guidFor(this);
  @tracked listItem?: ListItem;

  get manager(): ListManager {
    assert(
      `ListboxItem does not have a listManager; Missing argument @manager`,
      this.args.manager
    );

    return this.args.manager;
  }

  get key(): string {
    assert(
      `Argument @key is undefined or null, @key must be provided in Listbox.Item component`,
      this.args.key
    );

    return this.args.key;
  }

  @action
  onRegister(item: ListItem) {
    this.listItem = item;
  }

  @action
  onClick(): void {
    if (this.listItem?.isDisabled) {
      return;
    }

    // Opening a submenu is not choosing anything, so a sub-trigger must not
    // reach `selectItem` -- that is what fires `onAction` and
    // `onSelectionChange`. It still registers as an item, so arrow
    // navigation, type-ahead and the roving tab stop are unaffected.
    if (!this.args.hasSubmenu) {
      this.manager.selectItem(this.listItem);
    }

    if (typeof this.args.onClick === 'function') {
      this.args.onClick();
    }
  }

  /**
   * A roving tabindex: the manager nominates one option as the composite's tab
   * stop and every other option stays out of the tab order, as the ARIA
   * listbox pattern requires. Giving a `0` to each active *or selected* option
   * turned a multi-select with eight selections into eight tab stops.
   */
  get tabindex() {
    return this.manager.isTabStop(this.key) ? 0 : -1;
  }

  /**
   * Resolved once per render (`@cached`) so referencing it from both
   * `classNames` and `submenuIndicatorClass` does not fire the deprecation
   * twice for the same item.
   */
  @cached
  get variant(): 'solid' | 'outline' | 'subtle' {
    return (
      renamedArgValue(
        this.args.variant,
        this.args.appearance,
        { default: 'solid', outlined: 'outline', faded: 'subtle' } as const,
        {
          component: 'Listbox',
          from: 'appearance',
          to: 'variant',
          id: 'frontile.listbox.appearance'
        }
      ) || 'solid'
    );
  }

  get classNames() {
    const { listboxItem } = useStyles();

    const { base, descriptionWrapper, label, description, selectedIcon } =
      listboxItem({
        variant: this.variant,
        intent: this.args.intent || 'default',
        isDisabled: this.listItem?.isDisabled,
        isSelected: this.listItem?.isSelected,
        isActive: this.listItem?.isActive,
        withDivider: this.args.withDivider
      });

    return {
      base: base({ class: this.args.class }),
      descriptionWrapper: descriptionWrapper(),
      label: label(),
      description: description(),
      selectedIcon: selectedIcon()
    };
  }

  /**
   * The `submenuIndicator` slot is only ever rendered on a sub-trigger, so it
   * is looked up here rather than in `classNames`, and only when
   * `@hasSubmenu` is set — a plain item never pays for it.
   *
   * `registerCustomStyles` (`packages/theme/src/index.ts`) shallow-replaces:
   * a consumer supplying their own `listboxItem` via `tv({...})` swaps out
   * the whole config, not just the slots they mention. `tv()` in turn only
   * produces a function for a slot it was actually given. So a third-party
   * override written before this slot existed has no `submenuIndicator` key
   * at all, and calling it would throw. A published component library must
   * not crash a consumer's app over a stale override, so this stays
   * defensive — but the check now only runs for sub-triggers, not for every
   * item on every render.
   */
  get submenuIndicatorClass(): string | undefined {
    if (!this.args.hasSubmenu) {
      return undefined;
    }

    const { listboxItem } = useStyles();
    const { submenuIndicator } = listboxItem({
      variant: this.variant,
      intent: this.args.intent || 'default',
      isDisabled: this.listItem?.isDisabled,
      isSelected: this.listItem?.isSelected,
      isActive: this.listItem?.isActive,
      withDivider: this.args.withDivider
    });

    return typeof submenuIndicator === 'function'
      ? submenuIndicator()
      : undefined;
  }

  get shortcutVariant() {
    return this.args.shortcutVariant ?? 'inherit';
  }

  get role() {
    if (this.args.type === 'menu') {
      return 'menuitem';
    }
    return 'option';
  }

  /**
   * `aria-selected` belongs on `option`, and only there — a plain `menuitem`
   * that carries it is invalid ARIA, since menu items convey state through
   * `aria-checked` and only as `menuitemcheckbox`/`menuitemradio`. Returning
   * undefined omits the attribute rather than rendering an empty one.
   */
  get ariaSelected(): 'true' | 'false' | undefined {
    if (this.role !== 'option') {
      return undefined;
    }
    return this.listItem?.isSelected ? 'true' : 'false';
  }

  /**
   * `aria-haspopup="menu"` rather than the bare `"true"`: both are valid, but
   * the explicit role tells a screen reader what is about to open.
   */
  get ariaHasPopup(): 'menu' | undefined {
    return this.args.hasSubmenu ? 'menu' : undefined;
  }

  /**
   * Only a row that owns a popup has an expanded state. Rendering
   * `aria-expanded` on a plain `menuitem` would be invalid ARIA, so this is
   * undefined -- and therefore omitted -- unless `@hasSubmenu` is set.
   */
  /**
   * `aria-expanded` and `data-submenu-open` share this same value — one is
   * the ARIA state for assistive tech, the other a styling hook for the
   * template's own resting/hover state — so both getters delegate here.
   */
  get submenuOpenState(): 'true' | 'false' | undefined {
    if (!this.args.hasSubmenu) {
      return undefined;
    }
    return this.args.isSubmenuOpen ? 'true' : 'false';
  }

  get ariaExpanded(): 'true' | 'false' | undefined {
    return this.submenuOpenState;
  }

  get dataSubmenuOpen(): 'true' | 'false' | undefined {
    return this.submenuOpenState;
  }

  <template>
    <li
      {{this.manager.setupItem
        key=this.key
        textValue=@textValue
        item=@item
        onRegister=this.onRegister
      }}
      {{on "click" this.onClick}}
      id={{this.itemId}}
      role={{this.role}}
      aria-labelledby={{this.labelId}}
      aria-selected={{this.ariaSelected}}
      aria-haspopup={{this.ariaHasPopup}}
      aria-expanded={{this.ariaExpanded}}
      aria-controls={{if @hasSubmenu @submenuId}}
      data-submenu-open={{this.dataSubmenuOpen}}
      tabindex={{this.tabindex}}
      data-active="{{this.listItem.isActive}}"
      data-selected="{{this.listItem.isSelected}}"
      data-component="listbox-item"
      data-part="base"
      data-key={{this.key}}
      aria-disabled={{if this.listItem.isDisabled "true"}}
      class={{this.classNames.base}}
      ...attributes
    >
      {{yield to="start"}}

      {{#if @description}}
        <div
          data-part="description-wrapper"
          class={{this.classNames.descriptionWrapper}}
        >
          <span
            data-part="label"
            class={{this.classNames.label}}
            id={{this.labelId}}
          >{{yield}}</span>
          <span
            data-part="description"
            class={{this.classNames.description}}
          >{{@description}}</span>
        </div>
      {{else}}
        <span
          data-part="label"
          class={{this.classNames.label}}
          id={{this.labelId}}
        >{{yield}}</span>
      {{/if}}

      {{#if @shortcut}}
        <Kbd
          @keys={{@shortcut}}
          @size="sm"
          @variant={{this.shortcutVariant}}
          data-test-id="listbox-item-shortcut"
        />
      {{/if}}

      {{#if this.listItem.isSelected}}
        <span data-part="selected-icon" class={{this.classNames.selectedIcon}}>
          {{#if (has-block "selectedIcon")}}
            {{yield to="selectedIcon"}}
          {{else}}
            <CheckIcon class="h-full w-full" />
          {{/if}}
        </span>
      {{/if}}

      {{#if @hasSubmenu}}
        {{#unless (has-block "end")}}
          <span
            data-part="submenu-indicator"
            class={{this.submenuIndicatorClass}}
          >
            <ChevronRightIcon class="h-full w-full" />
          </span>
        {{/unless}}
      {{/if}}

      {{yield to="end"}}
    </li>
    {{#if @withDivider}}
      <Divider @as="li" />
    {{/if}}
  </template>
}

const CheckIcon: TOC<{
  Element: SVGElement;
}> = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    stroke-width="1.5"
    stroke="currentColor"
    ...attributes
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="m4.5 12.75 6 6 9-13.5"
    />
  </svg>
</template>;

const ChevronRightIcon: TOC<{
  Element: SVGElement;
}> = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    stroke-width="1.5"
    stroke="currentColor"
    ...attributes
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="m8.25 4.5 7.5 7.5-7.5 7.5"
    />
  </svg>
</template>;

export { ListboxItem };
