import pageTitle from 'ember-page-title/helpers/page-title';
import Demo from '../components/notifications/demo';
<template>
  {{pageTitle "Notifications"}}
  {{outlet}}

  <Demo />
</template>
