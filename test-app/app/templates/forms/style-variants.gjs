import pageTitle from 'ember-page-title/helpers/page-title';
import Navigation from '../../components/forms/navigation';
import StyleVariants from '../../components/forms/style-variants';
<template>
  {{pageTitle "Forms"}}
  {{outlet}}

  <Navigation />
  <StyleVariants />
</template>
