import fuzzysort from 'fuzzysort';

/**
 * Score or match an item against the current input text.
 *
 * Return a **number** to rank: higher sorts first and `0` (or any value at or
 * below it) means no match. Return a **boolean** to match without expressing
 * relevance — `true` normalizes to a full match (`1`) and `false` to `0`.
 *
 * Because a boolean filter scores every match identically, and the sort is
 * stable, a purely boolean filter leaves the order of `@items` untouched. That
 * is exactly the behavior filters had before scoring existed.
 */
export type FilterFn = (
  itemValue: string,
  inputValue: string
) => boolean | number;

/**
 * Guarantees a match is distinguishable from no match. `0` is load-bearing in
 * {@link FilterFn}, so a value that must count as a match is never allowed to
 * land exactly on it.
 */
const MIN_MATCH_SCORE = Number.EPSILON;

/**
 * Scores at or above this count as a match; anything below is discarded.
 *
 * This is fuzzysort's own default: `fuzzysort.go()` applies `threshold: 0.5`,
 * while `fuzzysort.single()` — which this filter uses, because it scores one
 * item at a time — applies none at all. Taking the threshold on ourselves keeps
 * us at the library's own quality bar rather than below it.
 *
 * It matters because fuzzy matching is *looser* than the `includes()` filter
 * this replaced, and fuzzysort cannot distinguish a useful abbreviation
 * (`btn` -> `Button`) from noise (`sa` -> `Spain`) — both are scattered mid-word
 * subsequences scoring ~0.32-0.36. Without a threshold, a two-letter query
 * against a country list returns two to three times as many rows as before,
 * most of them baffling.
 *
 * A threshold alone is not enough, though: genuine substring matches can score
 * *below* it (`ma` -> `Guatemala` is 0.500, `an` -> `Switzerland` is 0.447), so
 * see the substring floor in {@link createFuzzyFilter}.
 */
export const DEFAULT_MATCH_THRESHOLD = 0.5;

export interface FuzzyFilterOptions {
  /**
   * Minimum score to count as a match, between `0` and `1`. Lower it to trade
   * precision for recall — at `0`, `btn` matches `Button`, and `sa` also
   * matches `Spain`.
   *
   * Substring matches are never dropped regardless of this value.
   *
   * @defaultValue {@link DEFAULT_MATCH_THRESHOLD}
   */
  threshold?: number;
}

/**
 * Build a relevance filter backed by fuzzysort.
 *
 * The filter is a strict superset of a case-insensitive "contains" match: every
 * item `includes()` would have matched still matches, scored at no less than
 * the threshold, so raising the threshold can never make a result disappear
 * that used to be there. On top of that it matches acronyms and initialisms
 * (`bg` -> `ButtonGroup`, `nz` -> `New Zealand`) and orders everything by
 * relevance instead of by source position.
 *
 * @param options - See {@link FuzzyFilterOptions}.
 */
export function createFuzzyFilter(
  options: FuzzyFilterOptions = {}
): (itemValue: string, inputValue: string) => number {
  const threshold = options.threshold ?? DEFAULT_MATCH_THRESHOLD;

  // The query is the same for every candidate in a pass, so its lowercased
  // form is memoized rather than rebuilt once per item.
  let lastQuery: string | undefined;
  let lastQueryLower = '';

  return function fuzzyFilter(itemValue: string, inputValue: string): number {
    // A blank query matches everything. fuzzysort returns null for a blank or
    // whitespace-only needle, which would otherwise read as "no match" and
    // empty the list rather than leaving it alone.
    if (!inputValue.trim()) {
      return 1;
    }

    if (!itemValue) {
      return 0;
    }

    if (inputValue !== lastQuery) {
      lastQuery = inputValue;
      lastQueryLower = inputValue.toLowerCase();
    }

    const score = fuzzysort.single(inputValue, itemValue)?.score ?? 0;

    // The substring floor. This is what makes the filter a superset of the old
    // `includes()` default: a substring match is always a match, whatever it
    // scored, so the threshold only ever removes results that are new.
    if (itemValue.toLowerCase().includes(lastQueryLower)) {
      return Math.max(score, threshold, MIN_MATCH_SCORE);
    }

    return score >= threshold ? Math.max(score, MIN_MATCH_SCORE) : 0;
  };
}

/**
 * The default relevance filter: {@link createFuzzyFilter} at
 * {@link DEFAULT_MATCH_THRESHOLD}.
 */
export const defaultFilter = createFuzzyFilter();

/**
 * Weight applied to every field after the first.
 *
 * Fields are combined by weighted **max**, never by sum: summing lets three
 * weak field hits outrank one exact hit on the primary field.
 */
export const SECONDARY_FIELD_WEIGHT = 0.6;

/**
 * Normalize whatever a {@link FilterFn} returned into a score.
 *
 * `true` is a full match rather than a zero one — without this, a filter that
 * mixed booleans and numbers would sort its `true` results below every numeric
 * match, including the very weakest.
 *
 * `NaN` falls through to `0`, since no comparison with it is true.
 */
function toScore(result: boolean | number): number {
  if (typeof result === 'number') {
    return result > 0 ? result : 0;
  }

  return result ? 1 : 0;
}

/** Weighted max across fields; see {@link SECONDARY_FIELD_WEIGHT}. */
function scoreFields(
  values: string | string[],
  query: string,
  filter: FilterFn
): number {
  if (typeof values === 'string') {
    return toScore(filter(values, query));
  }

  let best = 0;

  values.forEach((value, index) => {
    const weight = index === 0 ? 1 : SECONDARY_FIELD_WEIGHT;
    best = Math.max(best, toScore(filter(value, query)) * weight);
  });

  return best;
}

/**
 * Filter `items` by `query`, ordering them by relevance.
 *
 * A blank query returns the items untouched, so a caller can render a default
 * list (recents, suggestions) without special-casing it.
 *
 * The sort is stable, so items scoring equally keep the order they were given.
 * A filter that only ever returns booleans scores every match identically and
 * therefore preserves the order of `items` exactly.
 *
 * @param items - The items to filter.
 * @param query - The user's input text.
 * @param labelFor - Extracts the text to match against. Return an array to
 * search several fields; the first is the primary one and the rest are
 * weighted by {@link SECONDARY_FIELD_WEIGHT}, combined by max.
 * @param filter - Scores one item; defaults to {@link defaultFilter}.
 */
export function filterAndRankItems<T>(
  items: T[] | undefined,
  query: string,
  labelFor: (item: T) => string | string[],
  filter: FilterFn = defaultFilter
): T[] | undefined {
  if (!items || !query.trim()) {
    return items;
  }

  const matched: { item: T; score: number }[] = [];

  for (const item of items) {
    const score = scoreFields(labelFor(item), query, filter);

    if (score > 0) {
      matched.push({ item, score });
    }
  }

  matched.sort((a, b) => b.score - a.score);

  return matched.map((entry) => entry.item);
}
