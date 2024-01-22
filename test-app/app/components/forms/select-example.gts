import Select from '@frontile/forms/components/form-field/select';
const animals = [
  'cheetah',
  'crocodile',
  'elephant',
  'giraffe',
  'kangaroo',
  'koala',
  'lemming',
  'lemur',
  'lion',
  'lobster',
  'panda',
  'penguin',
  'tiger',
  'zebra'
];

<template>
  <Select
    @options={{animals}}
  >

    <:option as |o|>
      <o.Option>
        {{o.option}}
      </o.Option>
    </:option>
  </Select>

  <Select
    class="mt-8"
    @options={{animals}}
  >
    <:trigger>Trigger</:trigger>
  </Select>
</template>
