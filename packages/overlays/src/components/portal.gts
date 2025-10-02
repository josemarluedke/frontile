import Component from '@glimmer/component';
import { getDOM, getElementById, getElementByAttribute } from '../-private/dom';
import type { TOC } from '@ember/component/template-only';
import { guidFor } from '@ember/object/internals';
import { isTesting, macroCondition } from '@embroider/macros';
import { PortalTarget } from './portal-target';

const MaybeInElement: TOC<{
  Args: {
    destinationElement?: Element | null;
    renderInPlace?: boolean;
  };
  Blocks: {
    default: [];
  };
}> = <template>
  {{#if @renderInPlace}}
    {{yield}}
  {{else if @destinationElement}}
    {{#in-element @destinationElement insertBefore=null}}
      {{yield}}
    {{/in-element}}
  {{/if}}
</template>;

interface PortalSignature {
  Args: {
    /**
     * Whether to render in place or in the specified/default destination
     *
     * @defaultValue false
     */
    renderInPlace?: boolean;

    /**
     * The target where to render the portal.
     * There are 3 options: 1) `Element` object, 2) element id, 3) portal target name.
     *
     * For element id, string must be prefixed with `#`.
     * If no value is passed in, we will render to the closest unnamed portal target,
     * parent portal or `document.body`.
     */
    target?: string | Element;

    /**
     * @defaultValue true
     */
    appendToParentPortal?: boolean;
  };
  Element: HTMLDivElement;
  Blocks: { default: [] };
}

function findParentPortal(origin: Element | null): Element | null {
  if (!origin) {
    return null;
  }

  let parent = origin.parentElement;
  while (parent) {
    if (parent.getAttribute('data-portal') === 'true') {
      return parent;
    }

    parent = parent.parentElement;
  }

  return null;
}

function findClosestPortalTarget(
  element: Element | null,
  name?: string
): Element | null {
  if (!element) {
    return null;
  }

  let parent = element.parentElement;
  while (parent) {
    if (name) {
      const target = getElementByAttribute(parent, 'data-portal-for', name);
      if (target) {
        return target;
      }
    }
    const target = getElementByAttribute(parent, 'data-portal-target', 'true');
    if (target && target.getAttribute('data-portal-for') === null) {
      return target;
    }
    parent = parent.parentElement;
  }

  return null;
}

class Portal extends Component<PortalSignature> {
  id = guidFor(this);
  dom = getDOM(this);

  get destinationElement(): Element | null {
    const doc = this.dom;
    if (!doc) {
      return null;
    }

    if (this.args.target) {
      if (typeof this.args.target === 'string') {
        if (this.args.target[0] === '#') {
          return getElementById(doc, this.args.target.replace('#', ''));
        }

        const namedTarget = findClosestPortalTarget(
          this.portalMarker,
          this.args.target
        );
        if (namedTarget) {
          return namedTarget;
        }
      } else if (typeof this.args.target === 'object') {
        return this.args.target;
      }
    }

    let containerEl: Element = doc.body;

    if (macroCondition(isTesting())) {
      const testingContainer = getElementById(doc, 'ember-testing');
      if (testingContainer) {
        containerEl = testingContainer;
      }
    }

    if (this.args.appendToParentPortal !== false) {
      const parentPortal = findParentPortal(this.portalMarker);
      if (parentPortal) {
        return parentPortal;
      }
    }

    const portalTarget = findClosestPortalTarget(this.portalMarker);
    if (portalTarget) {
      return portalTarget;
    }

    return containerEl;
  }

  get portalMarker(): Element | null {
    const doc = this.dom;
    if (!doc) {
      return null;
    }

    return getElementById(doc, this.id);
  }

  needsTarget = (destEl: Element | null): boolean => {
    if (this.args.renderInPlace || this.args.target) {
      return false;
    }

    return (
      !!destEl &&
      destEl.getAttribute('data-portal-target') !== 'true' &&
      destEl.getAttribute('data-portal') !== 'true'
    );
  };

  <template>
    <script type="x/portal-marker" id={{this.id}}></script>

    {{#let this.destinationElement as |destinationElement|}}
      <MaybeInElement
        @renderInPlace={{@renderInPlace}}
        @destinationElement={{destinationElement}}
      >
        {{#if (this.needsTarget destinationElement)}}
          <PortalTarget>
            <div data-portal="true" ...attributes>
              {{yield}}
            </div>
          </PortalTarget>
        {{else}}
          <div data-portal="true" ...attributes>
            {{yield}}
          </div>
        {{/if}}
      </MaybeInElement>
    {{/let}}
  </template>
}

export { Portal, type PortalSignature, findParentPortal };
export default Portal;
