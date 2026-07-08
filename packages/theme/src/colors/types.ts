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
  divider: ColorScale;
  focus: ColorScale;
};

export type SemanticBaseColors = {
  light: BaseColors;
  dark: BaseColors;
};

export interface SemanticColorCategory {
  subtle: string;
  muted: string;
  soft: string;
  medium: string;
  DEFAULT: string;
  firm: string;
  strong: string;
  bolder: string;
  boldest: string;
}

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
 *     medium: '#1e40af',
 *     DEFAULT: '#1e40af'
 *   },
 *   'on-primary': {
 *     subtle: '#ffffff',
 *     medium: '#e0f2ff',  // Light blue tint instead of pure white
 *     DEFAULT: '#ffffff'
 *   }
 * };
 */
export interface OnColorCategory {
  subtle?: string;
  soft?: string;
  medium?: string;
  strong?: string;
  DEFAULT?: string;
}

export interface SurfaceOverlay {
  subtle: string;
  soft: string;
  medium: string;
  strong: string;
  /**
   * Heavy backdrop tint for modal/drawer scrims, one step past `strong`.
   *
   * Follows the same darken-in-light / lighten-in-dark direction as
   * `subtle`/`soft`/`medium`/`strong`, just at much higher opacity (75%) so it
   * reads as a deliberate backdrop rather than a hover/elevation hint. A black
   * tint is used in light mode; a black scrim in dark mode would barely
   * register against an already near-black page, so dark mode lightens
   * (white tint) instead — same visual weight, opposite direction.
   *
   * @example
   * <div className="fixed inset-0 bg-surface-overlay-scrim">
   */
  scrim: string;
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
   * Dark: Medium gray, lighter than canvas for elevation
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
   * Form control surface for inputs, checkboxes, radios, and similar controls
   * (hierarchy level -1).
   *
   * Light: Pure white
   * Dark: Near-black, the darkest step in the neutral scale
   *
   * @example
   * // Text input
   * <input className="bg-surface-input border border-neutral-medium rounded px-3 py-2" />
   */
  input: string;

  /**
   * Modal, drawer, and popover container surface, highest elevation
   * (hierarchy level 3).
   *
   * Used for modal dialogs, drawers, dropdown menus, and other floating
   * content that appears above all other surfaces. Modals and drawers pair it
   * with a scrim backdrop to focus attention.
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
   * <div className="fixed inset-0 bg-surface-overlay-scrim">
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
  accent: SemanticColorCategory;
  success: SemanticColorCategory;
  warning: SemanticColorCategory;
  danger: SemanticColorCategory;
  surface: SurfaceColors;

  // Optional on-color overrides
  // If not provided, these will be auto-generated for optimal contrast
  'on-neutral'?: OnColorCategory;
  'on-primary'?: OnColorCategory;
  'on-accent'?: OnColorCategory;
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
