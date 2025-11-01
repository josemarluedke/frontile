import pageTitle from 'ember-page-title/helpers/page-title';
import Dropdown from '../components/buttons/dropdown';
import ToggleButton from '../components/buttons/toggle-button';
import ButtonGroup from '../components/buttons/button-group';
import Button from '../components/buttons/button';
import Chip from '../components/buttons/chip';
import ProgressBar from '../components/buttons/progress-bar';
import Listbox from '../components/buttons/listbox';
<template>
  {{pageTitle "Buttons"}}
  {{outlet}}
  <Dropdown />
  <ToggleButton />
  <ButtonGroup />
  <Button />
  <Chip />
  <ProgressBar />
  <Listbox />
</template>
