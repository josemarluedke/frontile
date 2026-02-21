import Component from '@glimmer/component';
import type { CellRenderingContext } from './cell-rendering-context';
import type { Column, Row } from './types';

interface CellDefaultSignature<T> {
  Args: {
    /**
     * The Column object for the current cell
     */
    column: Column<T>;

    /**
     * Registry to check for claimed keys
     */
    registry: CellRenderingContext;

    /**
     * Optional array of keys to exclude from default rendering
     * (alternative to using the registry system)
     */
    except?: string[];
  };

  Blocks: {
    default: [];
  };
}

/**
 * Default/fallback rendering component for table cells. Only renders its content
 * when no CellForComponent has claimed the current column key.
 *
 * Usage:
 * ```hbs
 * <c.Default>
 *   Default: {{c.value}}
 * </c.Default>
 *
 * <!-- Or with explicit exclusions -->
 * <c.Default @except={{array "status" "actions"}}>
 *   {{c.value}}
 * </c.Default>
 * ```
 */
export default class CellDefaultComponent<T> extends Component<
  CellDefaultSignature<T>
> {
  get shouldRender(): boolean {
    const currentKey = this.args.column.key;

    // Check explicit exclusions first
    if (this.args.except?.includes(currentKey)) {
      return false;
    }

    // Check if any CellForComponent has claimed this key
    return !this.args.registry.isKeyClaimed(currentKey);
  }

  <template>
    {{#if this.shouldRender}}
      {{yield}}
    {{/if}}
  </template>
}
