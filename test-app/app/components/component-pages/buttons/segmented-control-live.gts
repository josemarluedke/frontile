import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { SegmentedControl } from 'frontile';

type Range = 'day' | 'week' | 'month';

/** A controlled SegmentedControl with its value printed beside it. */
export default class SegmentedControlLive extends Component {
  @tracked value: Range = 'week';

  change = (value: Range): void => {
    this.value = value;
  };

  <template>
    <div class="flex flex-wrap items-center gap-4">
      <SegmentedControl
        @value={{this.value}}
        @onChange={{this.change}}
        @color="primary"
        aria-label="Date range"
        as |Ctl|
      >
        <Ctl.Item @value="day">day</Ctl.Item>
        <Ctl.Item @value="week">week</Ctl.Item>
        <Ctl.Item @value="month">month</Ctl.Item>
      </SegmentedControl>
      <p class="text-neutral-firm font-mono text-xs">
        value:
        <span data-segmented-live-value>{{this.value}}</span>
      </p>
    </div>
  </template>
}
