import pageTitle from 'ember-page-title/helpers/page-title';
import { Breadcrumbs } from 'frontile';

<template>
  {{pageTitle "Breadcrumbs Demo"}}
  <Breadcrumbs as |b|>
    <b.Item @route="breadcrumbs-demo.index">First</b.Item>
    <b.Item @route="breadcrumbs-demo.second">Second</b.Item>
    <b.Item
      @route="breadcrumbs-demo.second"
      @isDisabled={{true}}
      data-test-disabled-crumb
    >Disabled</b.Item>
  </Breadcrumbs>
  {{outlet}}
</template>
