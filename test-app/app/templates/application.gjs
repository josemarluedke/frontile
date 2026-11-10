import { AppLayout } from 'frontile';
import { Button } from 'frontile/buttons';
import ThemeSwitcher from '../components/theme-switcher';

<template>
  <AppLayout @scrollMode="page" as |layout|>
    <layout.Sidebar @label="Playground" @collapsible="none" as |sidebar|>
      <sidebar.Header>
        <span class="truncate text-sm font-semibold text-primary">
          Frontile playground
        </span>
      </sidebar.Header>
      <sidebar.Body>
        <sidebar.Group @label="0 Overview">
          <sidebar.Item @route="index">Home</sidebar.Item>
        </sidebar.Group>

        <sidebar.Group @label="1 Global">
          <sidebar.Item @route="foundations.global">Global</sidebar.Item>
        </sidebar.Group>

        <sidebar.Group @label="2 Palette">
          <sidebar.Item @route="foundations.palette">Palette</sidebar.Item>
        </sidebar.Group>

        <sidebar.Group @label="3 Theme">
          <sidebar.Item @route="foundations.theme">Theme</sidebar.Item>
        </sidebar.Group>

        <sidebar.Group @label="4 Typography">
          <sidebar.Item
            @route="foundations.typography"
          >Typography</sidebar.Item>
        </sidebar.Group>

        <sidebar.Group @label="5 Components">
          <sidebar.Item @route="component-pages.buttons">Buttons</sidebar.Item>
          <sidebar.Item @route="component-pages.form-controls">Form controls</sidebar.Item>
          <sidebar.Item @route="component-pages.status">Status</sidebar.Item>
        </sidebar.Group>

        <sidebar.Group @label="6 Live demos">
          <sidebar.Item @route="overlays">Overlays</sidebar.Item>
          <sidebar.Item @route="notifications">Notifications</sidebar.Item>
        </sidebar.Group>

        <sidebar.Group @label="7 Legacy packages">
          <sidebar.Item @route="forms-legacy">Forms (Legacy)</sidebar.Item>
          <sidebar.Item @route="changeset-form">Changeset Form</sidebar.Item>
        </sidebar.Group>

        <sidebar.Group @label="8 Fixtures">
          <sidebar.Item @route="sidebar-demo">Sidebar</sidebar.Item>
          <sidebar.Item @route="platform-demo">Platform shell</sidebar.Item>
          <sidebar.Item @route="breadcrumbs-demo">Breadcrumbs</sidebar.Item>
          <sidebar.Item @route="tab-nav-demo">Tab nav</sidebar.Item>
        </sidebar.Group>
      </sidebar.Body>
    </layout.Sidebar>

    <layout.Navbar>
      <layout.MenuToggle />
      <div class="ms-auto flex items-center gap-2">
        <ThemeSwitcher />
        <Button @size="xs" @variant="outline" @isRenderless={{true}} as |btn|>
          <a href="/tests?hidepassed" class={{btn.classNames}}>
            Go to Tests
          </a>
        </Button>
      </div>
    </layout.Navbar>

    <layout.Main>
      <div class="p-4 md:p-6">
        {{outlet}}
      </div>
    </layout.Main>
  </AppLayout>
</template>
