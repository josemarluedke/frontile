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
  soft: string;
  medium: string;
  strong: string;
  DEFAULT: string;
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
 * // Override on-colors for brand
 * const colors: Partial<ThemeColors> = {
 *   brand: {
 *     subtle: '#3b82f6',
 *     medium: '#1e40af',
 *     DEFAULT: '#1e40af'
 *   },
 *   'on-brand': {
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
  inverse: {
    subtle: string;
    soft: string;
    medium: string;
    strong: string;
  };
}

export interface SurfaceSolid {
  0: string;
  1: string;
  2: string;
  3: string;
  4: string;
  5: string;
  6: string;
  7: string;
  8: string;
  9: string;
  10: string;
  11: string;
}

/**
 * Surface color system defining background colors for UI containers.
 *
 * Surface tokens organize backgrounds into three categories:
 * 1. **Roles**: Component context tokens (where in layout hierarchy)
 * 2. **Solid**: Base 12-step gray scale (0-11) for surfaces
 * 3. **Overlay**: Translucent layers for elevation and depth
 */
export interface SurfaceColors {
  /**
   * Translucent overlay system for elevation and depth.
   *
   * Standard overlays use black translucent on light backgrounds.
   * Inverse overlays use white translucent on dark backgrounds.
   *
   * @example
   * // Standard overlay on card
   * bg-surface-card hover:bg-surface-overlay-subtle
   *
   * // Stacking overlays
   * bg-surface-solid-1 bg-surface-overlay-soft
   */
  overlay: SurfaceOverlay;

  /**
   * Base 12-step achromatic scale (0-11) for surface backgrounds.
   *
   * Light theme: 0 (white) → 11 (black)
   * Dark theme: 0 (black) → 11 (white)
   *
   * The scale is bidirectional and theme-agnostic, inverting between themes.
   * Most surface roles reference 0-3 only.
   *
   * @example
   * // Using solid scale directly
   * bg-surface-solid-0  // Pure white (light) or black (dark)
   * bg-surface-solid-1  // Canvas level
   * bg-surface-solid-11 // Pure black (light) or white (dark)
   */
  solid: SurfaceSolid;

  /**
   * Primary application/page background (hierarchy level 0).
   *
   * Light: gray.50 (near-white canvas)
   * Dark: solid.1 (near-black canvas)
   *
   * @example
   * // App shell background
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
   * Light: solid.0 (pure white, elevated off canvas)
   * Dark: solid.2 (dark gray, slight elevation)
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
   * Sidebar and panel container surface (hierarchy level 1).
   *
   * Light: solid.0 (pure white, elevated)
   * Dark: solid.2 (dark gray, slight elevation)
   *
   * @example
   * // Navigation sidebar
   * <aside className="bg-surface-panel border-r border-neutral-subtle">
   *   <nav>...</nav>
   * </aside>
   *
   * @example
   * // Inspector panel
   * <div className="bg-surface-panel p-4">
   *   <h3>Properties</h3>
   * </div>
   */
  panel: string;

  /**
   * Popover and tooltip container surface (hierarchy level 2).
   *
   * Light: solid.0 (pure white, high elevation)
   * Dark: solid.3 (medium gray, high elevation)
   *
   * @example
   * // Dropdown menu
   * <div className="bg-surface-popover rounded-md shadow-lg border border-neutral-subtle">
   *   <MenuItem />
   * </div>
   *
   * @example
   * // Tooltip
   * <div className="bg-surface-popover px-2 py-1 rounded text-sm">
   *   Helpful tip
   * </div>
   */
  popover: string;

  /**
   * Recessed surface for inputs, wells, and embedded content (hierarchy level -1).
   *
   * Light: solid.2 (darker gray, recessed below canvas)
   * Dark: solid.0 (pure black, deepest recess)
   *
   * Appears recessed: darker than canvas in light mode, lighter in dark mode.
   *
   * @example
   * // Text input
   * <input className="bg-surface-inset border border-neutral-medium rounded px-3 py-2" />
   *
   * @example
   * // Code block
   * <pre className="bg-surface-inset rounded-md p-4">
   *   <code>const example = true;</code>
   * </pre>
   *
   * @example
   * // Search field
   * <div className="bg-surface-inset rounded-full px-4 py-2">
   *   <input type="search" />
   * </div>
   */
  inset: string;

  /**
   * Modal and drawer container surface, highest elevation (hierarchy level 3).
   *
   * Light: solid.0 (pure white, highest elevation)
   * Dark: solid.3 (medium gray, highest elevation)
   *
   * @example
   * // Modal dialog
   * <div className="bg-surface-overlay-content rounded-lg shadow-2xl p-6">
   *   <h2>Confirm Action</h2>
   *   <p>Are you sure?</p>
   * </div>
   *
   * @example
   * // Drawer with backdrop
   * <div className="fixed inset-0 bg-surface-overlay-strong">
   *   <aside className="bg-surface-overlay-content h-full w-80">
   *     <DrawerContent />
   *   </aside>
   * </div>
   */
  overlayContent: string;
}

export interface ThemeColors {
  neutral: SemanticColorCategory;
  brand: SemanticColorCategory;
  accent: SemanticColorCategory;
  success: SemanticColorCategory;
  warning: SemanticColorCategory;
  danger: SemanticColorCategory;
  surface: SurfaceColors;

  // Optional on-color overrides
  // If not provided, these will be auto-generated for optimal contrast
  'on-neutral'?: OnColorCategory;
  'on-brand'?: OnColorCategory;
  'on-accent'?: OnColorCategory;
  'on-success'?: OnColorCategory;
  'on-warning'?: OnColorCategory;
  'on-danger'?: OnColorCategory;

  /**
   * Optional on-color overrides for surface-solid colors.
   *
   * Surface-solid has numeric keys (0-11), so on-colors follow the same pattern.
   *
   * @example
   * // Override specific surface-solid on-colors
   * 'on-surface-solid': {
   *   0: '#000000',  // Text color on surface-solid-0
   *   5: '#ffffff',  // Text color on surface-solid-5
   *   11: '#ffffff'  // Text color on surface-solid-11
   * }
   */
  'on-surface-solid'?: {
    0?: string;
    1?: string;
    2?: string;
    3?: string;
    4?: string;
    5?: string;
    6?: string;
    7?: string;
    8?: string;
    9?: string;
    10?: string;
    11?: string;
  };
}
