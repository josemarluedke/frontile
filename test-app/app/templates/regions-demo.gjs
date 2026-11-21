import pageTitle from 'ember-page-title/helpers/page-title';
import { AppLayout } from 'frontile';

<template>
  {{pageTitle "Regions Demo"}}
  <AppLayout @scrollMode="page" as |layout|>
    <layout.Navbar>
      <div class="ms-auto flex items-center gap-2">
        <layout.Region @name="actions"><span>No actions</span></layout.Region>
        <layout.AsideToggle />
      </div>
    </layout.Navbar>
    <layout.Main>{{outlet}}</layout.Main>
    <layout.Aside @region="aside" @label="Details" />
  </AppLayout>
</template>
