import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { Listbox } from '../listbox/listbox';
import { Spinner } from '../../utilities/spinner';
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
    const { command } = useStyles();
    return command({ size: this.args.size || 'md' });
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
          {{/if}}
        {{/each}}
      </Listbox>
    {{/if}}
  </template>
}

export { CommandList };
export default CommandList;
