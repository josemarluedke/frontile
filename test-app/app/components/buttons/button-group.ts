import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

interface ExampleArgs { }

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
}
