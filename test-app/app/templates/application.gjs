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
        <sidebar.Item @route="index">Home</sidebar.Item>

        <sidebar.Group @label="Foundations">
          <sidebar.Item @route="foundations.theme">Theme</sidebar.Item>
          <sidebar.Item @route="foundations.palette">Palette</sidebar.Item>
          <sidebar.Item
            @route="foundations.typography"
          >Typography</sidebar.Item>
          <sidebar.Item @route="foundations.global">Global</sidebar.Item>
        </sidebar.Group>

        <sidebar.Group @label="Components">
          <sidebar.Item @route="component-pages.buttons">Buttons</sidebar.Item>
          <sidebar.Item @route="component-pages.form-controls">Form controls</sidebar.Item>
          <sidebar.Item @route="component-pages.status">Status</sidebar.Item>
        </sidebar.Group>

        <sidebar.Group @label="Demos">
          <sidebar.Item @route="overlays">Overlays</sidebar.Item>
          <sidebar.Item @route="notifications">Notifications</sidebar.Item>
        </sidebar.Group>

        <sidebar.Folder @label="Fixtures" as |folder|>
          <folder.Item @route="sidebar-demo">Sidebar</folder.Item>
          <folder.Item @route="platform-demo">Platform shell</folder.Item>
          <folder.Item @route="breadcrumbs-demo">Breadcrumbs</folder.Item>
          <folder.Item @route="tab-nav-demo">Tab nav</folder.Item>
        </sidebar.Folder>
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
