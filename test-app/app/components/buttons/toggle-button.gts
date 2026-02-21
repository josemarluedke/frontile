import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { ToggleButton } from 'frontile/buttons';

interface ExampleArgs {}

export default class Example extends Component<ExampleArgs> {
  @tracked
  isSelected = {
    default: false,
    primary: false,
    success: false,
    warning: false,
    danger: false
  };

  @action
  onChange(ty: keyof typeof this.isSelected, value: boolean): void {
    this.isSelected[ty] = value;
    this.isSelected = { ...this.isSelected };
  }

  <template>
    <h2 class="text-2xl mt-6">
      ToggleButton
    </h2>
    <div class="mt-6">
      {{#each-in this.isSelected as |key val|}}
        <ToggleButton
          @isSelected={{val}}
          @onChange={{fn this.onChange key}}
          @intent={{key}}
        >
          Toggle
        </ToggleButton>
      {{/each-in}}
    </div>

    <div class="mt-6">
      {{#each-in this.isSelected as |key val|}}
        <ToggleButton
          @isSelected={{val}}
          @onChange={{fn this.onChange key}}
          @intent={{key}}
          disabled={{true}}
        >
          Toggle
        </ToggleButton>
      {{/each-in}}
    </div>
  </template>
}
