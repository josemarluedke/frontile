function swapColorValues<T extends Record<string, unknown>>(
  colors: T
): Record<string, unknown> {
  const swappedColors: Record<string, unknown> = {};
  const keys = Object.keys(colors);
  const length = keys.length;

  for (let i = 0; i < length / 2; i++) {
    const key1 = keys[i] as string;
    const key2 = keys[length - 1 - i] as string;

    swappedColors[key1] = colors[key2];
    swappedColors[key2] = colors[key1];
  }
  if (length % 2 !== 0) {
    const middleKey = keys[Math.floor(length / 2)] as string;

    swappedColors[middleKey] = colors[middleKey];
  }

  return swappedColors;
}

export { swapColorValues };
