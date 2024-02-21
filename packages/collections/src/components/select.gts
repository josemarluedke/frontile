import Component from '@glimmer/component';
import type { TOC } from '@ember/component/template-only';
import { tracked } from '@glimmer/tracking';
import { NativeSelect } from './native-select';
import { Listbox, type ListboxSignature, type ListItemNode } from './listbox';
import { useStyles } from '@frontile/theme';
import { VisuallyHidden } from '@frontile/utilities';
import {
  Popover,
  type PopoverSignature,
  type ContentSignature
} from '@frontile/overlays';

interface SelectArgs<T = unknown>
  extends Pick<
      PopoverSignature['Args'],
      | 'placement'
      | 'flipOptions'
      | 'middleware'
      | 'shiftOptions'
      | 'offsetOptions'
      | 'strategy'
      | 'didClose'
    >,
    Pick<
      ListboxSignature<T>['Args'],
      | 'appearance'
      | 'intent'
      | 'class'
      | 'selectedKeys'
      | 'disabledKeys'
      | 'allowEmpty'
      | 'onSelectionChange'
      | 'items'
      | 'onAction'
    >,
    Pick<
      ContentSignature['Args'],
      | 'renderInPlace'
      | 'destinationElementId'
      | 'transitionDuration'
      | 'backdrop'
      | 'disableTransitions'
      | 'focusTrapOptions'
      | 'closeOnOutsideClick'
      | 'closeOnEscapeKey'
      | 'backdropTransition'
      | 'transition'
    > {
  selectionMode?: 'single' | 'multiple';

  /**
   * Whether the select should close upon selecting an item.
   *
   * @defaultValue true
   */
  closeOnItemSelect?: boolean;
  /**
   * @defaultValue true
   */
  blockScroll?: boolean;

  /**
   * @defaultValue false
   */
  disableFocusTrap?: boolean;
}

interface SelectSignature {
  Args: SelectArgs;
  Element: HTMLUListElement | HTMLSelectElement;
  Blocks: ListboxSignature['Blocks'];
}

class Select extends Component<SelectSignature> {
  @tracked nodes: ListItemNode[] = [];
  @tracked isOpen = false;

  onOpenChange = (isOpen: boolean) => {
    this.isOpen = isOpen;
  };

  get blockScroll() {
    if (this.args.blockScroll === false) {
      return false;
    }
    return true;
  }

  get disableFocusTrap() {
    if (this.args.disableFocusTrap === true) {
      return true;
    }
    return false;
  }

  onAction = (key: string) => {
    if (typeof this.args.onAction === 'function') {
      this.args.onAction(key);
    }

    if (
      this.args.closeOnItemSelect !== false &&
      this.args.selectionMode !== 'multiple'
    ) {
      this.isOpen = false;
    }
  };

  get selectedText() {
    return this.args.selectedKeys?.join(', ');
  }

  onItemsChange = (nodes: ListItemNode[], _: 'add' | 'remove') => {
    this.nodes = nodes;
  };

  get selectedTextValue(): string {
    let selectedTextValues: string[] = [];
    for (let node of this.nodes) {
      if (this.args.selectedKeys?.includes(node.key)) {
        selectedTextValues.push(node.textValue);
      }
    }
    return selectedTextValues.join(', ');
  }

  get backdrop() {
    if (typeof this.args.backdrop === 'undefined') {
      return 'transparent';
    }
    return this.args.backdrop;
  }

  get classNames() {
    const { select } = useStyles();
    const { base, icon, listbox } = select();
    return {
      base: base({ class: this.args.class }),
      icon: icon(),
      listbox: listbox()
    };
  }

  <template>
    <Popover
      @placement={{@placement}}
      @flipOptions={{@flipOptions}}
      @middleware={{@middleware}}
      @shiftOptions={{@shiftOptions}}
      @offsetOptions={{@offsetOptions}}
      @strategy={{@strategy}}
      @didClose={{@didClose}}
      @isOpen={{this.isOpen}}
      @onOpenChange={{this.onOpenChange}}
      as |p|
    >
      <VisuallyHidden>
        <NativeSelect
          @items={{@items}}
          @allowEmpty={{@allowEmpty}}
          @disabledKeys={{@disabledKeys}}
          @onSelectionChange={{@onSelectionChange}}
          @selectedKeys={{@selectedKeys}}
          @selectionMode={{if @selectionMode @selectionMode "single"}}
          @onItemsChange={{this.onItemsChange}}
          ...attributes
        >
          <:item as |l|>
            {{#if (has-block "item")}}
              {{! @glint-expect-error: the signature of the native select item is not the same as the listtbox item}}
              {{yield l to="item"}}
            {{else}}
              <l.Item @key={{l.key}}>
                {{l.label}}
              </l.Item>
            {{/if}}
          </:item>
          <:default as |l|>
            {{! @glint-expect-error: the signature of the native select is not the same as the listtbox}}
            {{yield l to="default"}}
          </:default>
        </NativeSelect>
      </VisuallyHidden>

      <button
        {{p.trigger}}
        {{p.anchor}}
        data-test-id="trigger"
        class={{this.classNames.base}}
      >
        <span>
          {{this.selectedTextValue}}
        </span>

        <Icon class={{this.classNames.icon}} />
      </button>

      <p.Content
        @destinationElementId={{@destinationElementId}}
        @renderInPlace={{@renderInPlace}}
        @disableFocusTrap={{this.disableFocusTrap}}
        @blockScroll={{this.blockScroll}}
        @transitionDuration={{@transitionDuration}}
        @backdrop={{this.backdrop}}
        @disableTransitions={{@disableTransitions}}
        @focusTrapOptions={{@focusTrapOptions}}
        @closeOnOutsideClick={{@closeOnOutsideClick}}
        @closeOnEscapeKey={{@closeOnEscapeKey}}
        @backdropTransition={{@backdropTransition}}
        @transition={{@transition}}
      >
        <Listbox
          @items={{@items}}
          @allowEmpty={{@allowEmpty}}
          @appearance={{@appearance}}
          @disabledKeys={{@disabledKeys}}
          @intent={{@intent}}
          @isKeyboardEventsEnabled={{true}}
          @onAction={{this.onAction}}
          @onSelectionChange={{@onSelectionChange}}
          @selectedKeys={{@selectedKeys}}
          @selectionMode={{if @selectionMode @selectionMode "single"}}
          @type="listbox"
          @class={{this.classNames.listbox}}
          ...attributes
        >
          <:item as |l|>
            {{#if (has-block "item")}}
              {{yield l to="item"}}
            {{else}}
              <l.Item
                @key={{l.key}}
                @appearance={{@appearance}}
                @intent={{@intent}}
              >
                {{l.label}}
              </l.Item>
            {{/if}}
          </:item>
          <:default as |l|>
            {{yield l to="default"}}
          </:default>
        </Listbox>
      </p.Content>
    </Popover>
  </template>
}

const Icon: TOC<{
  Element: SVGElement;
}> = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    stroke-width="1.5"
    stroke="currentColor"
    aria-hidden="true"
    ...attributes
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="M8.25 15 12 18.75 15.75 15m-7.5-6L12 5.25 15.75 9"
    />
  </svg>
</template>;

export { Select, type SelectSignature };
export default Select;
