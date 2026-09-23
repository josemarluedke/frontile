import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
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
     * How the image fills the avatar. `cover` crops the image to fill the
     * avatar, which suits photos. `contain` shows the whole image, inset from
     * the edge, which suits logos and wordmarks.
     *
     * @defaultValue 'cover'
     */
    fit?: AvatarVariants['fit'];

    /**
     * Draws a faint hairline just inside the avatar's edge. Pass `false` to
     * remove it.
     *
     * @defaultValue true
     */
    isBordered?: boolean;

    /**
     * URL of the image to be displayed in the avatar.
     * If provided, the image will be used instead of initials. If the image
     * fails to load, the avatar falls back to the initials, or to an empty
     * plate when there is no name.
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
  // Keyed by URL rather than a boolean, so a new `@src` is tried afresh
  // without having to reset anything when the argument changes.
  @tracked failedSrc?: string | null;

  get classes() {
    const { avatar } = useStyles();
    return avatar({
      size: this.args.size,
      shape: this.args.shape,
      fit: this.args.fit,
      isBordered: this.args.isBordered
    });
  }

  get hasImage() {
    const { src } = this.args;
    return Boolean(src) && src !== this.failedSrc;
  }

  @action
  handleImageError() {
    this.failedSrc = this.args.src;
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
    const { name, firstName, lastName } = this.args;
    if (this.hasImage) {
      return false;
    }

    return Boolean(name || firstName || lastName);
  }

  <template>
    <span
      class={{this.classes.base class=@classes.base}}
      data-component="avatar"
      data-part="base"
      ...attributes
    >
      {{#if this.shouldShowInitials}}
        {{! role="img" makes the contents presentational, so the initials stop
        being read. Only claim the role when there is an @alt to name it with;
        otherwise leave the letters as plain text. }}
        <span
          aria-label={{@alt}}
          class={{this.classes.name class=@classes.name}}
          data-part="name"
          role={{if @alt "img"}}
        >
          {{this.initials}}
        </span>
      {{/if}}
      {{#if this.hasImage}}
        {{! An omitted alt makes screen readers fall back to the URL. An empty
        one marks the image decorative, which is right beside a visible name. }}
        <img
          class={{this.classes.img class=@classes.img}}
          data-part="img"
          src={{@src}}
          alt={{if @alt @alt ""}}
          {{on "error" this.handleImageError}}
        />
      {{/if}}
    </span>
  </template>
}

export { Avatar };
export default Avatar;
