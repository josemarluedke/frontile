import pageTitle from 'ember-page-title/helpers/page-title';
import ButtonCard from 'test-app/components/component-pages/buttons/button-card';
import ButtonGroupCard from 'test-app/components/component-pages/buttons/button-group-card';
import ToggleButtonCard from 'test-app/components/component-pages/buttons/toggle-button-card';
import ChipCard from 'test-app/components/component-pages/buttons/chip-card';
import CloseButtonCard from 'test-app/components/component-pages/buttons/close-button-card';
import SegmentedControlCard from 'test-app/components/component-pages/buttons/segmented-control-card';

<template>
  {{pageTitle "Buttons"}}
  <h1 class="text-neutral-bolder mb-6 text-2xl font-semibold">Buttons</h1>

  <div class="flex flex-col gap-8">
    <ButtonCard />
    <ButtonGroupCard />
    <ToggleButtonCard />
    <ChipCard />
    <CloseButtonCard />
    <SegmentedControlCard />
  </div>
</template>
