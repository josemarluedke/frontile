export const focusVisibleRing = [
  'outline-hidden',
  'focus-visible:z-10',
  'focus-visible:ring-3',
  'focus-visible:ring-focus',
  'focus-visible:ring-offset-2',
  'focus-visible:ring-offset-background'
];

/**
 * The close button sitting at the end of a status row — NotificationCard's
 * and Alert's. It is the same affordance in both: a small round hit area,
 * pulled into the row's padding, that reveals a surface tint on hover.
 *
 * Colour is deliberately absent, so this stays intent- and variant-neutral
 * and each recipe keeps ownership of its own palette.
 */
export const statusRowCloseButton = [
  'shrink-0 self-center -mr-1 inline-block p-1.5 rounded-full',
  'transition duration-200',
  'hover:bg-surface-overlay-soft',
  ...focusVisibleRing
];

/**
 * `focusVisibleRing` for a container whose focusable element is a descendant
 * (Switch's hidden input, a segmented control's radios). Every utility goes
 * through the theme's own `focus-visible` variant, which matches
 * `[data-focus-visible-added]` (see index.css). Spelling some of them with the
 * native pseudo-class instead drew the ring at full width but left its color
 * to whichever of the two focus states happened to agree.
 */
export const focusVisibleWithinRing = [
  'outline-hidden',
  'has-focus-visible:z-10',
  'has-focus-visible:ring-3',
  'has-focus-visible:ring-focus',
  'has-focus-visible:ring-offset-2',
  'has-focus-visible:ring-offset-background'
];
