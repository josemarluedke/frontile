import Component from '@glimmer/component';
import { on } from '@ember/modifier';

type FormDataEntryValue = NonNullable<ReturnType<FormData['get']>>;
type Data = Record<string, FormDataEntryValue>;

interface FormSignature {
  Element: HTMLFormElement;
  Args: {
    onChange: (
      data: Data,
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
    if (
      'currentTarget' in event &&
      event.currentTarget instanceof HTMLFormElement
    ) {
      let formData = new FormData(event.currentTarget);
      let data = Object.fromEntries(formData.entries());

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

export { Form, type FormSignature };
export default Form;
