import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { guidFor } from '@ember/object/internals';
import { useStyles } from '@frontile/theme';

/** Class names `Sidebar` hands each group. */
export interface SidebarGroupClasses {
  sidebarGroup: string;
  sidebarGroupLabel: string;
}

interface SidebarGroupArgs {
  /**
   * The group's heading. It is shown above the items and names the group for
   * assistive technology. In the icon rail it is visually hidden.
   */
  label: string;

  /** Class names appended to this group's theme classes. */
  class?: string;

  /**
   * Supplied by `Sidebar`. Not part of the public API. Without it (a group
   * rendered on its own) the standalone sidebar's classes are used.
   *
   * @internal
   */
  classes?: SidebarGroupClasses;
}

interface SidebarGroupSignature {
  Args: SidebarGroupArgs;
  Blocks: {
    /** The group's items. */
    default: [];
  };
  Element: HTMLDivElement;
}

/**
 * A labelled set of sidebar items: a `group` named by its visible `@label`.
 */
class SidebarGroup extends Component<SidebarGroupSignature> {
  labelId = `${guidFor(this)}-label`;

  @cached
  get classes(): SidebarGroupClasses {
    if (this.args.classes) {
      return this.args.classes;
    }
    const styles = useStyles().appLayout({
      variant: 'attached',
      standalone: true
    });
    return {
      sidebarGroup: styles.sidebarGroup(),
      sidebarGroupLabel: styles.sidebarGroupLabel()
    };
  }

  get className(): string {
    return this.args.class
      ? `${this.classes.sidebarGroup} ${this.args.class}`
      : this.classes.sidebarGroup;
  }

  <template>
    <div
      data-part="sidebar-group"
      role="group"
      aria-labelledby={{this.labelId}}
      class={{this.className}}
      ...attributes
    >
      <div
        id={{this.labelId}}
        data-part="sidebar-group-label"
        data-sidebar-label
        class={{this.classes.sidebarGroupLabel}}
      >{{@label}}</div>
      {{yield}}
    </div>
  </template>
}

export { SidebarGroup, type SidebarGroupSignature, type SidebarGroupArgs };
export default SidebarGroup;
