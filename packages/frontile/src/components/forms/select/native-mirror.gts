import Component from '@glimmer/component';
import {
  NativeSelect,
  type ListItem,
  type NativeSelectSignature
} from '../native-select';

const eq = (a: unknown, b: unknown) => a === b;

interface SelectNativeMirrorSignature<T> {
  Args: {
    /**
     * The **unfiltered** collection. The mirror carries the form value, which
     * must not shrink to whatever the listbox filter currently shows, so it is
     * deliberately never handed `filteredItems`.
     */
    items?: T[];
    allowEmpty?: boolean;
    disabledKeys?: string[];
    selectionMode?: 'single' | 'multiple';

    /** Read in multiple selection mode. */
    selectedKeys: string[];
    /** Read in single selection mode. */
    selectedKey: string | null;

    /** Selection handler for multiple selection mode. */
    onSelectionChange: (keys: string[]) => void;
    /** Selection handler for single selection mode. */
    onSingleSelectionChange: (key: string | null) => void;

    onItemsChange: (nodes: ListItem[], action: 'add' | 'remove') => void;
    placeholder?: string;
    id?: string;
    name?: string;
    isDisabled?: boolean;
  };
  Blocks: {
    default: NativeSelectSignature<T>['Blocks']['default'];
  };
}

/**
 * The visually hidden native `<select>` that makes a Select submit with a form.
 *
 * Single and multiple selection mode differ only in three arguments, so those
 * three are curried onto the component and everything else -- the element, its
 * attributes and both blocks -- is written **once**. Two copies of this used to
 * sit side by side in `select.gts`, and a fix to the submitted value landed in
 * one of them and not the other.
 */
class SelectNativeMirror<T = unknown> extends Component<
  SelectNativeMirrorSignature<T>
> {
  <template>
    {{#let
      (if
        (eq @selectionMode "multiple")
        (component
          NativeSelect
          selectionMode="multiple"
          selectedKeys=@selectedKeys
          onSelectionChange=@onSelectionChange
        )
        (component
          NativeSelect
          selectionMode="single"
          selectedKey=@selectedKey
          onSelectionChange=@onSingleSelectionChange
        )
      )
      as |Mirror|
    }}
      <Mirror
        @items={{@items}}
        @allowEmpty={{@allowEmpty}}
        @disabledKeys={{@disabledKeys}}
        @onItemsChange={{@onItemsChange}}
        @placeholder={{@placeholder}}
        @id={{@id}}
        @name={{@name}}
        tabindex="-1"
        disabled={{@isDisabled}}
      >
        <:item as |l|>
          <l.Item @key={{l.key}}>
            {{l.label}}
          </l.Item>
        </:item>
        <:default as |l|>
          {{yield l}}
        </:default>
      </Mirror>
    {{/let}}
  </template>
}

export { SelectNativeMirror, type SelectNativeMirrorSignature };
export default SelectNativeMirror;
