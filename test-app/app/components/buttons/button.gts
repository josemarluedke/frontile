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
    <Button @variant="outline">
      Button
    </Button>
    <Button @variant="outline" @intent="primary">
      Primary
    </Button>
    <Button @variant="outline" @intent="success">
      Success
    </Button>
    <Button @variant="outline" @intent="warning">
      Warning
    </Button>
    <Button @variant="outline" @intent="danger">
      Danger
    </Button>
  </div>

  <div class="mt-6">
    <Button @variant="outline" disabled="true">
      Button
    </Button>
    <Button @variant="outline" disabled="true" @intent="primary">
      Primary
    </Button>
    <Button @variant="outline" disabled="true" @intent="success">
      Success
    </Button>
    <Button @variant="outline" disabled="true" @intent="warning">
      Warning
    </Button>
    <Button @variant="outline" disabled="true" @intent="danger">
      Danger
    </Button>
  </div>

  <h2 class="text-2xl mt-6">
    Minimal
  </h2>
  <div class="mt-6">
    <Button @variant="plain">
      Button
    </Button>
    <Button @variant="plain" @intent="primary">
      Primary
    </Button>
    <Button @variant="plain" @intent="success">
      Success
    </Button>
    <Button @variant="plain" @intent="warning">
      Warning
    </Button>
    <Button @variant="plain" @intent="danger">
      Danger
    </Button>
  </div>

  <div class="mt-6">
    <Button @variant="plain" disabled="true">
      Button
    </Button>
    <Button @variant="plain" disabled="true" @intent="primary">
      Primary
    </Button>
    <Button @variant="plain" disabled="true" @intent="success">
      Success
    </Button>
    <Button @variant="plain" disabled="true" @intent="warning">
      Warning
    </Button>
    <Button @variant="plain" disabled="true" @intent="danger">
      Danger
    </Button>
  </div>

  <h2 class="text-2xl mt-6">
    Custom
  </h2>
  <div class="mt-6">
    <Button @variant="custom">
      Button
    </Button>
    <Button @variant="custom" @intent="primary">
      Primary
    </Button>
    <Button @variant="custom" @intent="success">
      Success
    </Button>
    <Button @variant="custom" @intent="warning">
      Warning
    </Button>
    <Button @variant="custom" @intent="danger">
      Danger
    </Button>
  </div>

  <div class="mt-6">
    <Button @variant="custom" disabled="true">
      Button
    </Button>
    <Button @variant="custom" disabled="true" @intent="primary">
      Primary
    </Button>
    <Button @variant="custom" disabled="true" @intent="success">
      Success
    </Button>
    <Button @variant="custom" disabled="true" @intent="warning">
      Warning
    </Button>
    <Button @variant="custom" disabled="true" @intent="danger">
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
    <Button @variant="outline" @size="xs">
      XSmall
    </Button>
    <Button @variant="outline" @size="sm">
      Small
    </Button>
    <Button @variant="outline">
      Normal
    </Button>
    <Button @variant="outline" @size="lg">
      Large
    </Button>
    <Button @variant="outline" @size="xl">
      XLarge
    </Button>
  </div>

  <div class="mt-6">
    <Button @variant="plain" @size="xs">
      XSmall
    </Button>
    <Button @variant="plain" @size="sm">
      Small
    </Button>
    <Button @variant="plain">
      Normal
    </Button>
    <Button @variant="plain" @size="lg">
      Large
    </Button>
    <Button @variant="plain" @size="xl">
      XLarge
    </Button>
  </div>

  <div class="mt-6">
    <Button @variant="custom" @size="xs">
      XSmall
    </Button>
    <Button @variant="custom" @size="sm">
      Small
    </Button>
    <Button @variant="custom">
      Normal
    </Button>
    <Button @variant="custom" @size="lg">
      Large
    </Button>
    <Button @variant="custom" @size="xl">
      XLarge
    </Button>
  </div>
</template>;

export default Comp;
