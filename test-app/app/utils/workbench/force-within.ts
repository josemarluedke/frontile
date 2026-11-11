import { modifier } from 'ember-modifier';

interface ForceWithinSignature {
  Element: Element;
  Args: { Positional: [attribute: string | null, selector: string] };
}

/**
 * Sets a force attribute on a descendant instead of the element itself:
 * `{{forceWithin cell.attribute '[data-part="input"]'}}`.
 *
 * For controls whose `...attributes` lands on a wrapper while the focus style
 * sits on an inner element (Select's trigger button). `cell.force` would put
 * the attribute on the wrapper, where nothing reads it. A `null` attribute
 * does nothing, so it can be bound straight to `cell.attribute`.
 */
const forceWithin = modifier<ForceWithinSignature>(
  (element, [attribute, selector]): (() => void) | undefined => {
    if (!attribute) {
      return;
    }
    const target = element.querySelector(selector);
    if (!target) {
      return;
    }
    target.setAttribute(attribute, '');
    return () => target.removeAttribute(attribute);
  }
);

export default forceWithin;
