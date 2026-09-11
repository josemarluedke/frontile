import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export function assertCleanShell(shell) {
  if (shell.includes('name="x-prerendered"')) {
    throw new Error('Refusing to snapshot an already-prerendered app shell. Run the client build first.');
  }

  if (!shell.includes('<script type="module"') || !shell.includes('</head>')) {
    throw new Error('Client index.html is not a valid Vite app shell.');
  }
}

export async function snapshotShell(clientPath, snapshotPath) {
  const shell = await readFile(clientPath, 'utf8');
  assertCleanShell(shell);
  await mkdir(dirname(snapshotPath), { recursive: true });
  await writeFile(snapshotPath, shell, 'utf8');
  return shell;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
  await snapshotShell(join(root, 'dist', 'index.html'), join(root, 'dist-ssr', 'app-shell.html'));
}
