import type { ContentValue } from '@glint/template';
import type { ColumnConfig } from './types';

/**
 * Safely extracts a value from an object using either a custom value function or direct property access
 */
export function getSafeValue<T>(
  obj: T,
  column: ColumnConfig<T> | { key: string; label?: string }
): ContentValue {
  // Use custom value function if provided (ColumnConfig)
  if ('value' in column && typeof column.value === 'function') {
    try {
      // Try with legacy format (direct item parameter) for backward compatibility
      const result = column.value(obj as any);
      if (result !== undefined && result !== null) {
        return result;
      }
    } catch (error) {
      // Legacy format didn't work
    }
    
    try {
      // Then try with the universal-ember CellContext format
      const cellContext = { row: { data: obj }, column } as any;
      const result = column.value(cellContext);
      if (result !== undefined && result !== null) {
        return result;
      }
    } catch (error) {
      // CellContext format didn't work either
    }
  }

  // Fallback to direct property access
  return getSafeValueByKey(obj, column.key);
}

/**
 * Safely extracts a value from an object by key and ensures it's safe for template rendering
 */
export function getSafeValueByKey(obj: unknown, key: string): ContentValue {
  if (!obj || typeof obj !== 'object') {
    return undefined;
  }

  const value = (obj as Record<string, unknown>)[key];

  // Return the value if it's already a safe template type
  if (
    typeof value === 'string' ||
    typeof value === 'number' ||
    typeof value === 'boolean' ||
    value === null ||
    value === undefined
  ) {
    return value;
  }

  // For other types, convert to string representation
  if (typeof value === 'object' && value !== null) {
    // Handle arrays
    if (Array.isArray(value)) {
      return value.join(', ');
    }
    // Handle objects with toString method
    return value.toString();
  }

  // Fallback - convert to string
  return String(value);
}
