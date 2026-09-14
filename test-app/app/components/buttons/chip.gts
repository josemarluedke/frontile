import { Chip } from 'frontile';
import type { TOC } from '@ember/component/template-only';

const Comp: TOC<null> = <template>
  <h2 class="text-2xl mt-6">
    Sizes
  </h2>
  <div class="mt-6">
    <Chip @size="sm" @onClose={{true}}>
      Small
    </Chip>
    <Chip @size="md" @onClose={{true}}>
      Medium
    </Chip>
    <Chip @size="lg" @onClose={{true}}>
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
    <Chip @variant="outline" @onClose={{true}}>
      Chip
    </Chip>
    <Chip @variant="outline" @color="primary" @onClose={{true}}>
      Primary
    </Chip>
    <Chip @variant="outline" @color="success" @onClose={{true}}>
      Success
    </Chip>
    <Chip @variant="outline" @color="warning" @onClose={{true}}>
      Warning
    </Chip>
    <Chip @variant="outline" @color="danger" @onClose={{true}}>
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
    <Chip @variant="soft" @onClose={{true}}>
      Chip
    </Chip>
    <Chip @variant="soft" @color="primary" @onClose={{true}}>
      Primary
    </Chip>
    <Chip @variant="soft" @color="success" @onClose={{true}}>
      Success
    </Chip>
    <Chip @variant="soft" @color="warning" @onClose={{true}}>
      Warning
    </Chip>
    <Chip @variant="soft" @color="danger" @onClose={{true}}>
      Danger
    </Chip>
  </div>

  <div class="mt-6">
    <Chip @variant="soft" @onClose={{true}} @isDisabled={{true}}>
      Chip
    </Chip>
    <Chip
      @variant="soft"
      @color="primary"
      @onClose={{true}}
      @isDisabled={{true}}
    >
      Primary
    </Chip>
    <Chip
      @variant="soft"
      @color="success"
      @onClose={{true}}
      @isDisabled={{true}}
    >
      Success
    </Chip>
    <Chip
      @variant="soft"
      @color="warning"
      @onClose={{true}}
      @isDisabled={{true}}
    >
      Warning
    </Chip>
    <Chip
      @variant="soft"
      @color="danger"
      @onClose={{true}}
      @isDisabled={{true}}
    >
      Danger
    </Chip>
  </div>
</template>;

export default Comp;
