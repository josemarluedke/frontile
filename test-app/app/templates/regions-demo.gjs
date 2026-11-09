import pageTitle from 'ember-page-title/helpers/page-title';
import { AppLayout, breadcrumb } from 'frontile';

<template>
  {{pageTitle "Regions Demo"}}
  {{breadcrumb "Home" route="regions-demo.index"}}
  <AppLayout @scrollMode="page" as |layout|>
    <layout.Navbar>
      <layout.Breadcrumbs />
      <div class="ms-auto flex items-center gap-2">
        <layout.Region @name="actions" />
        <layout.AsideToggle />
      </div>
    </layout.Navbar>
    <layout.Main>{{outlet}}</layout.Main>
    <layout.Aside @region="aside" @label="Details" />
  </AppLayout>
</template>
