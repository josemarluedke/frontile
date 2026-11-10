import { Chip } from 'frontile';
import type { TOC } from '@ember/component/template-only';

const noop = () => {
  // demo only
};

const Comp: TOC<null> = <template>
  <h2 class="text-2xl mt-6">
    Sizes
  </h2>
  <div class="mt-6">
    <Chip @size="xs" @onClose={{noop}}>
      Extra small
    </Chip>
    <Chip @size="sm" @onClose={{noop}}>
      Small
    </Chip>
    <Chip @size="md" @onClose={{noop}}>
      Medium
    </Chip>
    <Chip @size="lg" @onClose={{noop}}>
      Large
    </Chip>
  </div>

  <h2 class="text-2xl mt-6">
    Radius
  </h2>
  <div class="mt-6">
    <Chip @radius="none">
      None
    </Chip>
    <Chip @radius="sm">
      Small
    </Chip>
    <Chip @radius="lg">
      Large
    </Chip>
    <Chip @radius="full">
      Full
    </Chip>
  </div>

  <h2 class="text-2xl mt-6">
    Default
  </h2>
  <div class="mt-6">
    <Chip>
      Default
    </Chip>
    <Chip @color="primary">
      Primary
    </Chip>
    <Chip @color="success">
      Success
    </Chip>
    <Chip @color="warning">
      Warning
    </Chip>
    <Chip @color="danger">
      Danger
    </Chip>
  </div>

  <h2 class="text-2xl mt-6">
    Outlined
  </h2>

  <div class="mt-6">
    <Chip @variant="outline" @withDot={{true}}>
      Chip
    </Chip>
    <Chip @variant="outline" @color="primary" @withDot={{true}}>
      Primary
    </Chip>
    <Chip @variant="outline" @color="success" @withDot={{true}}>
      Success
    </Chip>
    <Chip @variant="outline" @color="warning" @withDot={{true}}>
      Warning
    </Chip>
    <Chip @variant="outline" @color="danger" @withDot={{true}}>
      Danger
    </Chip>
  </div>

  <div class="mt-6">
    <Chip @variant="outline" @onClose={{noop}}>
      Chip
    </Chip>
    <Chip @variant="outline" @color="primary" @onClose={{noop}}>
      Primary
    </Chip>
    <Chip @variant="outline" @color="success" @onClose={{noop}}>
      Success
    </Chip>
    <Chip @variant="outline" @color="warning" @onClose={{noop}}>
      Warning
    </Chip>
    <Chip @variant="outline" @color="danger" @onClose={{noop}}>
      Danger
    </Chip>
  </div>

  <h2 class="text-2xl mt-6">
    Faded
  </h2>
  <div class="mt-6">
    <Chip @variant="soft" @withDot={{true}}>
      Chip
    </Chip>
    <Chip @variant="soft" @color="primary" @withDot={{true}}>
      Primary
    </Chip>
    <Chip @variant="soft" @color="success" @withDot={{true}}>
      Success
    </Chip>
    <Chip @variant="soft" @color="warning" @withDot={{true}}>
      Warning
    </Chip>
    <Chip @variant="soft" @color="danger" @withDot={{true}}>
      Danger
    </Chip>
  </div>

  <div class="mt-6">
    <Chip @variant="soft" @onClose={{noop}}>
      Chip
    </Chip>
    <Chip @variant="soft" @color="primary" @onClose={{noop}}>
      Primary
    </Chip>
    <Chip @variant="soft" @color="success" @onClose={{noop}}>
      Success
    </Chip>
    <Chip @variant="soft" @color="warning" @onClose={{noop}}>
      Warning
    </Chip>
    <Chip @variant="soft" @color="danger" @onClose={{noop}}>
      Danger
    </Chip>
  </div>

  <div class="mt-6">
    <Chip @variant="soft" @onClose={{noop}} @isDisabled={{true}}>
      Chip
    </Chip>
    <Chip
      @variant="soft"
      @color="primary"
      @onClose={{noop}}
      @isDisabled={{true}}
    >
      Primary
    </Chip>
    <Chip
      @variant="soft"
      @color="success"
      @onClose={{noop}}
      @isDisabled={{true}}
    >
      Success
    </Chip>
    <Chip
      @variant="soft"
      @color="warning"
      @onClose={{noop}}
      @isDisabled={{true}}
    >
      Warning
    </Chip>
    <Chip
      @variant="soft"
      @color="danger"
      @onClose={{noop}}
      @isDisabled={{true}}
    >
      Danger
    </Chip>
  </div>
</template>;

export default Comp;
