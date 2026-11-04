/**
 * Replaces `window.matchMedia` with a fake viewport of the given width, so a
 * test can drive width-dependent behavior without resizing the browser (the
 * test container is scaled, so real widths would not match the CSS anyway).
 *
 * Understands `min-width` and `max-width` in `px`, `rem` (16px) and
 * `calc(<rem> - <px>)`. `setWidth` updates every query created so far and
 * fires `change` on the ones whose answer flipped. Call `restore` when done.
 */
export interface MatchMediaMock {
  setWidth(width: number): void;
  restore(): void;
}

type Listener = (event: MediaQueryListEvent) => void;

interface FakeQuery {
  mql: MediaQueryList;
  listeners: Set<Listener>;
  evaluate(width: number): boolean;
}

function toPx(value: string): number {
  const trimmed = value.trim();
  const calc = /^calc\((.+)\)$/.exec(trimmed);
  if (calc) {
    const [, left, op, right] = /^(.+?)\s+([-+])\s+(.+)$/.exec(calc[1]!) ?? [];
    if (left === undefined || right === undefined) {
      return NaN;
    }
    return op === '-' ? toPx(left) - toPx(right) : toPx(left) + toPx(right);
  }
  if (trimmed.endsWith('rem')) {
    return parseFloat(trimmed) * 16;
  }
  return parseFloat(trimmed);
}

function parse(media: string): (width: number) => boolean {
  const checks: ((width: number) => boolean)[] = [];
  const pattern = /\((min|max)-width:\s*([^()]+(?:\([^()]*\))?)\)/g;
  let match: RegExpExecArray | null;
  while ((match = pattern.exec(media))) {
    const px = toPx(match[2]!);
    checks.push(match[1] === 'min' ? (w) => w >= px : (w) => w <= px);
  }
  return (width) => checks.every((check) => check(width));
}

export function mockMatchMedia(initialWidth: number): MatchMediaMock {
  const original = Object.getOwnPropertyDescriptor(window, 'matchMedia');
  const queries: FakeQuery[] = [];
  let width = initialWidth;

  function matchMedia(media: string): MediaQueryList {
    const evaluate = parse(media);
    const listeners = new Set<Listener>();
    const mql = {
      media,
      matches: evaluate(width),
      onchange: null,
      addEventListener(_type: string, listener: Listener) {
        listeners.add(listener);
      },
      removeEventListener(_type: string, listener: Listener) {
        listeners.delete(listener);
      },
      addListener(listener: Listener) {
        listeners.add(listener);
      },
      removeListener(listener: Listener) {
        listeners.delete(listener);
      },
      dispatchEvent() {
        return true;
      }
    } as unknown as MediaQueryList;
    queries.push({ mql, listeners, evaluate });
    return mql;
  }

  Object.defineProperty(window, 'matchMedia', {
    configurable: true,
    writable: true,
    value: matchMedia
  });

  return {
    setWidth(next: number) {
      width = next;
      for (const query of queries) {
        const matches = query.evaluate(width);
        if (matches === query.mql.matches) {
          continue;
        }
        (query.mql as { matches: boolean }).matches = matches;
        const event = {
          matches,
          media: query.mql.media
        } as MediaQueryListEvent;
        for (const listener of [...query.listeners]) {
          listener(event);
        }
      }
    },
    restore() {
      if (original) {
        Object.defineProperty(window, 'matchMedia', original);
      } else {
        delete (window as { matchMedia?: unknown }).matchMedia;
      }
    }
  };
}

/**
 * Removes `window.matchMedia`, as in an environment without it. Returns a
 * function that puts it back.
 */
export function removeMatchMedia(): () => void {
  const original = Object.getOwnPropertyDescriptor(window, 'matchMedia');
  Object.defineProperty(window, 'matchMedia', {
    configurable: true,
    writable: true,
    value: undefined
  });
  return () => {
    if (original) {
      Object.defineProperty(window, 'matchMedia', original);
    } else {
      delete (window as { matchMedia?: unknown }).matchMedia;
    }
  };
}
