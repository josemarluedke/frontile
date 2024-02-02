import Modifier, { type ArgsFor } from 'ember-modifier';
import { registerDestructor } from '@ember/destroyable';
import { ListManager, type NodeArgs } from './listManager';

interface SetupListItemModifierSignature {
  Args: {
    Positional: [manager: ListManager];
    Named: Pick<NodeArgs, 'key' | 'textValue'>;
  };
  Element: HTMLLIElement;
}

class SetupListItem extends Modifier<SetupListItemModifierSignature> {
  element?: HTMLLIElement;
  manager?: ListManager;

  /* eslint-disable-next-line */
  constructor(owner: any, args: ArgsFor<SetupListItemModifierSignature>) {
    super(owner, args);
    registerDestructor(this, this.unregister);
  }

  modify(
    element: HTMLLIElement,
    [manager]: [ListManager],
    args: ArgsFor<SetupListItemModifierSignature>['named']
  ): void {
    if (!this.element) {
      this.register(element, manager, args);
    } else {
      this.update(args);
    }
  }

  update = (args: ArgsFor<SetupListItemModifierSignature>['named']): void => {
    const node = this.manager?.at(this.element);
    if (node) {
      const prevKey = node.key;
      if (args.textValue) {
        node.textValue = args.textValue;
      }

      if (prevKey !== args.key) {
        node.key = args.key;
        node.isDisabled = this.manager?.isKeyDisabled(args.key) || false;
        node.isSelected = this.manager?.isKeySelected(args.key) || false;
      }
    }
  };

  register = (
    el: HTMLLIElement,
    manager: ListManager,
    args: ArgsFor<SetupListItemModifierSignature>['named']
  ): void => {
    this.element = el;
    this.manager = manager;

    let textValue = args.textValue;
    if (
      typeof textValue === 'undefined' ||
      textValue === '' ||
      textValue === null
    ) {
      textValue = el.textContent?.trim();
    }
    manager.register(el as HTMLLIElement, {
      key: args.key,
      textValue: textValue || '',
      isActive: false,
      isDisabled: manager.isKeyDisabled(args.key),
      isSelected: manager.isKeySelected(args.key)
    });

    el.addEventListener('mouseenter', this.mouseEnter);
    el.addEventListener('mouseleave', this.mouseLeave);
  };

  unregister = (instance: SetupListItem): void => {
    const { element, manager } = instance;

    if (element && manager) {
      manager.unregister(element);

      instance.element = undefined;
      instance.manager = undefined;

      element.addEventListener('mouseenter', instance.mouseEnter);
      element.addEventListener('mouseleave', instance.mouseLeave);
    }
  };

  mouseEnter = (): void => {
    if (this.element && this.manager) {
      const node = this.manager.at(this.element);
      this.manager.activateNode(node);
    }
  };

  mouseLeave = (): void => {
    if (this.element && this.manager) {
      const node = this.manager.at(this.element);
      if (node) {
        node.isActive = false;
      }
    }
  };
}

export { SetupListItem };
