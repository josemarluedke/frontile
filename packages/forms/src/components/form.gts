import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { dataFrom } from 'form-data-utils';

type FormResultData = ReturnType<typeof dataFrom>;

interface FormSignature {
  Element: HTMLFormElement;
  Args: {
    onChange?: (data: FormResultData, event: Event) => void;

    onSubmit: (
      data: FormResultData,
      event: SubmitEvent
    ) => void | Promise<void>;
  };
  Blocks: {
    default: [];
  };
}

class Form extends Component<FormSignature> {
  @action
  handleInput(event: Event) {
    const form = event.currentTarget;
    if (form instanceof HTMLFormElement && this.args.onChange) {
      const data = dataFrom(event);
      this.args.onChange(data, event);
    }
  }

  @action
  async handleSubmit(event: SubmitEvent) {
    event.preventDefault();
    const form = event.currentTarget;
    if (form instanceof HTMLFormElement && this.args.onSubmit) {
      const data = dataFrom(event);
      await this.args.onSubmit(data, event);
    }
  }

  <template>
    <form
      {{on "input" this.handleInput}}
      {{on "submit" this.handleSubmit}}
      ...attributes
    >
      {{yield}}
    </form>
  </template>
}

export { Form, type FormSignature, type FormResultData };
export default Form;
