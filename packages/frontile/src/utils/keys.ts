import { tracked } from '@glimmer/tracking';

/**
 * The key table and grammar behind `Kbd`.
 *
 * Kept apart from the component so the table and the parsing rules can be
 * tested without rendering anything, and so the platform detection has one home
 * rather than a copy per consumer.
 */

export type KbdPlatform = 'apple' | 'other';
export type KbdPlatformSetting = KbdPlatform | 'auto';

/** One parsed key, ready to render. */
export interface KbdKey {
  /** What is shown, e.g. `⌘` or `K`. */
  glyph: string;

  /**
   * The human name of the key, e.g. `Command`. Absent for literal characters,
   * where we have no name to offer.
   */
  name?: string;

  /**
   * Whether a screen reader needs `name` spoken in place of `glyph`.
   *
   * True only when the glyph is a symbol. `Esc` already reads correctly, so
   * labelling it would announce "Escape Escape".
   */
  needsSpokenLabel: boolean;
}

interface KeyEntry {
  glyph: string;
  name: string;
  /** Falls back to `glyph` when the platform makes no difference. */
  otherGlyph?: string;
  /** Falls back to `name`. */
  otherName?: string;
}

/**
 * Only `mod`, `ctrl` and `alt` differ by platform. `meta` names a specific
 * physical key rather than a role, so it stays `⌘` everywhere.
 */
const KEYS: Record<string, KeyEntry> = {
  mod: {
    glyph: '⌘',
    name: 'Command',
    otherGlyph: 'Ctrl',
    otherName: 'Control'
  },
  meta: { glyph: '⌘', name: 'Command' },
  cmd: { glyph: '⌘', name: 'Command' },
  command: { glyph: '⌘', name: 'Command' },
  ctrl: { glyph: '⌃', name: 'Control', otherGlyph: 'Ctrl' },
  control: { glyph: '⌃', name: 'Control', otherGlyph: 'Ctrl' },
  alt: { glyph: '⌥', name: 'Option', otherGlyph: 'Alt', otherName: 'Alt' },
  option: { glyph: '⌥', name: 'Option', otherGlyph: 'Alt', otherName: 'Alt' },
  shift: { glyph: '⇧', name: 'Shift' },
  win: { glyph: '⊞', name: 'Windows' },
  windows: { glyph: '⊞', name: 'Windows' },
  fn: { glyph: 'fn', name: 'Function' },

  enter: { glyph: '↵', name: 'Enter' },
  return: { glyph: '↵', name: 'Enter' },
  esc: { glyph: 'Esc', name: 'Escape' },
  escape: { glyph: 'Esc', name: 'Escape' },
  tab: { glyph: '⇥', name: 'Tab' },
  space: { glyph: '␣', name: 'Space' },
  spacebar: { glyph: '␣', name: 'Space' },
  backspace: { glyph: '⌫', name: 'Backspace' },
  del: { glyph: '⌦', name: 'Delete' },
  delete: { glyph: '⌦', name: 'Delete' },
  capslock: { glyph: '⇪', name: 'Caps Lock' },
  plus: { glyph: '+', name: 'Plus' },

  up: { glyph: '↑', name: 'Arrow up' },
  arrowup: { glyph: '↑', name: 'Arrow up' },
  down: { glyph: '↓', name: 'Arrow down' },
  arrowdown: { glyph: '↓', name: 'Arrow down' },
  left: { glyph: '←', name: 'Arrow left' },
  arrowleft: { glyph: '←', name: 'Arrow left' },
  right: { glyph: '→', name: 'Arrow right' },
  arrowright: { glyph: '→', name: 'Arrow right' },
  pageup: { glyph: '⇞', name: 'Page up' },
  pagedown: { glyph: '⇟', name: 'Page down' },
  home: { glyph: '↖', name: 'Home' },
  end: { glyph: '↘', name: 'End' }
};

/**
 * Tracked so `setKbdPlatform` invalidates keycaps that have already rendered.
 * With plain module variables a call after first render changed nothing on
 * screen, which is a trap for an app that resolves its platform
 * asynchronously.
 */
class PlatformState {
  @tracked setting: KbdPlatformSetting = 'auto';
}

const state = new PlatformState();

/**
 * Deliberately NOT tracked. It is an immutable fact about the environment, and
 * the lazy `??=` below both reads and writes it during render — which on a
 * tracked property trips Glimmer's backtracking assertion.
 */
let detected: KbdPlatform | undefined;

/**
 * True on Apple platforms. `platform` is deprecated but remains the only
 * synchronous signal in some browsers, so userAgent covers the rest.
 */
export function isApplePlatform(): boolean {
  const nav = globalThis.navigator;

  return /Mac|iPhone|iPad|iPod/i.test(nav?.platform || nav?.userAgent || '');
}

/**
 * Chooses the glyphs `Kbd` renders for `mod`, `ctrl` and `alt`.
 *
 * Defaults to `'auto'`, which reads the browser. Set it explicitly when
 * detection cannot work or would be wrong:
 *
 * - during server rendering, where every visitor looks non-Apple, so a Mac
 *   user would see `Ctrl` until hydration corrected it
 * - in tests, which would otherwise pass or fail depending on the machine
 * - in an app that already knows the platform from the request
 */
export function setKbdPlatform(platform: KbdPlatformSetting): void {
  state.setting = platform;
}

/** The platform in force, with `'auto'` already resolved. */
export function resolveKbdPlatform(): KbdPlatform {
  if (state.setting !== 'auto') {
    return state.setting;
  }

  // Detection is cached: it cannot change within a page, and `Kbd` is cheap
  // enough that it may render many times.
  detected ??= isApplePlatform() ? 'apple' : 'other';

  return detected;
}

const ALPHANUMERIC = /^[a-z0-9]+$/i;

function toKey(token: string, platform: KbdPlatform): KbdKey {
  const entry = KEYS[token.toLowerCase()];

  if (!entry) {
    // A single letter is a keycap, and keycaps are capitalised: `mod+k` should
    // read `⌘K`. Anything longer is passed through untouched so `F5` and `Ins`
    // work without needing table entries.
    const glyph = /^[a-z]$/i.test(token) ? token.toUpperCase() : token;

    return { glyph, needsSpokenLabel: false };
  }

  const isApple = platform === 'apple';
  const glyph = isApple ? entry.glyph : (entry.otherGlyph ?? entry.glyph);
  const name = isApple ? entry.name : (entry.otherName ?? entry.name);

  return { glyph, name, needsSpokenLabel: !ALPHANUMERIC.test(glyph) };
}

/**
 * Splits a shortcut like `mod+shift+p` into its keys.
 *
 * A string with no `+` is a single key rendered verbatim, which is what lets
 * existing `@shortcut='⌘⇧S'` values keep working unchanged.
 */
export function parseKeys(
  keys: string | undefined,
  platform?: KbdPlatform
): KbdKey[] {
  if (!keys || !keys.trim()) {
    return [];
  }

  const resolved = platform ?? resolveKbdPlatform();

  return keys
    .split('+')
    .map((token) => token.trim())
    .filter((token) => token !== '')
    .map((token) => toKey(token, resolved));
}
