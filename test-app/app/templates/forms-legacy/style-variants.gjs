import pageTitle from 'ember-page-title/helpers/page-title';
import Navigation from '../../components/forms-legacy/navigation';
import StyleVariants from '../../components/forms-legacy/style-variants';
<template>
  {{pageTitle "Forms"}}
  {{outlet}}

  <Navigation />
  <StyleVariants />
</template>
