import type { MaybeNamed } from '@glint/template/-private/signature';
import type {
  Invokable,
  NamedArgs,
  ComponentReturn
} from '@glint/template/-private/integration';

// Unfortunately, TypeScript cannot preserve unbounded generics through conditional types.
// This means we can't create a truly generic WithBoundArgsForComponent that works
// with the simple syntax you want AND preserves generics.
//
// The best we can do is create a helper that works for non-generic components,
// and handle generic components case-by-case.

// For non-generic components, this works:
export type WithBoundArgsForSignature<
  Sig extends { Args: unknown; Blocks?: unknown; Element?: unknown },
  BoundKeys extends keyof Sig['Args']
> = Invokable<
  (
    ...args: [
      ...positional: [],
      ...named: MaybeNamed<
        NamedArgs<
          Omit<Sig['Args'], BoundKeys> & Partial<Pick<Sig['Args'], BoundKeys>>
        >
      >
    ]
  ) => ComponentReturn<
    Sig extends { Blocks: infer B } ? B : {},
    Sig extends { Element: infer E } ? E : unknown
  >
>;
