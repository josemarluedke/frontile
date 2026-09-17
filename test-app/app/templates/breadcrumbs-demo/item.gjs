import { Breadcrumbs } from 'frontile';

<template>
  <Breadcrumbs as |b|>
    <b.Item @route="breadcrumbs-demo.index">First</b.Item>
    <b.Item @route="breadcrumbs-demo.item" @model={{@model.item_id}}>Item
      {{@model.item_id}}</b.Item>
  </Breadcrumbs>
</template>
