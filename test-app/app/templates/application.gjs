import { AppLayout } from 'frontile';
import { Button } from 'frontile/buttons';
import { LinkTo } from '@ember/routing';
import ThemeSwitcher from '../components/theme-switcher';
import Logo from '../components/logo';
import IconHouse from '~icons/lucide/house';
import IconPalette from '~icons/lucide/palette';
import IconSwatchBook from '~icons/lucide/swatch-book';
import IconType from '~icons/lucide/type';
import IconRuler from '~icons/lucide/ruler';
import IconMousePointerClick from '~icons/lucide/mouse-pointer-click';
import IconTextCursorInput from '~icons/lucide/text-cursor-input';
import IconActivity from '~icons/lucide/activity';
import IconLayers from '~icons/lucide/layers';
import IconBell from '~icons/lucide/bell';
import IconFlaskConical from '~icons/lucide/flask-conical';
import IconPanelLeft from '~icons/lucide/panel-left';
import IconAppWindow from '~icons/lucide/app-window';
import IconChevronsRight from '~icons/lucide/chevrons-right';
import IconPanelsTopLeft from '~icons/lucide/panels-top-left';

<template>
  <AppLayout @scrollMode="page" as |layout|>
    <layout.Sidebar @label="Playground" @collapsible="none" as |sidebar|>
      <sidebar.Header>
        <LinkTo
          @route="index"
          aria-label="Frontile home"
          class="text-primary inline-flex items-center rounded-sm"
        >
          <Logo class="h-5 w-auto" aria-hidden="true" />
        </LinkTo>
      </sidebar.Header>
      <sidebar.Body>
        <sidebar.Item @route="index" @icon={{IconHouse}}>Home</sidebar.Item>

        <sidebar.Group @label="Foundations">
          <sidebar.Item
            @route="foundations.theme"
            @icon={{IconPalette}}
          >Theme</sidebar.Item>
          <sidebar.Item
            @route="foundations.palette"
            @icon={{IconSwatchBook}}
          >Palette</sidebar.Item>
          <sidebar.Item
            @route="foundations.typography"
            @icon={{IconType}}
          >Typography</sidebar.Item>
          <sidebar.Item
            @route="foundations.global"
            @icon={{IconRuler}}
          >Global</sidebar.Item>
        </sidebar.Group>

        <sidebar.Group @label="Components">
          <sidebar.Item
            @route="component-pages.buttons"
            @icon={{IconMousePointerClick}}
          >Buttons</sidebar.Item>
          <sidebar.Item
            @route="component-pages.form-controls"
            @icon={{IconTextCursorInput}}
          >Form controls</sidebar.Item>
          <sidebar.Item
            @route="component-pages.status"
            @icon={{IconActivity}}
          >Status</sidebar.Item>
        </sidebar.Group>

        <sidebar.Group @label="Demos">
          <sidebar.Item
            @route="overlays"
            @icon={{IconLayers}}
          >Overlays</sidebar.Item>
          <sidebar.Item
            @route="notifications"
            @icon={{IconBell}}
          >Notifications</sidebar.Item>
        </sidebar.Group>

        <sidebar.Folder
          @label="Fixtures"
          @icon={{IconFlaskConical}}
          as |folder|
        >
          <folder.Item
            @route="sidebar-demo"
            @icon={{IconPanelLeft}}
          >Sidebar</folder.Item>
          <folder.Item @route="platform-demo" @icon={{IconAppWindow}}>Platform
            shell</folder.Item>
          <folder.Item
            @route="breadcrumbs-demo"
            @icon={{IconChevronsRight}}
          >Breadcrumbs</folder.Item>
          <folder.Item @route="tab-nav-demo" @icon={{IconPanelsTopLeft}}>Tab nav</folder.Item>
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
