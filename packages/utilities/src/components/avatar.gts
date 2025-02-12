import Component from '@glimmer/component';
import {
  useStyles,
  type AvatarVariants,
  type AvatarSlots,
  type SlotsToClasses
} from '@frontile/theme';

interface AvatarSignature {
  Args: {
    /**
     * Controls the size of the avatar.
     *
     * @defaultValue 'md'
     */
    size?: AvatarVariants['size'];

    /**
     * Defines the shape of the avatar.
     *
     * @defaultValue 'circle'
     */
    shape?: AvatarVariants['shape'];

    /**
     * URL of the image to be displayed in the avatar.
     * If provided, the image will be used instead of initials.
     *
     */
    src?: string | null;

    /**
     * Full name of the user, used to generate initials.
     * If `@firstName` and `@lastName` are not provided, initials will be
     * derived from this property.
     */
    name?: string;

    /**
     * First name of the user, used to generate initials.
     * If `@name` is not provided, initials will be generated from
     * `@firstName` and `@lastName`.
     */
    firstName?: string;

    /**
     * Last name of the user, used to generate initials.
     * If `@name` is not provided, initials will be generated from
     * `@firstName` and `@lastName`.
     */
    lastName?: string;

    /**
     * Alternative text for accessibility.
     * If `@src` is provided, this text will be used as the `alt`
     * attribute for the image.
     * If only initials are displayed, this text will be read by screen readers.
     */
    alt?: string;

    /**
     * Custom CSS classes for styling different slots within the avatar component.
     */
    classes?: SlotsToClasses<AvatarSlots>;
  };

  /**
   * The root element of the avatar component, which is an HTML `<span>` tag.
   */
  Element: HTMLSpanElement;
}

class Avatar extends Component<AvatarSignature> {
  get classes() {
    const { avatar } = useStyles();
    return avatar({
      size: this.args.size,
      shape: this.args.shape
    });
  }

  get initials() {
    const { name, firstName, lastName } = this.args;

    if (name) {
      return name
        .trim()
        .split(/\s+/)
        .slice(0, 2)
        .map((word) => word.charAt(0))
        .join('')
        .toUpperCase();
    }

    const initials = [firstName?.charAt(0), lastName?.charAt(0)]
      .filter(Boolean)
      .join('')
      .toUpperCase();

    return initials;
  }

  get shouldShowInitials() {
    const { src, name, firstName, lastName } = this.args;
    if (src) {
      return false;
    }

    return Boolean(name || firstName || lastName);
  }

  <template>
    <span
      class={{this.classes.base class=@classes.base}}
      data-component="avatar"
      ...attributes
    >
      {{#if this.shouldShowInitials}}
        <span
          aria-label={{@alt}}
          class={{this.classes.name class=@classes.name}}
          role="img"
        >
          {{this.initials}}
        </span>
      {{/if}}
      {{#if @src}}
        <img
          class={{this.classes.img class=@classes.img}}
          src={{@src}}
          alt={{@alt}}
        />
      {{/if}}
    </span>
  </template>
}

export { Avatar };
export default Avatar;
