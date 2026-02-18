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
   * <div className="bg-surface-solid-1 bg-surface-overlay-soft" />
   */
  overlay: SurfaceOverlay;

  /**
   * Base 12-step achromatic scale (0-11) for surface backgrounds.
   *
   * Foundation for all surface roles, providing a consistent grayscale progression
   * that inverts between themes to support the elevation-luminance principle.
   *
   * Light theme: 0 (white) → 11 (black) - darkening progression
   * Dark theme: 0 (black) → 11 (white) - lightening progression
   *
   * The scale is bidirectional and theme-agnostic. Surface roles typically
   * reference steps 0-3, while higher steps (4-11) are available for custom
   * surface needs and direct usage.
   *
   * @example
   * // Using solid scale directly
   * bg-surface-solid-0  // Extreme anchor: white (light) or black (dark)
   * bg-surface-solid-1  // Near-white (light) or near-black (dark)
   * bg-surface-solid-11 // Opposite extreme: black (light) or white (dark)
   */
  solid: SurfaceSolid;

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
   * Sidebar and panel container surface (hierarchy level 1).
   *
   * Used for navigation sidebars, inspector panels, and tool palettes.
   * Provides consistent container background for grouped sections.
   *
   * Light: Pure white, elevated appearance
   * Dark: Dark gray, slight elevation above canvas
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
   * Used for dropdown menus, tooltips, context menus, and toast notifications.
   * Provides higher elevation than cards for floating UI elements.
   *
   * Light: Pure white, high elevation
   * Dark: Medium gray, lighter than card for higher elevation
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
   * Context-adaptive overlay that always darkens relative to its parent surface
   * via alpha compositing. Used for text inputs, search fields, code blocks,
   * and embedded content that should appear recessed.
   *
   * Works on any surface: Translucent black overlay that darkens the parent
   * surface, creating a consistent recessed appearance across all contexts.
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
   * Used for modal dialogs, drawers, and other overlay content that floats
   * above all other surfaces. Appears with a scrim backdrop to focus attention.
   *
   * Light: Pure white, highest elevation
   * Dark: Medium gray, lightest surface for maximum elevation
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
