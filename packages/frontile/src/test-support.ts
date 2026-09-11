import { triggerEvent } from '@ember/test-helpers';

export function selectOptionByKey(
  selectSelector: string,
  key: string
): Promise<void> {
  return changeOption('selectOptionByKey', selectSelector, key, false);
}

export function toggleOptionByKey(
  selectSelector: string,
  key: string
): Promise<void> {
  return changeOption('toggleOptionByKey', selectSelector, key, true);
}

function changeOption(
  functionName: string,
  selectSelector: string,
  key: string,
  toggle: boolean
): Promise<void> {
  const container = document.querySelector(selectSelector);

  if (!container) {
    throw new Error(
      `You called "${functionName}('${selectSelector}', '${key}')" but no select was found using selector "${selectSelector}"`
    );
  }

  let select: Element | null = container;
  if (container.tagName !== 'SELECT') {
    // `data-component="native-select"` lives on FormControl's root element,
    // not the `<select>` itself (the anatomy contract puts `data-component`
    // only on a component's outermost element, and the `<select>` is a
    // *part* of `native-select`, not its root). `data-test-id="native-select"`
    // stays directly on the `<select>` tag, so it is the stable way to reach
    // it from an arbitrary ancestor container.
    select = container.querySelector('[data-test-id="native-select"]');
  }

  if (!select) {
    throw new Error(
      `You called "${functionName}('${selectSelector}', '${key}')" but no select was found inside container using selector "${selectSelector}"`
    );
  }

  const option = select.querySelector(`[data-key="${key}"]`) as
    HTMLOptionElement | undefined;
  if (!option) {
    throw new Error(
      `You called "${functionName}('${selectSelector}', '${key}')" but no option with key "${key}" was found`
    );
  }

  if (toggle && option.selected) {
    option.selected = false;
  } else {
    option.selected = true;
  }

  return triggerEvent(select, 'change');
}

export { setPrefersReducedMotion } from './utils/prefers-reduced-motion';
