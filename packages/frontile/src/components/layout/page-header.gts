import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { standaloneStyles, type AppLayoutContext } from './context';

interface PageHeaderArgs {
  /** The page title, rendered as the page's `h1`. */
  title?: string;

  /** A short line under the title. */
  description?: string;

  /**
   * Supplied by `AppLayout`. Not part of the public API.
   *
   * @internal
   */
  layout?: AppLayoutContext;
}

interface PageHeaderSignature {
  Args: PageHeaderArgs;
  Blocks: {
    /** Extra content under the title and description. */
    default: [];
    /** Buttons or links for the page, aligned to the end of the row. */
    actions: [];
  };
  Element: HTMLDivElement;
}

/**
 * The title row at the top of a page: title, description and actions. Place
 * it inside `Main`.
 */
class PageHeader extends Component<PageHeaderSignature> {
  @cached
  get classes() {
    const styles = this.args.layout?.styles ?? standaloneStyles();
    const custom = this.args.layout?.classes;

    return {
      pageHeader: styles.pageHeader({ class: custom?.pageHeader }),
      pageHeaderContent: styles.pageHeaderContent({
        class: custom?.pageHeaderContent
      }),
      pageHeaderTitle: styles.pageHeaderTitle({
        class: custom?.pageHeaderTitle
      }),
      pageHeaderDescription: styles.pageHeaderDescription({
        class: custom?.pageHeaderDescription
      }),
      pageHeaderActions: styles.pageHeaderActions({
        class: custom?.pageHeaderActions
      })
    };
  }

  <template>
    <div
      data-part="page-header"
      class={{this.classes.pageHeader}}
      ...attributes
    >
      <div
        data-part="page-header-content"
        class={{this.classes.pageHeaderContent}}
      >
        {{#if @title}}
          <h1
            data-part="page-header-title"
            class={{this.classes.pageHeaderTitle}}
          >
            {{@title}}
          </h1>
        {{/if}}
        {{#if @description}}
          <p
            data-part="page-header-description"
            class={{this.classes.pageHeaderDescription}}
          >
            {{@description}}
          </p>
        {{/if}}
        {{yield}}
      </div>
      {{#if (has-block "actions")}}
        <div
          data-part="page-header-actions"
          class={{this.classes.pageHeaderActions}}
        >
          {{yield to="actions"}}
        </div>
      {{/if}}
    </div>
  </template>
}

export { PageHeader, type PageHeaderSignature, type PageHeaderArgs };
export default PageHeader;
