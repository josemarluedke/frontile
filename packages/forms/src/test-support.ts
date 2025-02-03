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
    select = container.querySelector('[data-component="native-select"]');
  }

  if (!select) {
    throw new Error(
      `You called "${functionName}('${selectSelector}', '${key}')" but no select was found inside of of container using selector "${selectSelector}"`
    );
  }

  const option = select.querySelector(`[data-key="${key}"]`) as
    | HTMLOptionElement
    | undefined;
  if (!option) {
    throw new Error(
      `You called "${functionName}('${selectSelector}', '${key}')" but no option with key "${key}" was found`
    );
  }
  if (option.selected && toggle) {
    option.selected = false;
  } else {
    option.selected = true;
  }
  return triggerEvent(select, 'change');
}
