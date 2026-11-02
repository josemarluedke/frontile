#!/usr/bin/env node
// Compiled-CSS validity check.
//
// The theme's index.css declares variants (`@custom-variant`) whose
// selectors Tailwind copies into the CSS verbatim: it does not validate them.
// A selector the browser does not understand makes it drop the whole rule,
// silently, and every class built on that variant stops working. Nothing in
// the test suite notices, because the classes are still generated.
//
// So this script compiles the theme the way an app does (Tailwind plus
// index.css, scanning the theme's own `@source`) and parses the result with
// lightningcss, the parser Tailwind's own optimizer uses. Any warning fails
// the check. Besides the classes the theme uses, it builds one probe class
// per declared `@custom-variant` and `@utility`, so a declaration nothing
// uses yet is checked too.
import { createRequire } from 'node:module';
import { readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { compile } from '@tailwindcss/node';
import { Scanner } from '@tailwindcss/oxide';

// The Tailwind and lightningcss that @tailwindcss/node itself depends on, so
// the check compiles and parses with exactly what the build uses, wherever
// the entry lives.
const require = createRequire(import.meta.url);
const tailwindRequire = createRequire(require.resolve('@tailwindcss/node'));
const lightningcss = tailwindRequire('lightningcss');
const tailwindCss = join(
  dirname(tailwindRequire.resolve('tailwindcss/package.json')),
  'index.css'
);

/**
 * One probe class per variant and static utility `css` declares. Functional
 * utilities (`@utility tab-*`) need a value to be generated, so they are
 * covered only where the theme uses them.
 */
export function readProbes(css) {
  const variants = [...css.matchAll(/@custom-variant\s+([\w-]+)/g)].map(
    (m) => `${m[1]}:underline`
  );
  const utilities = [...css.matchAll(/@utility\s+([\w-]+)(?=\s*\{)/g)].map(
    (m) => m[1]
  );
  return [...variants, ...utilities];
}

/**
 * Compiles `entry` the way an app consumes it and returns lightningcss's
 * warnings, each with the rule it points at.
 */
export async function checkCss({ entry }) {
  const css = readFileSync(entry, 'utf8');
  const base = dirname(resolve(entry));
  const compiler = await compile(
    `@import '${tailwindCss}';\n@import '${resolve(entry)}';`,
    { base, onDependency() {} }
  );
  const scanner = new Scanner({ sources: compiler.sources });
  const output = compiler.build([...scanner.scan(), ...readProbes(css)]);

  const { warnings } = lightningcss.transform({
    filename: entry,
    code: Buffer.from(output),
    errorRecovery: true
  });
  // lightningcss warns once per selector in a list, so a rule with two bad
  // selectors would be reported twice.
  const lines = output.split('\n');
  const problems = new Map();
  for (const w of warnings) {
    const rule = lines[w.loc.line - 1]?.trim();
    problems.set(`${w.message}\n${rule}`, { message: w.message, rule });
  }
  return [...problems.values()];
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const problems = await checkCss({ entry: 'packages/theme/src/index.css' });
  for (const p of problems) {
    console.error(`invalid: ${p.message}\n  in: ${p.rule}`);
  }
  if (problems.length) {
    console.error(
      '\nBrowsers drop a rule with a selector they do not understand. ' +
        'Check the @custom-variant or class that produced it.'
    );
    process.exit(1);
  }
  console.log('css ok');
}
