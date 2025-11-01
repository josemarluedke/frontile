import pageTitle from 'ember-page-title/helpers/page-title';
import Navigation from '../../components/forms-legacy/navigation';
import FormExample from '../../components/forms-legacy/form-example';
<template>
  {{pageTitle "Forms"}}
  {{outlet}}

  <Navigation />
  <FormExample />
</template>
