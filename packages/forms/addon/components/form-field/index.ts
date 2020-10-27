import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';

interface FormFieldArgs {
  size?: 'sm' | 'lg';
}

export default class FormField extends Component<FormFieldArgs> {
  id = guidFor(this);

  get hintId(): string {
    return this.id + '-hint';
  }

  get feedbackId(): string {
    return this.id + '-feedback';
  }
}
