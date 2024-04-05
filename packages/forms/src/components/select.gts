import Component from '@glimmer/component';
import type { TOC } from '@ember/component/template-only';
import { tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import { NativeSelect, type ListItem } from './native-select';
import { Listbox, type ListboxSignature } from '@frontile/collections';
import {
  useStyles,
  type SelectSlots,
  type SelectVariants,
  type SlotsToClasses
} from '@frontile/theme';
import { VisuallyHidden } from '@frontile/utilities';
import {
  Popover,
  type PopoverSignature,
  type ContentSignature
} from '@frontile/overlays';
import { FormControl, type FormControlSharedArgs } from './form-control';
import { triggerFormInputEvent } from '../utils';

interface SelectArgs<T>
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
    >,
    FormControlSharedArgs {
  selectionMode?: 'single' | 'multiple';

  id?: string;
  inputSize?: SelectVariants['size'];
  popoverSize?: 'sm' | 'md' | 'lg';
  classes?: SlotsToClasses<SelectSlots>;

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

  placeholder?: string;

  isDisabled?: boolean;

  name?: string;
}

interface SelectSignature<T> {
  Args: SelectArgs<T>;
  Element: HTMLDivElement;
  Blocks: ListboxSignature<T>['Blocks'];
}

class Select<T = unknown> extends Component<SelectSignature<T>> {
  @tracked nodes: ListItem[] = [];
  @tracked isOpen = false;
  @tracked _selectedKeys: string[] = this.args.selectedKeys || [];

  el: HTMLElement | null = null;

  registerEl = modifier((element: HTMLElement) => {
    this.el = element;
  });

  get selectedKeys(): string[] {
    if (
      typeof this.args.selectedKeys !== 'undefined' &&
      typeof this.args.onSelectionChange === 'function'
    ) {
      return this.args.selectedKeys;
    }

    return this._selectedKeys;
  }

  onSelectionChange = (keys: string[]) => {
    if (typeof this.args.onSelectionChange === 'function') {
      this.args.onSelectionChange(keys);
    } else {
      this._selectedKeys = keys;
    }

    triggerFormInputEvent(this.el);
  };

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
    return this.selectedKeys?.join(', ');
  }

  onItemsChange = (nodes: ListItem[], _: 'add' | 'remove') => {
    this.nodes = nodes;
  };

  get selectedTextValue(): string {
    let selectedTextValues: string[] = [];
    for (let node of this.nodes) {
      if (this.selectedKeys?.includes(node.key)) {
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

  get classes() {
    const { select } = useStyles();
    return select({
      size: this.args.inputSize
    });
  }

  <template>
    <div
      {{this.registerEl}}
      class={{this.classes.base class=@classes.base}}
      ...attributes
    >
      <FormControl
        @id={{@id}}
        @size={{@inputSize}}
        @label={{@label}}
        @isRequired={{@isRequired}}
        @description={{@description}}
        @errors={{@errors}}
        @isInvalid={{@isInvalid}}
        as |c|
      >
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
              @onSelectionChange={{this.onSelectionChange}}
              @selectedKeys={{this.selectedKeys}}
              @selectionMode={{if @selectionMode @selectionMode "single"}}
              @onItemsChange={{this.onItemsChange}}
              @placeholder={{@placeholder}}
              @id={{c.id}}
              @name={{@name}}
              tabindex="-1"
              disabled={{@isDisabled}}
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
            type="button"
            {{p.trigger}}
            {{p.anchor}}
            data-test-id="trigger"
            data-component="select-trigger"
            disabled={{@isDisabled}}
            class={{this.classes.trigger class=@classes.trigger}}
          >
            {{#if this.selectedText}}
              <span>
                {{this.selectedTextValue}}
              </span>
            {{else}}
              <span
                class={{this.classes.placeholder class=@classes.placeholder}}
              >
                {{@placeholder}}
              </span>
            {{/if}}

            <Icon class={{this.classes.icon class=@classes.icon}} />
          </button>

          <p.Content
            @size={{@popoverSize}}
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
              @onSelectionChange={{this.onSelectionChange}}
              @selectedKeys={{this.selectedKeys}}
              @selectionMode={{if @selectionMode @selectionMode "single"}}
              @type="listbox"
              @class={{this.classes.listbox class=@classes.listbox}}
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
      </FormControl>
    </div>
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
