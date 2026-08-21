export type ColorScale =
  | Partial<{
      50: string;
      100: string;
      200: string;
      300: string;
      400: string;
      500: string;
      600: string;
      700: string;
      800: string;
      900: string;
      950: string;
      DEFAULT: string;
    }>
  | string;

export type BaseColors = {
  background: ColorScale;
  divider: ColorScale;
  focus: ColorScale;
};

export type SemanticBaseColors = {
  light: BaseColors;
  dark: BaseColors;
};

/**
 * Semantic color levels are split into two bands that share one emphasis
 * vocabulary but are consumed by different CSS properties. In Tailwind's
 * shared-palette model a token name maps to exactly one color value, so the
 * band a level belongs to is what tells you which property it is meant for:
 * surface-band levels are fills, ink-band levels are legible foregrounds.
 *
 * Every name describes emphasis RANK, never brightness. A level can be dark in
 * light mode and light in dark mode — interaction direction inverts between
 * schemes (light lightens on hover / darkens on press; dark does the reverse)
 * — so a brightness word like "deep" or "light" would be a lie in one theme.
 */

/**
 * Surface band — fills. Backgrounds and decorative borders for filled/tinted
 * surfaces, ordered low → high emphasis:
 *
 *   subtle → muted → soft → mild → DEFAULT → firm
 *
 * `DEFAULT` is the resting fill (the bare `bg-{category}` class); `firm` is the
 * most emphatic fill, e.g. a pressed/active background.
 */
export interface SurfaceBand {
  /** Faintest tint — hairline fills, tonal resting backgrounds. */
  subtle: string;
  /** Light tint — hover on tonal fills, chip/close-button backgrounds. */
  muted: string;
  /** Soft fill — the hover step for solid fills. */
  soft: string;
  /** Between `soft` and `DEFAULT` — a lower-emphasis fill just short of resting. */
  mild: string;
  /** Resting fill — the bare `bg-{category}` / `border-{category}` token. */
  DEFAULT: string;
  /** Most emphatic fill — pressed/active backgrounds. */
  firm: string;
}

/**
 * Ink band — legible foregrounds. Text, and the borders of outlined controls,
 * that must stay readable on the page and on surface-band fills, ordered
 * low → high emphasis:
 *
 *   strong → bolder
 *
 * `strong` is the default legible foreground; `bolder` is the highest-emphasis
 * foreground (headings, hover/active text).
 */
export interface InkBand {
  /** Default legible foreground — body text, outlined-control text/border. */
  strong: string;
  /** Highest-emphasis foreground — headings, hover/active text. */
  bolder: string;
}

/**
 * A semantic color category is the union of both bands: fills (surface band)
 * plus legible foregrounds (ink band). See {@link SurfaceBand} and
 * {@link InkBand} for how each level is intended to be consumed.
 */
export interface SemanticColorCategory extends SurfaceBand, InkBand {}

/**
 * Optional on-color overrides for semantic color categories.
 *
 * On-colors are foreground/text colors used on semantic backgrounds.
 * By default, they're auto-generated using WCAG contrast guidelines
 * (resulting in either pure white or pure black).
 *
 * Use this type to override the auto-generated values with custom colors
 * that match your brand or design requirements.
 *
 * @example
 * // Override on-colors for primary
 * const colors: Partial<ThemeColors> = {
 *   primary: {
 *     subtle: '#3b82f6',
 *     DEFAULT: '#1e40af'
 *   },
 *   'on-primary': {
 *     subtle: '#ffffff',
 *     DEFAULT: '#e0f2ff'  // Light blue tint instead of pure white
 *   }
 * };
 */
export interface OnColorCategory {
  subtle?: string;
  muted?: string;
  soft?: string;
  mild?: string;
  DEFAULT?: string;
  firm?: string;
  strong?: string;
  bolder?: string;
}

