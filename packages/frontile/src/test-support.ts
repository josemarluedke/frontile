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

/**
 * Selects the elements bearing `[data-part="${part}"]` whose *own* anatomy
 * root is `root` — i.e. `root` is the nearest `[data-component]` ancestor.
 *
 * `[data-component="X"] [data-part="Y"]` (plain CSS descendant combinator)
 * matches "any descendant", which is ambiguous whenever a component with a
 * part named `Y` renders a nested component that also has an element
 * carrying `data-part="Y"` (its own part, or a caller-supplied one on the
 * nested component's root). CSS has no "nearest enclosing" combinator, so
 * this helper resolves ownership the same way behavioural code would have
 * to: walk up from the part element and confirm the nearest
 * `[data-component]` ancestor is `root`.
 *
 * The walk starts at `el.parentElement`, not `el` itself, deliberately:
 * `el` may itself be a nested component's root (e.g. `CloseButton`, which
 * carries its own `data-component="close-button"` on the very element that
 * also carries a caller-supplied `data-part="clear-button"` or
 * `data-part="close-button"`). Starting `closest()`/the walk from `el`
 * would match `el` itself and never reach `root`, wrongly excluding a part
 * that legitimately belongs to `root`.
 */
export function ownParts(root: Element, part: string): Element[] {
  return [...root.querySelectorAll(`[data-part="${part}"]`)].filter((el) => {
    let node = el.parentElement;
    while (node && node !== root) {
      if (node.hasAttribute('data-component')) return false;
      node = node.parentElement;
    }
    return node === root;
  });
}
