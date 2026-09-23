import { triggerEvent, focus, triggerKeyEvent } from '@ember/test-helpers';
import { parseDate } from './components/forms/date-picker/value';

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

/**
 * Types a date into a segmented `DateInput` or `DatePicker`.
 *
 * `fillIn` cannot do this and, worse, does not fail when you try. The segments
 * are `contenteditable`, so `fillIn` writes their text and fires `input`
 * without complaint -- but the component renders from its own segments and
 * listens only to `beforeinput`/`keydown`, so nothing reaches the value. The
 * result is a test that reads green, whose `assert.dom(...).hasText('01')`
 * even passes, while the component's value stayed `null` and the form would
 * submit empty.
 *
 * This types the digits segment by segment the way a person does, so the value
 * composes through the same commit path as real input.
 *
 * ```js
 * await fillDate('[data-test-due]', '2026-01-20');
 * await fillDate('[data-test-due]', new Date(2026, 0, 20));
 * ```
 *
 * For `@mode="range"` use {@link fillDateRange}.
 */
export function fillDate(
  selector: string,
  value: Date | string
): Promise<void> {
  return fillGroup('fillDate', selector, value, 0);
}

/**
 * Types both ends of a range into a segmented `DatePicker @mode="range"`.
 *
 * ```js
 * await fillDateRange('[data-test-trip]', '2026-01-20', '2026-01-25');
 * ```
 */
export async function fillDateRange(
  selector: string,
  start: Date | string,
  end: Date | string
): Promise<void> {
  await fillGroup('fillDateRange', selector, start, 0);
  await fillGroup('fillDateRange', selector, end, 1);
}

/**
 * Reuses the component's own parser rather than restating the wire format, so
 * the helper cannot drift from what `@value` actually accepts -- but turns a
 * refusal into a thrown error, since a test helper handed a bad date should
 * say so rather than quietly fill nothing.
 */
function asDate(functionName: string, value: Date | string): Date {
  const parsed = parseDate(value);
  if (!parsed) {
    throw new Error(
      `You called "${functionName}" with "${String(value)}", which is neither a Date nor a yyyy-MM-dd string.`
    );
  }

  return parsed;
}

async function fillGroup(
  functionName: string,
  selector: string,
  value: Date | string,
  which: 0 | 1
): Promise<void> {
  const container = document.querySelector(selector);
  if (!container) {
    throw new Error(
      `You called "${functionName}('${selector}', ...)" but no element was found using selector "${selector}".`
    );
  }

  const group = container.querySelectorAll('[data-part="group"]')[which];

  if (!group) {
    // Far and away the likeliest cause: the field is on the button-trigger
    // path, where there is nothing to type into at all.
    const hasButtonTrigger = container.querySelector('[data-part="input"]');
    throw new Error(
      hasButtonTrigger
        ? `You called "${functionName}('${selector}', ...)" on a date field rendering its button trigger, which cannot be typed into. Drop @isEditable={{false}}, or click the trigger and pick from the calendar.`
        : `You called "${functionName}('${selector}', ...)" but found no date segments inside "${selector}".`
    );
  }

  const date = asDate(functionName, value);
  const digits: Record<string, string> = {
    year: String(date.getFullYear()).padStart(4, '0'),
    month: String(date.getMonth() + 1).padStart(2, '0'),
    day: String(date.getDate()).padStart(2, '0')
  };

  for (const segment of group.querySelectorAll('[data-part="segment"]')) {
    const element = segment as HTMLElement;
    const run = element.dataset['type']
      ? digits[element.dataset['type']]
      : undefined;
    if (!run) continue;

    await focus(element);
    for (const digit of run) {
      await triggerKeyEvent(element, 'keydown', digit);
    }
  }
}
