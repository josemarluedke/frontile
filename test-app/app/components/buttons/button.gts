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
    <Button @color="primary">
      Primary
    </Button>
    <Button @color="success">
      Success
    </Button>
    <Button @color="warning">
      Warning
    </Button>
    <Button @color="danger">
      Danger
    </Button>
  </div>

  <div class="mt-6">
    <Button disabled="true">
      Default
    </Button>
    <Button disabled="true" @color="primary">
      Primary
    </Button>
    <Button disabled="true" @color="success">
      Success
    </Button>
    <Button disabled="true" @color="warning">
      Warning
    </Button>
    <Button disabled="true" @color="danger">
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
    <Button @variant="outline" @color="primary">
      Primary
    </Button>
    <Button @variant="outline" @color="success">
      Success
    </Button>
    <Button @variant="outline" @color="warning">
      Warning
    </Button>
    <Button @variant="outline" @color="danger">
      Danger
    </Button>
  </div>

  <div class="mt-6">
    <Button @variant="outline" disabled="true">
      Button
    </Button>
    <Button @variant="outline" disabled="true" @color="primary">
      Primary
    </Button>
    <Button @variant="outline" disabled="true" @color="success">
      Success
    </Button>
    <Button @variant="outline" disabled="true" @color="warning">
      Warning
    </Button>
    <Button @variant="outline" disabled="true" @color="danger">
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
    <Button @variant="plain" @color="primary">
      Primary
    </Button>
    <Button @variant="plain" @color="success">
      Success
    </Button>
    <Button @variant="plain" @color="warning">
      Warning
    </Button>
    <Button @variant="plain" @color="danger">
      Danger
    </Button>
  </div>

  <div class="mt-6">
    <Button @variant="plain" disabled="true">
      Button
    </Button>
    <Button @variant="plain" disabled="true" @color="primary">
      Primary
    </Button>
    <Button @variant="plain" disabled="true" @color="success">
      Success
    </Button>
    <Button @variant="plain" disabled="true" @color="warning">
      Warning
    </Button>
    <Button @variant="plain" disabled="true" @color="danger">
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
    <Button @variant="custom" @color="primary">
      Primary
    </Button>
    <Button @variant="custom" @color="success">
      Success
    </Button>
    <Button @variant="custom" @color="warning">
      Warning
    </Button>
    <Button @variant="custom" @color="danger">
      Danger
    </Button>
  </div>

  <div class="mt-6">
    <Button @variant="custom" disabled="true">
      Button
    </Button>
    <Button @variant="custom" disabled="true" @color="primary">
      Primary
    </Button>
    <Button @variant="custom" disabled="true" @color="success">
      Success
    </Button>
    <Button @variant="custom" disabled="true" @color="warning">
      Warning
    </Button>
    <Button @variant="custom" disabled="true" @color="danger">
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
