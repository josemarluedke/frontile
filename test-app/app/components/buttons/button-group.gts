import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { ButtonGroup } from '@frontile/buttons';

interface ExampleArgs {}

export default class Example extends Component<ExampleArgs> {
  @tracked
  isSelected = {
    first: false,
    second: false,
    third: false
  };

  @action
  onChange(ty: keyof typeof this.isSelected, value: boolean): void {
    this.isSelected[ty] = value;
    this.isSelected = { ...this.isSelected };
  }

  <template>
    <h2 class="text-2xl mt-6">
      ButtonGroup
    </h2>
    <div class="mt-6">
      <ButtonGroup as |g|>
        <g.Button>First</g.Button>
        <g.Button>Second</g.Button>
        <g.Button>Third</g.Button>
      </ButtonGroup>

      <ButtonGroup @size="sm" @intent="primary" as |g|>
        {{#each-in this.isSelected as |key val|}}
          <g.ToggleButton
            @isSelected={{val}}
            @onChange={{(fn this.onChange key)}}
          >
            {{key}}
          </g.ToggleButton>
        {{/each-in}}
      </ButtonGroup>
    </div>
  </template>
}
