import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { guidFor } from '@ember/object/internals';
import { standaloneStyles, type AppLayoutContext } from './context';

interface MainArgs {
  /**
   * Supplied by `AppLayout`. Not part of the public API.
   *
   * @internal
   */
  layout?: AppLayoutContext;
}

interface MainSignature {
  Args: MainArgs;
  Blocks: { default: [] };
  Element: HTMLElement;
}

/**
 * The page's `main` landmark. Inside `AppLayout` it fills the content area
 * and, by default, scrolls on its own; the skip link moves focus here.
 */
class Main extends Component<MainSignature> {
  get id(): string {
    return this.args.layout?.mainId ?? `${guidFor(this)}-main`;
  }

  @cached
  get classNames(): string {
    const styles = this.args.layout?.styles ?? standaloneStyles();
    return styles.main({ class: this.args.layout?.classes?.main });
  }

  <template>
    <main
      id={{this.id}}
      tabindex="-1"
      data-part="main"
      class={{this.classNames}}
      ...attributes
    >
      {{yield}}
    </main>
  </template>
}

export { Main, type MainSignature, type MainArgs };
export default Main;