export interface SurfaceOverlay {
  subtle: string;
  soft: string;
  mild: string;
  firm: string;
  /**
   * Heaviest overlay step (75% in light, 95% in dark).
   *
   * In light mode this is the backdrop tint behind modals and drawers. In dark
   * mode the black scrim is {@link SurfaceLift}'s `strong` instead, because the
   * families mirror each other — pair them as
   * `bg-surface-overlay-strong dark:bg-surface-lift-strong` for a scrim that
   * holds in both schemes.
   *
   * Follows the same darken-in-light / lighten-in-dark direction as
   * `subtle`/`soft`/`mild`/`firm`, just at much higher opacity (75%) so it
   * reads as a deliberate backdrop rather than a hover/elevation hint. A black
   * tint is used in light mode; a black backdrop in dark mode would barely
   * register against an already near-black page, so dark mode lightens
   * (white tint) instead — same visual weight, opposite direction.
   *
   * @example
   * <div className="fixed inset-0 bg-surface-overlay-strong dark:bg-surface-lift-strong">
   */
  strong: string;
}

/**
 * Translucent overlay system that *lightens* in light mode and *darkens* in
 * dark mode — the mirror of {@link SurfaceOverlay}.
 *
 * Where overlay pushes an element down into its background, lift pulls it up
 * off of it: a white veil on a light page, a black veil on a dark one. Use it
 * for frosted/glass panels, sticky headers over content, and any surface that
 * should read as floating above what it covers.
 *
 * Levels run low → high emphasis, same as overlay: `subtle`, `soft`, `mild`,
 * `firm`, `strong`.
 *
 * @example
 * // Frosted sticky header
 * <header className="bg-surface-lift-firm backdrop-blur-md" />
 */
export interface SurfaceLift {
  subtle: string;
  soft: string;
  mild: string;
  firm: string;

  /**
   * Heaviest lift step, near-opaque (95%) — a panel lifted essentially clear
   * of the page rather than a veil you see through.
   *
   * Flips with the scheme like every other lift level: white in light mode,
   * black in dark mode. (Overlay's `strong` is the one that does *not* flip.)
   */
  strong: string;
}

/**
 * Surface color system defining background colors for UI containers.
 *
 * Surface tokens organize backgrounds into two categories:
 * 1. **Roles**: Component context tokens (where in layout hierarchy)
 * 2. **Overlay**: Translucent layers for elevation and depth
 */
export interface SurfaceColors {
  /**
   * Translucent overlay system for elevation and depth.
   *
   * Provides translucent layers that stack on surface roles to convey elevation,
   * interaction states, or visual depth without introducing chromatic tint.
   *
   * Standard overlays: Black translucent for darkening effect
   * Inverse overlays: White translucent for lightening effect
   *
   * Use overlays to create hover states, elevated containers, or glass morphism
   * effects while maintaining the base surface color.
   *
   * @example
   * // Hover state on card
   * <div className="bg-surface-card hover:bg-surface-overlay-subtle" />
   *
   * // Stacking overlays for depth
   * <div className="bg-surface-app bg-surface-overlay-soft" />
   */
  overlay: SurfaceOverlay;

  /**
   * Translucent lift system for elements that float above the page.
   *
   * The mirror of {@link overlay}: lightens in light mode, darkens in dark
   * mode. See {@link SurfaceLift}.
   *
   * @example
   * <div className="bg-surface-lift-soft backdrop-blur-sm" />
   */
  lift: SurfaceLift;

  /**
   * Root application background layer (hierarchy level 0).
   *
   * The foundational surface for the entire application. Navigation and other
   * UI elements float transparently over this layer.
   *
   * Both themes: Near-white (light) or near-black (dark)
   *
   * @example
   * // App shell root
   * <div className="bg-surface-app min-h-screen">
   *   <TransparentNav />
   *   <main className="bg-surface-canvas">
   *     <AppContent />
   *   </main>
   * </div>
   *
   * @example
   * // Full-viewport base layer
   * <body className="bg-surface-app">
   */
  app: string;

  /**
   * Primary application/page background (hierarchy level 1).
   *
   * Component contrast baseline that provides visual separation from the app layer.
   * Main content area where components and UI elements are placed.
   *
   * Light: Near-white gray canvas
   * Dark: Dark gray canvas
   *
   * @example
   * // Main content area
   * <div className="bg-surface-canvas">
   *   <AppContent />
   * </div>
   *
   * @example
   * // Page container
   * <main className="bg-surface-canvas min-h-screen">
   */
  canvas: string;

