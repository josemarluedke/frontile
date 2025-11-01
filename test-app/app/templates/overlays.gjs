import pageTitle from 'ember-page-title/helpers/page-title';
import Popover from '../components/overlays/popover';
import DemoDrawer from '../components/overlays/demo-drawer';
import DemoModal from '../components/overlays/demo-modal';
<template>
  {{pageTitle "Overlays"}}
  {{outlet}}

  <Popover />
  <DemoDrawer />
  <DemoModal />
</template>
