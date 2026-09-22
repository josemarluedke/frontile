import type {
  DateInputSlots,
  SlotsToClasses,
  useStyles
} from '@frontile/theme';
import type { FormControlSharedArgs } from '../form-control';

/** The resolved Tailwind Variants slot functions for this component. */
type DateInputClasses = ReturnType<ReturnType<typeof useStyles>['dateInput']>;

/** The editable units. Day granularity only -- see the spec's Out of scope. */
type SegmentType = 'year' | 'month' | 'day';

interface Segment {
  kind: 'segment';
  type: SegmentType;
  /** `null` until the user has entered something. */
  value: number | null;
  min: number;
  max: number;
  /**
   * Digits typed into this segment so far. Distinct from `value` because
   * typing `0` must show `00` and wait, which no number can represent.
   */
  buffer: string;
  /** How many digits the segment shows when filled: 2, or 4 for a year. */
  width: number;
  /** Rendered when `value` is null: 'mm', 'dd', 'yyyy'. */
  placeholder: string;
}

interface LiteralPart {
  kind: 'literal';
  text: string;
}

type Part = Segment | LiteralPart;

interface DateInputArgs extends FormControlSharedArgs {
  id?: string;
  /** The value submits under this name as `yyyy-MM-dd`. */
  name?: string;

  value?: Date | string | null;
  defaultValue?: Date | string | null;
  onChange?: (value: Date | null) => void;
  onBlur?: () => void;

  /** @defaultValue navigator.language */
  locale?: string;

  /**
   * Decides which segments appear, their order, and their literals.
   *
   * @defaultValue { year: 'numeric', month: '2-digit', day: '2-digit' }
   */
  formatOptions?: Intl.DateTimeFormatOptions;

  /** Where ArrowUp on an empty segment starts. @defaultValue today */
  placeholderValue?: Date;

  minValue?: Date;
  maxValue?: Date;
  isDateUnavailable?: (date: Date) => boolean;

  isReadOnly?: boolean;
  isClearable?: boolean;
  inputSize?: 'sm' | 'md' | 'lg';

  /** @defaultValue { year: 'year', month: 'month', day: 'day' } */
  segmentLabels?: Partial<Record<SegmentType, string>>;

  classes?: SlotsToClasses<DateInputSlots>;
}

export type {
  SegmentType,
  Segment,
  LiteralPart,
  Part,
  DateInputArgs,
  DateInputClasses
};
