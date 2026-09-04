import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { guidFor } from '@ember/object/internals';
import { useStyles } from '@frontile/theme';
import { Divider } from '../../utilities/divider';
import { ListboxItem } from './item';
import type { ListManager } from '../../../utils/listManager';
import type { ListboxItemSignature } from './item';
import type { WithBoundArgs } from '@glint/template';

type ItemCompBounded = WithBoundArgs<
  typeof ListboxItem,
  'manager' | 'type' | 'appearance' | 'intent'
>;

export interface ListboxGroupSignature {
  Args: {
    manager: ListManager;

    /**
     * The heading rendered above the group's options. When omitted, the group
     * still groups its options but renders no heading — and carries no
     * `aria-labelledby`, since there would be nothing to point at.
     */
    title?: string;

    class?: string;
    classes?: {
      base?: string;
      title?: string;
      list?: string;
    };

    /**
     * Render a divider after the group. Groups in a palette are usually
     * separated visually; the divider is a sibling of the group rather than a
     * child so it does not sit inside the group's labelled region.
     */
    withDivider?: boolean;

    type?: ListboxItemSignature['Args']['type'];
    appearance?: ListboxItemSignature['Args']['appearance'];
    intent?: ListboxItemSignature['Args']['intent'];
  };
  Element: HTMLLIElement;
  Blocks: {
    default: [{ Item: ItemCompBounded }];
  };
}

/**
 * A labelled section of options within a `Listbox`.
 *
 * The markup nests the options one level deeper than an ungrouped listbox, so
 * the intervening list is marked `role="none"` to keep the
 * `listbox` -> `option` ownership chain intact.
 *
 * Grouping deliberately adds no concepts to `ListManager`: navigation order is
 * derived from the live DOM via `compareDocumentPosition`, so nesting options
 * inside a group leaves keyboard traversal across group boundaries correct by
 * construction.
 */
class ListboxGroup extends Component<ListboxGroupSignature> {
  titleId = `${guidFor(this)}-title`;

  get classNames() {
    const { listboxGroup } = useStyles();
    const { base, title, list } = listboxGroup();

    return {
      base: base({ class: [this.args.class, this.args.classes?.base] }),
      title: title({ class: this.args.classes?.title }),
      list: list({ class: this.args.classes?.list })
    };
  }

  <template>
    <li
      role="group"
      aria-labelledby={{if @title this.titleId}}
      data-test-id="listbox-group"
      data-component="listbox-group"
      class={{this.classNames.base}}
      ...attributes
    >
      {{#if @title}}
        <span
          id={{this.titleId}}
          data-test-id="listbox-group-title"
          class={{this.classNames.title}}
        >{{@title}}</span>
      {{/if}}

      <ul role="none" class={{this.classNames.list}}>
        {{yield
          (hash
            Item=(component
              ListboxItem
              manager=@manager
              appearance=@appearance
              intent=@intent
              type=@type
            )
          )
        }}
      </ul>
    </li>

    {{#if @withDivider}}
      <Divider @as="li" @class="my-1" />
    {{/if}}
  </template>
}

export { ListboxGroup };
export default ListboxGroup;
