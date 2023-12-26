import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { BufferedChangeset } from 'ember-changeset/types';
import { action } from '@ember/object';
import { assert } from '@ember/debug';
import { next } from '@ember/runloop';
import { hash, fn } from '@ember/helper';
import { on } from '@ember/modifier';
import ChangesetFormFieldsInput from './fields/input';
import ChangesetFormFieldsTextarea from './fields/textarea';
import ChangesetFormFieldsSelect from './fields/select';
import ChangesetFormFieldsCheckbox from './fields/checkbox';
import ChangesetFormFieldsCheckboxGroup from './fields/checkbox-group';
import ChangesetFormFieldsRadio from './fields/radio';
import ChangesetFormFieldsRadioGroup from './fields/radio-group';

export interface ChangesetFormArgs {
  /** Changeset Object */
  changeset: BufferedChangeset;

  /**
   * Run Changeset execute method instead of save
   * @defaultValue false
   * */
  runExecuteInsteadOfSave?: boolean;

  /**
   * Always show errors if there are any
   * @defaultValue false
   */
  alwaysShowErrors?: boolean;

  /**
   * Validate the changeset on initialization
   * @defaultValue false
   */
  validateOnInit?: boolean;

  /** Callback executed when from `onsubmit` event is triggered */
  onSubmit?: (data: unknown, event: Event) => void;

  /** Callback executed when from `onreset` event is triggered */
  onReset?: (data: unknown, event: Event) => void;
}

export interface ChangesetFormSignature {
  Args: ChangesetFormArgs;
  Blocks: {
    default: [
      {
        Input: ChangesetFormFieldsInput;
        Textarea: ChangesetFormFieldsTextarea;
        Select: ChangesetFormFieldsSelect;
        Checkbox: ChangesetFormFieldsCheckbox;
        CheckboxGroup: ChangesetFormFieldsCheckboxGroup;
        Radio: ChangesetFormFieldsRadio;
        RadioGroup: ChangesetFormFieldsRadioGroup;
        state: { hasSubmitted: boolean };
      }
    ];
  };
  Element: HTMLFormElement;
}

export default class ChangesetForm extends Component<ChangesetFormSignature> {
  @tracked hasSubmitted = false;

  constructor(owner: unknown, args: ChangesetFormArgs) {
    super(owner, args);
    assert(
      '@changeset must be defined on <ChangesetForm> component',
      this.args.changeset
    );

    if (this.args.validateOnInit) {
      next(() => {
        this.args.changeset.validate();
      });
    }
  }

  @action
  async handleSubmit(
    changeset: BufferedChangeset,
    event: Event
  ): Promise<void> {
    event.preventDefault();
    await changeset.validate();

    this.hasSubmitted = true;

    if (changeset.isInvalid) {
      return;
    }

    let result;
    if (this.args.runExecuteInsteadOfSave) {
      result = changeset.execute();
    } else {
      result = await changeset.save({});
    }

    if (typeof this.args.onSubmit === 'function') {
      this.args.onSubmit(result.data, event);
    }
  }

  @action
  handleReset(changeset: BufferedChangeset, event: Event): void {
    event.preventDefault();
    this.hasSubmitted = false;

    const { data } = changeset.rollback();
    if (typeof this.args.onReset === 'function') {
      this.args.onReset(data, event);
    }
  }

  <template>
    <form
      ...attributes
      {{on "submit" (fn this.handleSubmit @changeset)}}
      {{on "reset" (fn this.handleReset @changeset)}}
    >

      {{yield
        (hash
          Input=(component
            ChangesetFormFieldsInput
            changeset=@changeset
            hasSubmitted=this.hasSubmitted
            showError=@alwaysShowErrors
          )
          Textarea=(component
            ChangesetFormFieldsTextarea
            changeset=@changeset
            hasSubmitted=this.hasSubmitted
            showError=@alwaysShowErrors
          )
          Select=(component
            ChangesetFormFieldsSelect
            changeset=@changeset
            hasSubmitted=this.hasSubmitted
            showError=@alwaysShowErrors
          )
          Checkbox=(component
            ChangesetFormFieldsCheckbox
            changeset=@changeset
            hasSubmitted=this.hasSubmitted
            showError=@alwaysShowErrors
          )
          CheckboxGroup=(component
            ChangesetFormFieldsCheckboxGroup
            changeset=@changeset
            hasSubmitted=this.hasSubmitted
            showError=@alwaysShowErrors
          )
          Radio=(component
            ChangesetFormFieldsRadio
            changeset=@changeset
            hasSubmitted=this.hasSubmitted
            showError=@alwaysShowErrors
          )
          RadioGroup=(component
            ChangesetFormFieldsRadioGroup
            changeset=@changeset
            hasSubmitted=this.hasSubmitted
            showError=@alwaysShowErrors
          )
          state=(hash hasSubmitted=this.hasSubmitted)
        )
      }}

    </form>
  </template>
}
