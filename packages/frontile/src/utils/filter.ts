import fuzzysort from 'fuzzysort';

/**
 * Score or match an item against the current input text.
 *
 * Return a **number** to rank: higher sorts first and `0` means no match, so
 * the list is filtered *and* ordered by relevance. Return a **boolean** to
 * filter only, leaving the order of the source items untouched.
 *
 * The boolean form exists for backwards compatibility — it cannot express
 * relevance, which is why a filter that merely includes or excludes always
 * returned an exact match below a longer name that happened to contain the
 * query.
 */
export type FilterFn = (
  itemValue: string,
  inputValue: string
) => boolean | number;

/**
 * `0` is reserved to mean "no match", so a real but very poor match is clamped
 * to just above it rather than being silently dropped. In practice fuzzysort
 * scores asymptote well above zero, but the contract should not depend on that.
 */
const MIN_MATCH_SCORE = Number.EPSILON;

/**
 * Scores at or above this count as a match; anything below is discarded.
 *
 * Fuzzy matching is looser than the `includes()` filter this replaced, and
 * fuzzysort cannot distinguish a useful abbreviation (`btn` -> `Button`) from
 * noise (`sa` -> `Spain`) — both are scattered mid-word subsequences. What it
 * *can* separate is contiguous and word-boundary matches from scattered ones,
 * and it does so with a clean gap: measured over 2000 words x 12 queries, every
 * substring match scored >= 0.414 while every non-substring match scored
 * <= 0.358.
 *
 * Sitting the threshold in that gap keeps this filter at least as precise as
 * `includes()` — no result that used to match is lost — while additionally
 * matching acronyms (`bg` -> `ButtonGroup`, `nz` -> `New Zealand`). The cost is
 * that `btn` -> `Button` is not matched; lower the threshold to trade precision
 * for that recall.
 */
export const DEFAULT_MATCH_THRESHOLD = 0.4;

export interface FuzzyFilterOptions {
  /**
   * Minimum score to count as a match, between `0` and `1`.
   *
   * @defaultValue {@link DEFAULT_MATCH_THRESHOLD}
   */
  threshold?: number;
}

/**
 * Build a relevance filter backed by fuzzysort.
 *
 * @param options - See {@link FuzzyFilterOptions}.
 */
export function createFuzzyFilter(
  options: FuzzyFilterOptions = {}
): (itemValue: string, inputValue: string) => number {
  const threshold = options.threshold ?? DEFAULT_MATCH_THRESHOLD;

  return function fuzzyFilter(itemValue: string, inputValue: string): number {
    // An empty query matches everything. fuzzysort returns null for a blank
    // needle, which would otherwise read as "no match" and empty the list
    // before the user has typed anything.
    if (!inputValue) {
      return 1;
    }

    if (!itemValue) {
      return 0;
    }

    const result = fuzzysort.single(inputValue, itemValue);

    if (!result || result.score < threshold) {
      return 0;
    }

    return Math.max(result.score, MIN_MATCH_SCORE);
  };
}

/**
 * The default relevance filter: {@link createFuzzyFilter} at
 * {@link DEFAULT_MATCH_THRESHOLD}.
 *
 * @param itemValue - The label of an item in the list.
 * @param inputValue - The user's input text.
 * @returns A score above `0` when the item matches, `0` when it does not.
 */
export const defaultFilter = createFuzzyFilter();

/**
 * Filter `items` by `query`, ranking them when the filter returns scores.
 *
 * A blank query returns the items untouched, so the caller can render a
 * default list (recents, suggestions) without special-casing.
 *
 * @param items - The items to filter.
 * @param query - The user's input text.
 * @param filter - Scores or matches one item; defaults to {@link defaultFilter}.
 * @param labelFor - Extracts the text to match against; defaults to `String`.
 */
export function filterAndRankItems<T>(
  items: T[] | undefined,
  query: string,
  filter: FilterFn = defaultFilter,
  labelFor: (item: T) => string = (item) => String(item)
): T[] | undefined {
  if (!items || !query) {
    return items;
  }

  const matched: { item: T; score: number }[] = [];
  let isRanked = false;

  for (const item of items) {
    const result = filter(labelFor(item), query);

    if (typeof result === 'number') {
      isRanked = true;

      if (result > 0) {
        matched.push({ item, score: result });
      }
    } else if (result) {
      matched.push({ item, score: 0 });
    }
  }

  // Only reorder when the filter actually expressed relevance. A boolean filter
  // says nothing about order, so the source order is the only meaningful one.
  // Array.prototype.sort is stable (ES2019), so equal scores keep source order.
  if (isRanked) {
    matched.sort((a, b) => b.score - a.score);
  }

  return matched.map((entry) => entry.item);
}
