import { htmlSafe } from '@ember/string';
import type { SafeString } from 'handlebars';

export default function safeStyles(
  style: Record<string, string | number> | undefined
): SafeString {
  if (!style) {
    return htmlSafe('');
  }
  const styles: string[] = [];

  Object.keys(style).forEach((key): void => {
    styles.push(`${key}:${style[key]}`);
  });

  return htmlSafe(styles.join(';'));
}
