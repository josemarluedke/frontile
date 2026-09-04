import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { Listbox } from '../listbox/listbox';
import { Spinner } from '../../utilities/spinner';
import { Divider } from '../../utilities/divider';
import { keyAndLabelForItem, type ListItem } from '../../../utils/listManager';
import type { CommandGroup } from './command';
import type { ListboxItem } from '../listbox/item';
import type { CommandSlots, SlotsToClasses } from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';

type ItemCompBounded = WithBoundArgs<typeof ListboxItem, 'manager'>;

interface RenderableGroup<T> extends CommandGroup<T> {
  /** Separator between sections; never after the last one. */
  withDivider: boolean;
}

export interface CommandListSignature<T> {
  Args: {
    /** @internal bound by Command */
    groups?: CommandGroup<T>[];
    /** @internal bound by Command */
    id?: string;
    /** @internal bound by Command */
    isLoading?: boolean;
    /** @internal bound by Command */
    isSearchPrompt?: boolean;
    /** @internal bound by Command */
    inputElement?: HTMLInputElement;
    /** @internal bound by Command */
    onSelect?: (key: string) => void;
    /** @internal bound by Command */
    onActiveItemChange?: (key?: string, item?: ListItem) => void;

    disabledKeys?: string[];
    size?: 'sm' | 'md' | 'lg';
    classes?: SlotsToClasses<CommandSlots>;
  };
  Element: HTMLUListElement;
  Blocks: {
    item: [{ item: T; key: string; label: string; Item: ItemCompBounded }];
    empty: [];
    loading: [];
    /** Shown by an async palette before anything has been typed. */
    prompt: [];
  };
}

/**
 * Renders the ranked results.
 *
 * Sections come from the ranked data rather than from markup, so a group whose
 * items all filtered out is simply not rendered — heading, wrapper and
 * separator disappear together, with no visibility tracking or `forceMount`
 * escape hatch. Reordering is a keyed `{{#each}}` over a sorted array, which
 * Glimmer handles natively.
 */
class CommandList<T = unknown> extends Component<CommandListSignature<T>> {
  @cached
  get groups(): RenderableGroup<T>[] {
    const groups = this.args.groups ?? [];

    return groups.map((group, index) => ({
      ...group,
      withDivider: index < groups.length - 1
    }));
  }

  get isEmpty(): boolean {
    return this.groups.length === 0;
  }

  /** Loading only replaces the list while there is nothing to show yet. */
  get showLoading(): boolean {
    return Boolean(this.args.isLoading) && this.isEmpty;
  }

  get classNames() {
    const { command, listboxGroup } = useStyles();
    // No size fallback: the theme's `defaultVariants` owns the default.
    return {
      ...command({ size: this.args.size }),
      // Same spacing a Group gives its own separator, so the ungrouped run
      // does not drift from the grouped one.
      divider: listboxGroup().divider()
    };
  }

  <template>
    {{#if this.showLoading}}
      <div
        class={{this.classNames.loading class=@classes.loading}}
        data-test-id="command-loading"
      >
        {{#if (has-block "loading")}}
          {{yield to="loading"}}
        {{else}}
          <Spinner @size="sm" />
          Searching…
        {{/if}}
      </div>
    {{else if @isSearchPrompt}}
      <div
        class={{this.classNames.empty class=@classes.empty}}
        data-test-id="command-prompt"
      >
        {{#if (has-block "prompt")}}
          {{yield to="prompt"}}
        {{else}}
          Start typing to search.
        {{/if}}
      </div>
    {{else if this.isEmpty}}
      <div
        class={{this.classNames.empty class=@classes.empty}}
        data-test-id="command-empty"
        role="status"
      >
        {{#if (has-block "empty")}}
          {{yield to="empty"}}
        {{else}}
          No results found.
        {{/if}}
      </div>
    {{else}}
      <Listbox
        id={{@id}}
        @selectionMode="none"
        @type="listbox"
        @isKeyboardEventsEnabled={{true}}
        @autoActivateMode="first"
        @disabledKeys={{@disabledKeys}}
        @onAction={{@onSelect}}
        @onActiveItemChange={{@onActiveItemChange}}
        @elementToAddKeyboardEvents={{@inputElement}}
        @class={{this.classNames.list class=@classes.list}}
        data-test-id="command-list"
        ...attributes
        as |l|
      >
        {{#each this.groups key="@index" as |group|}}
          {{#if group.title}}
            <l.Group
              @title={{group.title}}
              @withDivider={{group.withDivider}}
              as |g|
            >
              {{#each group.items as |item|}}
                {{#let (keyAndLabelForItem item) as |keyLabel|}}
                  {{yield
                    (hash
                      item=item
                      key=keyLabel.key
                      label=keyLabel.label
                      Item=g.Item
                    )
                    to="item"
                  }}
                {{/let}}
              {{/each}}
            </l.Group>
          {{else}}
            {{#each group.items as |item|}}
              {{#let (keyAndLabelForItem item) as |keyLabel|}}
                {{yield
                  (hash
                    item=item key=keyLabel.key label=keyLabel.label Item=l.Item
                  )
                  to="item"
                }}
              {{/let}}
            {{/each}}
            {{! Ungrouped items render without a Group wrapper, so their
                separator has to come from here or it goes missing. }}
            {{#if group.withDivider}}
              <Divider @as="li" @class={{this.classNames.divider}} />
            {{/if}}
          {{/if}}
        {{/each}}
      </Listbox>
    {{/if}}
  </template>
}

export { CommandList };
export default CommandList;
