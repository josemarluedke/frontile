import type { TOC } from '@ember/component/template-only';
import type {
  SelectSlots,
  SelectVariants,
  SlotsToClasses
} from '@frontile/theme';
import { Spinner } from '../../utilities/spinner';
import { CloseButton } from '../../buttons/close-button';
import { IconChevronUpDown } from '../icons';
import type { SelectClasses } from './types';

const isSm = (size: SelectVariants['size']) => size === 'sm';

interface SelectEndContentSignature {
  Args: {
    classes: SelectClasses;
    userClasses?: SlotsToClasses<SelectSlots>;

    /**
     * Defaults to `none` so clicks fall through to the trigger; content that
     * needs its own events opts back in per element.
     */
    endContentPointerEvents?: 'none' | 'auto';

    inputSize?: SelectVariants['size'];
    isLoading?: boolean;

    /** Whether the clear button takes the chevron's place. */
    isClearable?: boolean;

    onClear: () => void;
  };
  Blocks: {
    /** Consumer content, rendered before the spinner/clear/chevron cluster. */
    default: [];
  };
  Element: HTMLDivElement;
}

/**
 * The cluster at the end of the field: any consumer content, then exactly one
 * of the loading spinner, the clear button, or the chevron.
 */
const SelectEndContent: TOC<SelectEndContentSignature> = <template>
  <div
    data-test-id="input-end-content"
    class={{@classes.endContent
      class=@userClasses.endContent
      endContentPointerEvents=(if
        @endContentPointerEvents @endContentPointerEvents "none"
      )
    }}
    ...attributes
  >
    {{yield}}

    {{#if @isLoading}}
      <Spinner
        @size={{if (isSm @inputSize) "xs" "sm"}}
        data-test-id="loading-spinner"
      />
    {{else if @isClearable}}
      <CloseButton
        @title="Clear"
        @variant="subtle"
        @size="xs"
        @class={{@classes.clearButton class=@userClasses.clearButton}}
        data-test-id="input-clear-button"
        @onPress={{@onClear}}
      />
    {{else}}
      <IconChevronUpDown class={{@classes.icon class=@userClasses.icon}} />
    {{/if}}
  </div>
</template>;

export { SelectEndContent, type SelectEndContentSignature };
export default SelectEndContent;
