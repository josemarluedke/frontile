import pageTitle from 'ember-page-title/helpers/page-title';
import Navigation from '../../components/forms/navigation';
import FormExample from '../../components/forms/form-example';
<template>
  {{pageTitle "Forms"}}
  {{outlet}}

  <Navigation />
  <FormExample />
</template>
