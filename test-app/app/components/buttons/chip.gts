import { Chip } from '@frontile/buttons';

<template>
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
    <Chip @appearance="outlined" @withDot={{true}}>
      Chip
    </Chip>
    <Chip @appearance="outlined" @intent="primary" @withDot={{true}}>
      Primary
    </Chip>
    <Chip @appearance="outlined" @intent="success" @withDot={{true}}>
      Success
    </Chip>
    <Chip @appearance="outlined" @intent="warning" @withDot={{true}}>
      Warning
    </Chip>
    <Chip @appearance="outlined" @intent="danger" @withDot={{true}}>
      Danger
    </Chip>
  </div>

  <div class="mt-6">
    <Chip @appearance="outlined" @onClose={{true}}>
      Chip
    </Chip>
    <Chip @appearance="outlined" @intent="primary" @onClose={{true}}>
      Primary
    </Chip>
    <Chip @appearance="outlined" @intent="success" @onClose={{true}}>
      Success
    </Chip>
    <Chip @appearance="outlined" @intent="warning" @onClose={{true}}>
      Warning
    </Chip>
    <Chip @appearance="outlined" @intent="danger" @onClose={{true}}>
      Danger
    </Chip>
  </div>

  <h2 class="text-2xl mt-6">
    Faded
  </h2>
  <div class="mt-6">
    <Chip @appearance="faded" @withDot={{true}}>
      Chip
    </Chip>
    <Chip @appearance="faded" @intent="primary" @withDot={{true}}>
      Primary
    </Chip>
    <Chip @appearance="faded" @intent="success" @withDot={{true}}>
      Success
    </Chip>
    <Chip @appearance="faded" @intent="warning" @withDot={{true}}>
      Warning
    </Chip>
    <Chip @appearance="faded" @intent="danger" @withDot={{true}}>
      Danger
    </Chip>
  </div>

  <div class="mt-6">
    <Chip @appearance="faded" @onClose={{true}}>
      Chip
    </Chip>
    <Chip @appearance="faded" @intent="primary" @onClose={{true}}>
      Primary
    </Chip>
    <Chip @appearance="faded" @intent="success" @onClose={{true}}>
      Success
    </Chip>
    <Chip @appearance="faded" @intent="warning" @onClose={{true}}>
      Warning
    </Chip>
    <Chip @appearance="faded" @intent="danger" @onClose={{true}}>
      Danger
    </Chip>
  </div>

  <div class="mt-6">
    <Chip @appearance="faded" @onClose={{true}} @isDisabled={{true}}>
      Chip
    </Chip>
    <Chip
      @appearance="faded"
      @intent="primary"
      @onClose={{true}}
      @isDisabled={{true}}
    >
      Primary
    </Chip>
    <Chip
      @appearance="faded"
      @intent="success"
      @onClose={{true}}
      @isDisabled={{true}}
    >
      Success
    </Chip>
    <Chip
      @appearance="faded"
      @intent="warning"
      @onClose={{true}}
      @isDisabled={{true}}
    >
      Warning
    </Chip>
    <Chip
      @appearance="faded"
      @intent="danger"
      @onClose={{true}}
      @isDisabled={{true}}
    >
      Danger
    </Chip>
  </div>
</template>
