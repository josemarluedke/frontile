---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Alert

Displays an important message inline in the page. Reach for Alert, rather than the
notifications service, when the message is part of the page and should stay there until the
page or the consumer removes it — a notification is transient and dismisses itself.

## Import

```js
import { Alert } from 'frontile';
```

## Usage

```gts preview
import { Alert } from 'frontile';

<template>
  <div class='demo-stack'>
    <Alert
      @title='Update available'
      @description='A new version is ready to install.'
    />
  </div>
</template>
```

## Intents

```gts preview
import { Alert } from 'frontile';

<template>
  <div class='demo-stack'>
    <Alert @title='Default' @description='A neutral, general-purpose message.' />
    <Alert
      @title='Info'
      @description='Something worth knowing about.'
      @intent='info'
    />
    <Alert
      @title='Success'
      @description='The operation completed.'
      @intent='success'
    />
    <Alert
      @title='Warning'
      @description='Something needs attention.'
      @intent='warning'
    />
    <Alert
      @title='Danger'
      @description='Something went wrong.'
      @intent='danger'
    />
  </div>
</template>
```

## Variants

`@variant` decides how much of the alert the intent colors, from a neutral
surface with a colored icon and title through to a fully filled one. Set it
alongside `@intent` — the three below are shown across all five intents.

### Default

A neutral surface; the intent shows in the icon and title only. Quiet enough to
sit in a page without competing with the content around it.

```gts preview
import { Alert } from 'frontile';

<template>
  <div class='demo-stack'>
    <Alert @intent='default' @title='Default' />
    <Alert @intent='info' @title='Info' />
    <Alert @intent='success' @title='Success' />
    <Alert @intent='warning' @title='Warning' />
    <Alert @intent='danger' @title='Danger' />
  </div>
</template>
```

### Tonal

A translucent tint of the intent fills the alert, over an opaque surface. More
presence than `default` without the weight of `solid`.

```gts preview
import { Alert } from 'frontile';

<template>
  <div class='demo-stack'>
    <Alert @variant='tonal' @intent='default' @title='Default' />
    <Alert @variant='tonal' @intent='info' @title='Info' />
    <Alert @variant='tonal' @intent='success' @title='Success' />
    <Alert @variant='tonal' @intent='warning' @title='Warning' />
    <Alert @variant='tonal' @intent='danger' @title='Danger' />
  </div>
</template>
```

### Solid

The intent fills the surface, with contrast ink on top. The loudest of the
three — worth reserving for something the reader should not miss.

```gts preview
import { Alert } from 'frontile';

<template>
  <div class='demo-stack'>
    <Alert @variant='solid' @intent='default' @title='Default' />
    <Alert @variant='solid' @intent='info' @title='Info' />
    <Alert @variant='solid' @intent='success' @title='Success' />
    <Alert @variant='solid' @intent='warning' @title='Warning' />
    <Alert @variant='solid' @intent='danger' @title='Danger' />
  </div>
</template>
```

## Banner

`@layout='banner'` drops the radius and border and centres the content, for an
announcement spanning the width of its container — a notice under a Drawer's
header, or across the top of a panel.

Width is not what the argument controls: an Alert is full-width in either
layout. What changes is that a banner has no edges of its own, so it reads as
part of the surface it sits on rather than as a card resting on it.

```gts preview
import { Alert } from 'frontile';

<template>
  <div class='demo-stack'>
    <div
      class='w-full overflow-hidden rounded-lg border border-surface-overlay-mild'
    >
      <div class='bg-surface-modal px-4 py-3 font-label text-label-xs'>
        Panel header
      </div>
      <Alert
        @layout='banner'
        @variant='tonal'
        @intent='warning'
        @title='This is the banner text'
      />
      <div class='bg-surface-modal px-4 py-6 text-body-2xs text-neutral-firm'>
        Panel content
      </div>
    </div>
  </div>
</template>
```

A banner's close button is pinned to the trailing edge instead of sitting in
the row, so the centred text stays put whether or not the alert is
dismissible — two banners, one dismissible and one not, still line up with
each other.

