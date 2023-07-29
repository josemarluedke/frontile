import { htmlSafe } from '@ember/template';

export default function safeStyles(
  style: Record<string, string | number> | undefined
): ReturnType<typeof htmlSafe> {
  if (!style) {
    return htmlSafe('');
  }
  const styles: string[] = [];

  Object.keys(style).forEach((key): void => {
    styles.push(`${key}:${style[key]}`);
  });

  return htmlSafe(styles.join(';'));
}
