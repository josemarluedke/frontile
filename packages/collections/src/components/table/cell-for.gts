import Component from '@glimmer/component';
import type { CellRenderingContext } from './cell-rendering-context';
import type { Column, Row, ColumnConfig, ColumnKeys } from './types';

interface CellForSignature<
  T,
  TColumns extends ColumnConfig<T>[] = ColumnConfig<T>[]
> {
  Args: {
    /**
     * The column key to match against the current column.
     * When used with defineColumns(), this is type-checked against available column keys.
     */
    key: ColumnKeys<TColumns>;

    /**
     * The column object for the current cell
     */
    column: Column<T>;

    /**
     * Registry to track claimed keys
     */
    registry: CellRenderingContext;
  };

  Blocks: {
    default: [];
  };
}

/**
 * Conditional rendering component for table cells. Only renders its content
 * when the current column key matches the specified @key argument.
 *
 * Usage:
 * ```hbs
 * <c.For @key="status">
 *   <StatusBadge @status={{c.value}} />
 * </c.For>
 * ```
 */
export default class CellForComponent<
  T,
  TColumns extends ColumnConfig<T>[] = ColumnConfig<T>[]
> extends Component<CellForSignature<T, TColumns>> {
  get shouldRender(): boolean {
    const matches = this.args.column.key === this.args.key;

    // If this component matches the current column, claim the key
    // so that CellDefaultComponent knows not to render
    if (matches) {
      this.args.registry.claimKey(this.args.key);
    }

    return matches;
  }

  <template>
    {{#if this.shouldRender}}
      {{yield}}
    {{/if}}
  </template>
}
