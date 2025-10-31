import { Button } from 'frontile';
import type { TOC } from '@ember/component/template-only';

const Comp: TOC<null> = <template>
  <h2 class="text-2xl mt-6">
    Default
  </h2>
  <div class="mt-6">
    <Button>
      Default
    </Button>
    <Button @intent="primary">
      Primary
    </Button>
    <Button @intent="success">
      Success
    </Button>
    <Button @intent="warning">
      Warning
    </Button>
    <Button @intent="danger">
      Danger
    </Button>
  </div>

  <div class="mt-6">
    <Button disabled="true">
      Default
    </Button>
    <Button disabled="true" @intent="primary">
      Primary
    </Button>
    <Button disabled="true" @intent="success">
      Success
    </Button>
    <Button disabled="true" @intent="warning">
      Warning
    </Button>
    <Button disabled="true" @intent="danger">
      Danger
    </Button>
  </div>

  <h2 class="text-2xl mt-6">
    Outlined
  </h2>

  <div class="mt-6">
    <Button @appearance="outlined">
      Button
    </Button>
    <Button @appearance="outlined" @intent="primary">
      Primary
    </Button>
    <Button @appearance="outlined" @intent="success">
      Success
    </Button>
    <Button @appearance="outlined" @intent="warning">
      Warning
    </Button>
    <Button @appearance="outlined" @intent="danger">
      Danger
    </Button>
  </div>

  <div class="mt-6">
    <Button @appearance="outlined" disabled="true">
      Button
    </Button>
    <Button @appearance="outlined" disabled="true" @intent="primary">
      Primary
    </Button>
    <Button @appearance="outlined" disabled="true" @intent="success">
      Success
    </Button>
    <Button @appearance="outlined" disabled="true" @intent="warning">
      Warning
    </Button>
    <Button @appearance="outlined" disabled="true" @intent="danger">
      Danger
    </Button>
  </div>

  <h2 class="text-2xl mt-6">
    Minimal
  </h2>
  <div class="mt-6">
    <Button @appearance="minimal">
      Button
    </Button>
    <Button @appearance="minimal" @intent="primary">
      Primary
    </Button>
    <Button @appearance="minimal" @intent="success">
      Success
    </Button>
    <Button @appearance="minimal" @intent="warning">
      Warning
    </Button>
    <Button @appearance="minimal" @intent="danger">
      Danger
    </Button>
  </div>

  <div class="mt-6">
    <Button @appearance="minimal" disabled="true">
      Button
    </Button>
    <Button @appearance="minimal" disabled="true" @intent="primary">
      Primary
    </Button>
    <Button @appearance="minimal" disabled="true" @intent="success">
      Success
    </Button>
    <Button @appearance="minimal" disabled="true" @intent="warning">
      Warning
    </Button>
    <Button @appearance="minimal" disabled="true" @intent="danger">
      Danger
    </Button>
  </div>

  <h2 class="text-2xl mt-6">
    Custom
  </h2>
  <div class="mt-6">
    <Button @appearance="custom">
      Button
    </Button>
    <Button @appearance="custom" @intent="primary">
      Primary
    </Button>
    <Button @appearance="custom" @intent="success">
      Success
    </Button>
    <Button @appearance="custom" @intent="warning">
      Warning
    </Button>
    <Button @appearance="custom" @intent="danger">
      Danger
    </Button>
  </div>

  <div class="mt-6">
    <Button @appearance="custom" disabled="true">
      Button
    </Button>
    <Button @appearance="custom" disabled="true" @intent="primary">
      Primary
    </Button>
    <Button @appearance="custom" disabled="true" @intent="success">
      Success
    </Button>
    <Button @appearance="custom" disabled="true" @intent="warning">
      Warning
    </Button>
    <Button @appearance="custom" disabled="true" @intent="danger">
      Danger
    </Button>
  </div>

  <h2 class="text-2xl mt-6">
    Sizes
  </h2>
  <div class="mt-6">
    <Button @size="xs">
      XSmall
    </Button>
    <Button @size="sm">
      Small
    </Button>
    <Button>
      Normal
    </Button>
    <Button @size="lg">
      Large
    </Button>
    <Button @size="xl">
      XLarge
    </Button>
  </div>

  <div class="mt-6">
    <Button @appearance="outlined" @size="xs">
      XSmall
    </Button>
    <Button @appearance="outlined" @size="sm">
      Small
    </Button>
    <Button @appearance="outlined">
      Normal
    </Button>
    <Button @appearance="outlined" @size="lg">
      Large
    </Button>
    <Button @appearance="outlined" @size="xl">
      XLarge
    </Button>
  </div>

  <div class="mt-6">
    <Button @appearance="minimal" @size="xs">
      XSmall
    </Button>
    <Button @appearance="minimal" @size="sm">
      Small
    </Button>
    <Button @appearance="minimal">
      Normal
    </Button>
    <Button @appearance="minimal" @size="lg">
      Large
    </Button>
    <Button @appearance="minimal" @size="xl">
      XLarge
    </Button>
  </div>

  <div class="mt-6">
    <Button @appearance="custom" @size="xs">
      XSmall
    </Button>
    <Button @appearance="custom" @size="sm">
      Small
    </Button>
    <Button @appearance="custom">
      Normal
    </Button>
    <Button @appearance="custom" @size="lg">
      Large
    </Button>
    <Button @appearance="custom" @size="xl">
      XLarge
    </Button>
  </div>
</template>;

export default Comp;
