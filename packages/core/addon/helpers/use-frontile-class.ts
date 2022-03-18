import { helper } from '@ember/component/helper';

export function useFrontileClass(
  params: string | unknown[],
  hash: { part?: string; class?: string }
): string {
  const [base, ...variants] = params;
  if (typeof base === 'undefined') {
    return '';
  }

  const classes: string[] = [base as string];

  variants.forEach((variant) => {
    if (variant && variant !== '') {
      classes.push(`${base}--${variant}`);
    }
  });

  if (hash.part) {
    classes.forEach((klass, index) => {
      classes[index] = `${klass}__${hash.part}`;
    });
  }

  if (hash.class) {
    if (Array.isArray(hash.class)) {
      classes.push(hash.class.join(' '));
    } else {
      classes.push(hash.class);
    }
  }

  return classes.join(' ');
}

export default helper(useFrontileClass) as never;
