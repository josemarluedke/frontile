import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { ButtonGroup, ToggleButton } from 'frontile';

/** Real toggles: each click flips tracked state and so `aria-pressed`. */
export default class ToggleButtonLive extends Component {
  @tracked bold = true;
  @tracked italic = false;
  @tracked underline = false;

  setBold = (value: boolean): void => {
    this.bold = value;
  };
  setItalic = (value: boolean): void => {
    this.italic = value;
  };
  setUnderline = (value: boolean): void => {
    this.underline = value;
  };

  <template>
    <div class="flex flex-wrap items-center gap-6">
      <div class="flex gap-2">
        <ToggleButton @isSelected={{this.bold}} @onChange={{this.setBold}}>
          Bold
        </ToggleButton>
        <ToggleButton
          @color="primary"
          @isSelected={{this.italic}}
          @onChange={{this.setItalic}}
        >
          Italic
        </ToggleButton>
      </div>
      <ButtonGroup @color="primary" @size="sm" aria-label="Formatting" as |g|>
        <g.ToggleButton
          @isSelected={{this.bold}}
          @onChange={{this.setBold}}
        >Bold</g.ToggleButton>
        <g.ToggleButton
          @isSelected={{this.italic}}
          @onChange={{this.setItalic}}
        >Italic</g.ToggleButton>
        <g.ToggleButton
          @isSelected={{this.underline}}
          @onChange={{this.setUnderline}}
        >Underline</g.ToggleButton>
      </ButtonGroup>
    </div>
  </template>
}