  /**
   * Elevated card container surface (hierarchy level 1).
   *
   * Creates visual elevation for content containers like product cards,
   * article previews, and content blocks. Appears lifted off the canvas
   * through the elevation-luminance principle.
   *
   * Light: Pure white, creating lifted appearance against gray canvas
   * Dark: A translucent veil (white @ 7%, the same value as `overlay-subtle`),
   * so content behind it shows through faintly. Where a surface has to stay
   * opaque, use {@link table} — the same color without the transparency.
   *
   * @example
   * // Product card
   * <article className="bg-surface-card rounded-lg border border-neutral-subtle p-6">
   *   <h2>Product Title</h2>
   *   <p>Description...</p>
   * </article>
   *
   * @example
   * // Content block with hover state
   * <div className="bg-surface-card hover:bg-surface-overlay-subtle">
   */
  card: string;

  /**
   * Data table surface (hierarchy level 1).
   *
   * The same color as {@link card}, guaranteed opaque. Tables need that
   * guarantee: a sticky header, a frozen row, or a pinned column paints over the
   * rows and columns scrolling beneath it, and anything translucent lets them
   * show through.
   *
   * Light: Pure white, identical to `card`
   * Dark: `gray-900` — the color `card` renders over `canvas`, so the two are
   * indistinguishable on a canvas-backed page
   *
   * For one table on a different background, set `--color-surface-table` on it
   * rather than recolouring the role — it is a plain custom property, and it
   * applies to everything below it.
   *
   * @example
   * // Sticky table header, which the rows scroll under
   * <thead className="sticky top-0 bg-surface-table">
   */
  table: string;

  /**
   * Form control surface for inputs, checkboxes, radios, and similar controls
   * (hierarchy level -1).
   *
   * Light: Pure white
   * Dark: Near-black, the darkest step in the neutral scale
   *
   * @example
   * // Text input
   * <input className="bg-surface-input border border-neutral rounded px-3 py-2" />
   */
  input: string;

  /**
   * Modal, drawer, and popover container surface, highest elevation
   * (hierarchy level 3).
   *
   * Used for modal dialogs, drawers, dropdown menus, and other floating
   * content that appears above all other surfaces. Modals and drawers pair it
   * with a `surface-overlay-strong dark:surface-lift-strong` backdrop to focus
   * attention.
   *
   * Light: Pure white, highest elevation
   * Dark: Medium gray, lightest surface for maximum elevation
   *
   * @example
   * // Modal dialog
   * <div className="bg-surface-modal rounded-lg shadow-2xl p-6">
   *   <h2>Confirm Action</h2>
   *   <p>Are you sure?</p>
   * </div>
   *
   * @example
   * // Drawer with backdrop
   * <div className="fixed inset-0 bg-surface-overlay-strong dark:bg-surface-lift-strong">
   *   <aside className="bg-surface-modal h-full w-80">
   *     <DrawerContent />
   *   </aside>
   * </div>
   *
   * @example
   * // Dropdown menu
   * <div className="bg-surface-modal rounded-md shadow-lg border border-neutral-subtle">
   *   <MenuItem />
   * </div>
   */
  modal: string;
}

export interface ThemeColors {
  neutral: SemanticColorCategory;
  primary: SemanticColorCategory;
  secondary: SemanticColorCategory;
  tertiary: SemanticColorCategory;
  success: SemanticColorCategory;
  warning: SemanticColorCategory;
  danger: SemanticColorCategory;
  surface: SurfaceColors;

  // Optional on-color overrides
  // If not provided, these will be auto-generated for optimal contrast
  'on-neutral'?: OnColorCategory;
  'on-primary'?: OnColorCategory;
  'on-secondary'?: OnColorCategory;
  'on-tertiary'?: OnColorCategory;
  'on-success'?: OnColorCategory;
  'on-warning'?: OnColorCategory;
  'on-danger'?: OnColorCategory;

  /**
   * Optional on-color override for the `surface-modal` background.
   *
   * By default, auto-generated for optimal WCAG contrast, same as the other
   * semantic categories.
   *
   * @example
   * 'on-surface-modal': '#111111'
   */
  'on-surface-modal'?: string;
}