```gts preview
import { Alert, Button } from 'frontile';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

export default class BannerCloseExample extends Component {
  @tracked isVisible = true;

  close = () => {
    this.isVisible = false;
  };

  reset = () => {
    this.isVisible = true;
  };

  <template>
    <div class='demo-stack'>
      <div
        class='w-full overflow-hidden rounded-lg border border-surface-overlay-mild'
      >
        <Alert
          @layout='banner'
          @variant='tonal'
          @intent='info'
          @title='Not dismissible'
        />
        {{#if this.isVisible}}
          <Alert
            @layout='banner'
            @variant='tonal'
            @intent='info'
            @title='Dismissible'
            @onClose={{this.close}}
            @closeButtonTitle='Dismiss the banner'
          />
        {{/if}}
      </div>

      {{#unless this.isVisible}}
        <Button @size='xs' @onPress={{this.reset}}>Show the banner again</Button>
      {{/unless}}
    </div>
  </template>
}
```

## Icon

The `icon` block replaces the intent glyph with anything you pass it — a `Spinner` is a
convenient way to build a loading alert, since there is no dedicated loading argument.
`@hideIcon` removes it entirely and wins over the block.

```gts preview
import { Alert, Spinner } from 'frontile';

<template>
  <div class='demo-stack'>
    <Alert @title='Syncing'>
      <:icon><Spinner @size='sm' /></:icon>
    </Alert>

    <Alert @title='No icon' @hideIcon={{true}} />
  </div>
</template>
```

## Actions

The `actions` block renders buttons in a row between the content and the close button.
Alert follows the same styling convention as `NotificationCard`: `@size='xs'`, the first
button's `@intent` matching the alert's own, and any further button using
`@appearance='minimal'`.

```gts preview
import { Alert, Button } from 'frontile';

<template>
  <div class='demo-stack'>
    <Alert @intent='warning' @title='Unsaved changes' @description='Save before you leave?'>
      <:actions>
        <Button @size='xs' @intent='warning'>Save</Button>
        <Button @size='xs' @appearance='minimal'>Discard</Button>
      </:actions>
    </Alert>
  </div>
</template>
```

## Closing

Passing `@onClose` reveals the close button. Alert does not hide itself when it is
pressed — the consumer removes the Alert from the DOM, so animating it out or persisting
the dismissal is the application's to decide.

```gts preview
import { Alert, Button } from 'frontile';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

export default class ClosableAlertExample extends Component {
  @tracked isVisible = true;

  close = () => {
    this.isVisible = false;
  };

  reset = () => {
    this.isVisible = true;
  };

  <template>
    <div class='demo-stack'>
      {{#if this.isVisible}}
        <Alert
          @intent='success'
          @title='Changes saved'
          @onClose={{this.close}}
          @closeButtonTitle='Dismiss saved message'
        />
      {{else}}
        <Button @size='xs' @onPress={{this.reset}}>Show alert again</Button>
      {{/if}}
    </div>
  </template>
}
```

Set `@closeButtonTitle` when several alerts sit together, since every close button
otherwise announces as just "Close" without saying what is being dismissed.

## Rich content

The `description` block takes markup, such as a list, where the `@description` argument
only takes a string.

```gts preview
import { Alert } from 'frontile';

<template>
  <div class='demo-stack'>
    <Alert @intent='info' @title='Before you continue'>
      <:description>
        <ul class='list-disc pl-4'>
          <li>Your session expires in 10 minutes.</li>
          <li>Unsaved changes are not recovered.</li>
        </ul>
      </:description>
    </Alert>
  </div>
</template>
```

## Accessibility

`@intent` sets the ARIA role along with the color and icon: `warning` and `danger` render
`role="alert"`; every other intent renders `role="status"`. `@role` overrides this — use
`'none'` for an alert present in the DOM at first paint, where a live region announces
nothing useful and `alert` can interrupt a screen reader mid-page. Leave the default for an
alert inserted in response to an event, where the role is what gets it announced at all.

Colour alone should not carry the meaning of `@intent`. A `danger` alert reads as a problem
to a sighted user and as an ordinary alert to everyone else, so put the state in the
`@title` or `@description` as well.

## API

<Signature @component="Alert" />
