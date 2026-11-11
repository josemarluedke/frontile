import { array, hash } from '@ember/helper';
import { Alert, Button } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import {
  ALERT_LAYOUTS,
  ALERT_STATUSES,
  ALERT_VARIANTS
} from 'test-app/utils/workbench/options';

/** Shows the close button without doing anything. */
function noop(): void {}

<template>
  <WorkbenchCard
    @id="alert"
    @title="Alert"
    @description="An inline message. Takes @status rather than @color, because the status also picks the ARIA role: warning and danger render role=alert, the rest role=status. Neutral and primary share the info glyph and differ only in color."
    @sections={{array
      (hash id="matrix" label="Status × variant")
      (hash id="content" label="Content")
      (hash id="layout" label="Layout")
    }}
  >
    <WorkbenchSection
      @id="alert-matrix"
      @title="Status × variant"
      @subtitle="Every status in every variant"
    >
      <p class="text-neutral mb-3 text-sm">
        The surface and soft variants share the same outer box; soft adds a
        tinted inner fill, so the two differ most in dark mode.
      </p>
      <WorkbenchPanes @inverse={{true}}>
        <div class="flex flex-col gap-5">
          {{#each ALERT_STATUSES as |status|}}
            <div data-alert-row={{status}}>
              <WorkbenchSpecimen @label={{status}}>
                <div class="flex flex-col gap-2">
                  {{#each ALERT_VARIANTS as |variant|}}
                    <Alert
                      @status={{status}}
                      @variant={{variant}}
                      @title="{{status}} · {{variant}}"
                      @description="A short supporting sentence."
                      data-variant={{variant}}
                    />
                  {{/each}}
                </div>
              </WorkbenchSpecimen>
            </div>
          {{/each}}
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection
      @id="alert-content"
      @title="Content"
      @subtitle="Title, description, close, actions, icon"
    >
      <p class="text-neutral mb-3 text-sm">
        Shown in the surface variant with the primary status. A close button
        appears only when @onClose is passed; it does not hide the alert.
      </p>
      <WorkbenchPanes @inverse={{true}}>
        <div class="flex flex-col gap-4">
          <WorkbenchSpecimen @label="title only">
            <Alert @status="primary" @title="Title only" />
          </WorkbenchSpecimen>
          <WorkbenchSpecimen @label="description only">
            <Alert
              @status="primary"
              @description="Description only, with no heading above it."
            />
          </WorkbenchSpecimen>
          <WorkbenchSpecimen @label="title and description">
            <Alert
              @status="primary"
              @title="Title"
              @description="Description under the title."
            />
          </WorkbenchSpecimen>
          <WorkbenchSpecimen @label="close button">
            <Alert
              @status="primary"
              @title="Dismissible"
              @description="Pressing close does nothing here."
              @onClose={{noop}}
              @closeButtonTitle="Dismiss example alert"
            />
          </WorkbenchSpecimen>
          <WorkbenchSpecimen @label="actions block">
            <Alert
              @status="warning"
              @title="Needs a decision"
              @description="Buttons sit between the content and the close button."
              @onClose={{noop}}
              @closeButtonTitle="Dismiss alert with actions"
            >
              <:actions>
                <Button @size="xs" @variant="outline" @color="neutral">
                  Review
                </Button>
              </:actions>
            </Alert>
          </WorkbenchSpecimen>
          <WorkbenchSpecimen @label="hide icon">
            <Alert
              @status="success"
              @title="No icon"
              @description="Hiding the icon removes the glyph."
              @hideIcon={{true}}
            />
          </WorkbenchSpecimen>
          <WorkbenchSpecimen @label="icon block">
            <Alert
              @status="danger"
              @title="Custom icon"
              @description="The icon block replaces the status glyph."
            >
              <:icon>!</:icon>
            </Alert>
          </WorkbenchSpecimen>
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection
      @id="alert-layout"
      @title="Layout"
      @subtitle="Inline and banner"
    >
      <p class="text-neutral mb-3 text-sm">
        An Alert is w-full in both layouts, so width does not tell them apart. A
        banner drops the radius and border and centers its content. Here each
        sits inside a padded pane, so the banner spans the pane's content area,
        not the pane edge.
      </p>
      <WorkbenchPanes @inverse={{true}}>
        <div class="flex flex-col gap-4">
          {{#each ALERT_LAYOUTS as |layout|}}
            <WorkbenchSpecimen @label={{layout}}>
              <div class="flex flex-col gap-2">
                <Alert
                  @status="primary"
                  @layout={{layout}}
                  @title="{{layout}} layout"
                  @description="Same content, different shape."
                />
                <Alert
                  @status="primary"
                  @layout={{layout}}
                  @title="{{layout}} with close"
                  @onClose={{noop}}
                  @closeButtonTitle="Dismiss {{layout}} alert"
                />
              </div>
            </WorkbenchSpecimen>
          {{/each}}
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
