import pageTitle from 'ember-page-title/helpers/page-title';
import InputCard from 'test-app/components/component-pages/form-controls/input-card';
import TextareaCard from 'test-app/components/component-pages/form-controls/textarea-card';
import SelectCard from 'test-app/components/component-pages/form-controls/select-card';
import NativeSelectCard from 'test-app/components/component-pages/form-controls/native-select-card';
import CheckboxCard from 'test-app/components/component-pages/form-controls/checkbox-card';
import CheckboxGroupCard from 'test-app/components/component-pages/form-controls/checkbox-group-card';
import RadioCard from 'test-app/components/component-pages/form-controls/radio-card';
import RadioGroupCard from 'test-app/components/component-pages/form-controls/radio-group-card';
import SwitchCard from 'test-app/components/component-pages/form-controls/switch-card';
import InputOtpCard from 'test-app/components/component-pages/form-controls/input-otp-card';
import FieldPartsCard from 'test-app/components/component-pages/form-controls/field-parts-card';
import FormLiveCard from 'test-app/components/component-pages/form-controls/form-live-card';

<template>
  {{pageTitle "Form controls"}}
  <h1 class="text-neutral-bolder mb-6 text-2xl font-semibold">Form controls</h1>

  <div class="flex flex-col gap-8">
    <InputCard />
    <TextareaCard />
    <SelectCard />
    <NativeSelectCard />
    <CheckboxCard />
    <CheckboxGroupCard />
    <RadioCard />
    <RadioGroupCard />
    <SwitchCard />
    <InputOtpCard />
    <FieldPartsCard />
    <FormLiveCard />
  </div>
</template>
