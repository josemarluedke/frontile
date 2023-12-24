import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import FormFieldCheckbox from './form-field/checkbox';
import FormFieldFeedback from './form-field/feedback';
import FormFieldHint from './form-field/hint';
import FormFieldInput from './form-field/input';
import FormFieldLabel from './form-field/label';
import FormFieldRadio from './form-field/radio';
import FormFieldTextarea from './form-field/textarea';
import type { WithBoundArgs } from '@glint/template';

export interface FormFieldArgs {
  size?: 'sm' | 'lg';
}

export interface FormFieldSignature {
  Args: FormFieldArgs;
  Blocks: {
    default: [
      {
        id: string;
        hintId: string;
        feedbackId: string;
        Label: WithBoundArgs<typeof FormFieldLabel, 'for'> &
          WithBoundArgs<typeof FormFieldLabel, 'size'>;
        Hint: WithBoundArgs<typeof FormFieldHint, 'id'> &
          WithBoundArgs<typeof FormFieldHint, 'size'>;
        Feedback: WithBoundArgs<typeof FormFieldFeedback, 'id'> &
          WithBoundArgs<typeof FormFieldFeedback, 'size'>;
        Input: WithBoundArgs<typeof FormFieldInput, 'id'> &
          WithBoundArgs<typeof FormFieldInput, 'size'>;
        Textarea: WithBoundArgs<typeof FormFieldTextarea, 'id'> &
          WithBoundArgs<typeof FormFieldTextarea, 'size'>;
        Checkbox: WithBoundArgs<typeof FormFieldCheckbox, 'id'> &
          WithBoundArgs<typeof FormFieldCheckbox, 'size'>;
        Radio: WithBoundArgs<typeof FormFieldRadio, 'id'> &
          WithBoundArgs<typeof FormFieldRadio, 'size'>;
      }
    ];
  };
  Element: HTMLDivElement;
}

export default class FormField extends Component<FormFieldSignature> {
  id = guidFor(this);

  get hintId(): string {
    return this.id + '-hint';
  }

  get feedbackId(): string {
    return this.id + '-feedback';
  }

  <template>
    <div ...attributes>
      {{yield
        (hash
          id=this.id
          hintId=this.hintId
          feedbackId=this.feedbackId
          Label=(component FormFieldLabel for=this.id size=@size)
          Hint=(component FormFieldHint id=this.hintId size=@size)
          Feedback=(component FormFieldFeedback id=this.feedbackId size=@size)
          Input=(component FormFieldInput id=this.id size=@size)
          Textarea=(component FormFieldTextarea id=this.id size=@size)
          Checkbox=(component FormFieldCheckbox id=this.id size=@size)
          Radio=(component FormFieldRadio id=this.id size=@size)
        )
      }}
    </div>
  </template>
}
