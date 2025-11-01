import pageTitle from 'ember-page-title/helpers/page-title';
import Utilities from '../components/utilities';
<template>
  {{pageTitle "Core"}}
  {{outlet}}

  <Utilities />
</template>
