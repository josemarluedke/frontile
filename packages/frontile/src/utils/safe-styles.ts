import { htmlSafe } from '@ember/template';

export default function safeStyles(
  style: Record<string, string | number> | undefined
): ReturnType<typeof htmlSafe> {
  if (!style) {
    return htmlSafe('');
  }
  const styles: string[] = [];

  Object.keys(style).forEach((key): void => {
    // Values come from component arguments, so strip declaration separators to
    // keep a single value from injecting additional CSS declarations.
    //
    // Limitation: values that legitimately contain a `;` are not supported by
    // this helper — the realistic case is a data URI, e.g.
    // `background-image: url(data:image/png;base64,...)`, which this would
    // silently corrupt. A caller needing such a value should set the property
    // through the CSSOM (`element.style.setProperty(...)`) instead, which
    // cannot inject extra declarations in the first place.
    const value = String(style[key]).replace(/;/g, '');
    styles.push(`${key}:${value}`);
  });

  return htmlSafe(styles.join(';'));
}
