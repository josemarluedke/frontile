import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { modifier } from 'ember-modifier';
import { twMerge } from '@frontile/theme';
import type { TOC } from '@ember/component/template-only';
import type { ComponentLike } from '@glint/template';
import type { CloseButtonSignature } from '../../buttons/close-button';

export interface DrawerHeaderIconSignature {
  Args: {
    /**
     * @internal
     */
    classFromParent?: string;
    class?: string;
  };
  Element: HTMLDivElement;
  Blocks: { default: [] };
}

// `data-drawer-header-icon` and `data-drawer-header-description` are what the
// theme's header grid keys its icon alignment off: the icon spans both text
// rows only when a description is actually rendered (see `headerContent` in
// `overlays.ts`). They are structural hooks, not state, so they are always on.
const DrawerHeaderIcon: TOC<DrawerHeaderIconSignature> = <template>
  <div
    class={{twMerge @classFromParent @class}}
    data-drawer-header-icon
    ...attributes
  >
    {{yield}}
  </div>
</template>;

export interface DrawerHeaderTitleSignature {
  Args: {
    /**
     * Fallback content, used when this component is given no block.
     */
    value?: string;

    /**
     * @internal
     */
    classFromParent?: string;
    class?: string;
  };
  Element: HTMLDivElement;
  Blocks: { default: [] };
}

class DrawerHeaderTitle extends Component<DrawerHeaderTitleSignature> {
  <template>
    <div class={{twMerge @classFromParent @class}} ...attributes>
      {{#if (has-block)}}{{yield}}{{else}}{{@value}}{{/if}}
    </div>
  </template>
}

export interface DrawerHeaderDescriptionSignature {
  Args: {
    /**
     * Fallback content, used when this component is given no block.
     */
    value?: string;

    /**
     * @internal
     */
    classFromParent?: string;
    class?: string;
  };
  Element: HTMLDivElement;
  Blocks: { default: [] };
}

class DrawerHeaderDescription extends Component<DrawerHeaderDescriptionSignature> {
  <template>
    <div
      class={{twMerge @classFromParent @class}}
      data-drawer-header-description
      ...attributes
    >
      {{#if (has-block)}}{{yield}}{{else}}{{@value}}{{/if}}
    </div>
  </template>
}

export interface DrawerHeaderArgs {
  /**
   * The id used to reference labelledById in Drawer component
   */
  labelledById: string;

  /**
   * Header title. Rendered into the themed title slot when the header is given
   * no block, and used as the fallback content for a blockless `<h.Title />`.
   */
  title?: string;

  /**
   * Header description, shown under the title. Behaves like `@title`.
   */
  description?: string;

  class?: string;

  /**
   * @internal
   */
  classFromParent?: string;

  /**
   * @internal
   */
  iconClass?: string;

  /**
   * @internal
   */
  titleClass?: string;

  /**
   * @internal
   */
  descriptionClass?: string;

  /**
   * @internal
   */
  contentClass?: string;

  /**
   * @internal
   */
  actionsClass?: string;

  /**
   * Called with `true` when this header is rendered and `false` when it is
   * removed, so the Drawer knows whether it may point `aria-labelledby` at us.
   *
   * @internal
   */
  registerSelf?: (isRendered: boolean) => void;

  /**
   * The Drawer's close button, fully bound and rendered inside the header's
   * own grid so it can be centred against the header's actual height. Only
   * present when the Drawer should show a close button at all.
   *
   * @internal
   */
  closeButton?: ComponentLike<CloseButtonSignature>;
}

export interface DrawerHeaderSignature {
  Args: DrawerHeaderArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [
      {
        Icon: ComponentLike<DrawerHeaderIconSignature>;
        Title: ComponentLike<DrawerHeaderTitleSignature>;
        Description: ComponentLike<DrawerHeaderDescriptionSignature>;
      }
    ];

    /**
     * Controls placed beside the close button. Rendered in flow, so a taller
     * control makes the header band taller -- unlike the close button, which
     * is positioned out of flow precisely so it never does.
     */
    actions: [];
  };
}

export default class DrawerHeader extends Component<DrawerHeaderSignature> {
  register = modifier(() => {
    this.args.registerSelf?.(true);

    return () => {
      this.args.registerSelf?.(false);
    };
  });

  <template>
    <div
      id={{@labelledById}}
      class={{twMerge @classFromParent @class}}
      {{this.register}}
      ...attributes
    >
      <div class={{@contentClass}}>
        {{#if (has-block)}}
          {{yield
            (hash
              Icon=(component DrawerHeaderIcon classFromParent=@iconClass)
              Title=(component
                DrawerHeaderTitle classFromParent=@titleClass value=@title
              )
              Description=(component
                DrawerHeaderDescription
                classFromParent=@descriptionClass
                value=@description
              )
            )
          }}
        {{else}}
          {{#if @title}}
            <div class={{@titleClass}}>{{@title}}</div>
          {{/if}}
          {{#if @description}}
            <div class={{@descriptionClass}} data-drawer-header-description>
              {{@description}}
            </div>
          {{/if}}
        {{/if}}
      </div>

      {{! Only rendered when there is something to put in it: an empty flex
      child would still consume the header's gap, leaving a phantom space to
      the right of the title on every plain header. }}
      {{#if (has-block "actions")}}
        <div class={{@actionsClass}}>
          {{yield to="actions"}}
        </div>
      {{/if}}

      {{#if @closeButton}}
        <@closeButton />
      {{/if}}
    </div>
  </template>
}

export { DrawerHeaderIcon, DrawerHeaderTitle, DrawerHeaderDescription };
