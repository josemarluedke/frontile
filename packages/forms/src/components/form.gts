import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { dataFrom } from 'form-data-utils';

type FormResultData = ReturnType<typeof dataFrom>;

interface FormSignature {
  Element: HTMLFormElement;
  Args: {
    onChange: (
      data: FormResultData,
      eventType: 'input' | 'submit',
      event: Event | SubmitEvent
    ) => void;
  };
  Blocks: {
    default: [];
  };
}

class Form extends Component<FormSignature> {
  handleInput = (
    event: Event | SubmitEvent,
    eventType: 'input' | 'submit' = 'input'
  ) => {
    const form = event.currentTarget;
    if (form instanceof HTMLFormElement) {
      const data = dataFrom(event);
      this.args.onChange(data, eventType, event);
    }
  };

  handleSubmit = (event: SubmitEvent) => {
    event.preventDefault();
    this.handleInput(event, 'submit');
  };

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
