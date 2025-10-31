import { ProgressBar } from 'frontile';
import { hash } from '@ember/helper';
import type { TOC } from '@ember/component/template-only';

const Comp: TOC<null> = <template>
  <h2 class="text-2xl mt-6">
    Intents
  </h2>
  <div class="mt-6 grid grid-cols-5 gap-4">
    <ProgressBar @progress={{50}} @label="Default" @showValueLabel={{false}} />
    <ProgressBar
      @progress={{50}}
      @label="Primary"
      @intent="primary"
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label="Success"
      @intent="success"
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label="Warning"
      @intent="warning"
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label="Danger"
      @intent="danger"
      @showValueLabel={{false}}
    />
  </div>

  <h2 class="text-2xl mt-6">
    Sizes
  </h2>
  <div class="mt-6 grid grid-cols-4 gap-4 items-center">
    <ProgressBar
      @progress={{50}}
      @size="xs"
      @label="XSmall"
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @size="sm"
      @label="Small"
      @showValueLabel={{false}}
    />
    <ProgressBar @progress={{50}} @label="Normal" @showValueLabel={{false}} />
    <ProgressBar
      @progress={{50}}
      @size="lg"
      @label="Large"
      @showValueLabel={{false}}
    />
  </div>

  <h2 class="text-2xl mt-6">
    Radius
  </h2>
  <div class="mt-6 grid grid-cols-4 gap-4">
    <ProgressBar
      @size="lg"
      @progress={{50}}
      @radius="none"
      @label="None"
      @showValueLabel={{false}}
    />
    <ProgressBar
      @size="lg"
      @progress={{50}}
      @radius="sm"
      @label="Small"
      @showValueLabel={{false}}
    />
    <ProgressBar
      @size="lg"
      @progress={{50}}
      @radius="lg"
      @label="Large"
      @showValueLabel={{false}}
    />
    <ProgressBar
      @size="lg"
      @progress={{50}}
      @radius="full"
      @label="Full"
      @showValueLabel={{false}}
    />
  </div>

  <h2 class="text-2xl mt-6">
    Labels
  </h2>
  <div class="mt-6 grid grid-cols-4 gap-4">
    <ProgressBar @progress={{50}} @label="With label" />
    <ProgressBar
      @progress={{20}}
      @minValue={{10}}
      @maxValue={{50}}
      @label="Interpolated progress"
    />
    <ProgressBar
      @progress={{50}}
      @label="Hiding label value"
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label="Custom label value"
      @valueLabel="4 out of 8"
    />
    <ProgressBar
      @progress={{25}}
      @label="Custom label value"
      @valueLabel="1/4"
    />
    <ProgressBar
      @progress={{50}}
      @label="Custom formatter"
      @formatOptions={{(hash style="currency" currency="USD")}}
    />
  </div>
  <h2 class="text-2xl mt-6">
    Indeterminate
  </h2>
  <div class="mt-6 grid grid-cols-2 gap-4">
    <ProgressBar @size="md" @label="Progress" @isIndeterminate={{true}} />
  </div>
  <div class="pt-16"></div>
</template>;

export default Comp;
