import Component from '@glimmer/component';
import { on } from '@ember/modifier';

type FormDataEntryValue = NonNullable<ReturnType<FormData['get']>>;
type FormResultData = Record<string, FormDataEntryValue>;

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
      let formData = new FormData(form);

      for (let i = 0; i < form.elements.length; i++) {
        const element = form.elements[i] as HTMLSelectElement;
        if (element.type === 'select-multiple') {
          const selectedValues = [];
          for (let j = 0; j < element.options.length; j++) {
            const option = element.options[j];
            if (option && option.selected) {
              selectedValues.push(option.value);
            }
          }
          formData.append(element.name, selectedValues.join(','));
        }
      }

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

export { Form, type FormSignature, type FormResultData };
export default Form;
