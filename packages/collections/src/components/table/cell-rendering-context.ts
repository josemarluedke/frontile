/**
 * Context class to track which column keys have been claimed by CellForComponent
 * instances during cell rendering. This enables CellDefaultComponent to only
 * render when no specific column renderer has claimed the current column key.
 */
export class CellRenderingContext {
  private claimedKeys = new Set<string>();

  /**
   * Mark a column key as claimed by a CellForComponent
   */
  claimKey(key: string): void {
    this.claimedKeys.add(key);
  }

  /**
   * Check if a column key has been claimed by any CellForComponent
   */
  isKeyClaimed(key: string): boolean {
    return this.claimedKeys.has(key);
  }

  /**
   * Reset the claimed keys (called between cell renders)
   */
  reset(): void {
    this.claimedKeys.clear();
  }

  /**
   * Get all claimed keys (useful for debugging)
   */
  get claimedKeysList(): string[] {
    return Array.from(this.claimedKeys);
  }
}