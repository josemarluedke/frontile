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
    <Chip @intent="primary">
      Primary
    </Chip>
    <Chip @intent="success">
      Success
    </Chip>
    <Chip @intent="warning">
      Warning
    </Chip>
    <Chip @intent="danger">
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
    <Chip @variant="outline" @intent="primary" @withDot={{true}}>
      Primary
    </Chip>
    <Chip @variant="outline" @intent="success" @withDot={{true}}>
      Success
    </Chip>
    <Chip @variant="outline" @intent="warning" @withDot={{true}}>
      Warning
    </Chip>
    <Chip @variant="outline" @intent="danger" @withDot={{true}}>
      Danger
    </Chip>
  </div>

  <div class="mt-6">
    <Chip @variant="outline" @onClose={{true}}>
      Chip
    </Chip>
    <Chip @variant="outline" @intent="primary" @onClose={{true}}>
      Primary
    </Chip>
    <Chip @variant="outline" @intent="success" @onClose={{true}}>
      Success
    </Chip>
    <Chip @variant="outline" @intent="warning" @onClose={{true}}>
      Warning
    </Chip>
    <Chip @variant="outline" @intent="danger" @onClose={{true}}>
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
    <Chip @variant="soft" @intent="primary" @withDot={{true}}>
      Primary
    </Chip>
    <Chip @variant="soft" @intent="success" @withDot={{true}}>
      Success
    </Chip>
    <Chip @variant="soft" @intent="warning" @withDot={{true}}>
      Warning
    </Chip>
    <Chip @variant="soft" @intent="danger" @withDot={{true}}>
      Danger
    </Chip>
  </div>

  <div class="mt-6">
    <Chip @variant="soft" @onClose={{true}}>
      Chip
    </Chip>
    <Chip @variant="soft" @intent="primary" @onClose={{true}}>
      Primary
    </Chip>
    <Chip @variant="soft" @intent="success" @onClose={{true}}>
      Success
    </Chip>
    <Chip @variant="soft" @intent="warning" @onClose={{true}}>
      Warning
    </Chip>
    <Chip @variant="soft" @intent="danger" @onClose={{true}}>
      Danger
    </Chip>
  </div>

  <div class="mt-6">
    <Chip @variant="soft" @onClose={{true}} @isDisabled={{true}}>
      Chip
    </Chip>
    <Chip
      @variant="soft"
      @intent="primary"
      @onClose={{true}}
      @isDisabled={{true}}
    >
      Primary
    </Chip>
    <Chip
      @variant="soft"
      @intent="success"
      @onClose={{true}}
      @isDisabled={{true}}
    >
      Success
    </Chip>
    <Chip
      @variant="soft"
      @intent="warning"
      @onClose={{true}}
      @isDisabled={{true}}
    >
      Warning
    </Chip>
    <Chip
      @variant="soft"
      @intent="danger"
      @onClose={{true}}
      @isDisabled={{true}}
    >
      Danger
    </Chip>
  </div>
</template>;

export default Comp;
