import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { DocfyLink } from '@docfy/ember';
import { NotificationCard, Notification } from 'frontile/notifications';
import {
  Avatar,
  Button,
  ButtonGroup,
  Checkbox,
  Chip,
  Divider,
  Drawer,
  Dropdown,
  Field,
  Modal,
  ProgressBar,
  RadioGroup,
  Skeleton,
  Spinner,
  Switch,
  Table,
  type ColumnConfig
} from 'frontile';
import {
  ViewIcon,
  EditIcon,
  ShareIcon,
  ArchiveIcon,
  DeleteIcon
} from '../components/icons';
import AppSpecimen from '../components/homepage/app-specimen';
import ThemeSeam from '../components/homepage/theme-seam';
import ThemeLab from '../components/homepage/theme-lab';
import KeyboardProof from '../components/homepage/keyboard-proof';
import SpecimenTile from '../components/homepage/specimen-tile';
import CodePanel from '../components/homepage/code-panel';
import LinkButton from '../components/homepage/link-button';
import { inventory } from '../components/homepage/component-inventory';

/**
 * DIRECTION CONTRACT — Frontile homepage
 *
 * THESIS: A component set sold by showing it working, not by counting it.
 * Refuses the category's icon-heading-text feature grid and its
 * adoption-number proof bar — neither of which Frontile can honestly ship.
 *
 * OWN-WORLD: Frontile's own tokens, unmodified. Warm-neutral grounds stepping
 * between surface-app and surface-canvas, low-chroma teal for every
 * interaction, status hues only where they mean status. Domine for the single
 * marquee moment, Open Sans for structure, Source Code Pro for specimens. No
 * literal colors and no gradient text. The one deliberate flourish is the code
 * window: dark in both schemes because the bundled syntax theme is, lifted by
 * an offset teal glow drawn from primary-soft.
 *
 * STORY: A skeptical Ember developer sees real components working in both
 * schemes at once, believes the default theme is finished, and goes exploring —
 * into the specimen wall, the theming lab, and the docs.
 *
 * FIRST VIEWPORT: Left, a marquee headline claiming beautiful and
 * production-ready, one sentence substantiating it with accessibility, typed
 * templates, and Tailwind Variants, then two doors — components and theming.
 * Below, the live app specimen bisected by a draggable theme seam.
 *
 * FORM: Split-theme page — candidate 4 of 7 on the ordered list, assigned by
 * seed 9a7052ef (degraded roll: no challengers dealt). Staging: the seam runs
 * through a composed product UI rather than through the page chrome.
 */

interface Member {
  id: string;
  name: string;
  email: string;
  role: string;
}

const tableMembers: Member[] = [
  { id: '1', name: 'Ada Okonkwo', email: 'ada@example.com', role: 'Owner' },
  { id: '2', name: 'Bruno Salas', email: 'bruno@example.com', role: 'Editor' },
  { id: '3', name: 'Chen Wei', email: 'chen@example.com', role: 'Viewer' },
  { id: '4', name: 'Dara Whitfield', email: 'dara@example.com', role: 'Editor' }
];

const signatureSnippet = `import { Table, type ColumnConfig } from 'frontile';

interface Member { id: string; name: string; role: string }

const columns = [
  { key: 'name', name: 'Member' },
  { key: 'role', name: 'Role' }
] as const satisfies ColumnConfig<Member>[];`;

// Written as a constant rather than inline in the template: a `{{...}}` inside
// a quoted attribute is interpolated by Glimmer, which is how the previous
// homepage silently rendered `@rows=` with no value in its own code sample.
const templateSnippet = `<Table @columns={{columns}} @items={{members}} />

{{! Glint checks this against ColumnConfig<Member>: }}
<Table @columns={{columns}} @items={{projects}} />
{{! ^ Type 'Project[]' is not assignable to 'Member[]' }}`;

const toast = new Notification({}, 'Invitation sent to ada@example.com', {
  appearance: 'success',
  transitionDuration: 0
});

export default class IndexPage extends Component {
  @tracked isModalOpen = false;
  @tracked isDrawerOpen = false;
  @tracked notifyByEmail = true;

  inventory = inventory;
  members = tableMembers;
  toast = toast;
  signatureSnippet = signatureSnippet;
  templateSnippet = templateSnippet;

  columns = [
    { key: 'name', name: 'Member' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<Member>[];

  @action
  openModal(): void {
    this.isModalOpen = true;
  }

  @action
  closeModal(): void {
    this.isModalOpen = false;
  }

  @action
  openDrawer(): void {
    this.isDrawerOpen = true;
  }

  @action
  closeDrawer(): void {
    this.isDrawerOpen = false;
  }

  @action
  setNotifyByEmail(value: boolean): void {
    this.notifyByEmail = value;
  }

  <template>
    <div class="bg-surface-app relative">

      {{! ------------------------------------------------------------------ }}
      {{! The seam — one UI, both themes, at once }}
      {{! ------------------------------------------------------------------ }}
      <section class="ambient pt-16 pb-20 sm:pt-24 sm:pb-28">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="max-w-3xl">
            <p class="eyebrow rise-text">Ember component library</p>
            <h1
              class="mt-5 font-marquee text-marquee-lg sm:text-marquee-xl lg:text-marquee-3xl text-neutral-bolder text-balance rise-text rise-step-1"
            >
              Beautiful, production-ready components for Ember.js.
            </h1>
            <p
              class="mt-6 font-body text-body-sm sm:text-body-md text-neutral-firm text-pretty max-w-xl rise-text rise-step-2"
            >
              Accessible by construction, typed all the way into your templates
              with TypeScript and Glint, and styled with Tailwind Variants.
            </p>
            <div
              class="mt-9 flex flex-wrap items-center gap-3 rise rise-step-3"
            >
              <LinkButton
                @to="/docs/components/buttons/button"
                @intent="primary"
                @size="lg"
              >Explore the components</LinkButton>
              <LinkButton
                @to="/docs/theming/overview"
                @appearance="outlined"
                @size="lg"
              >How theming works</LinkButton>
            </div>
          </div>
        </div>

        <div
          class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-14 rise rise-step-4"
        >
          <ThemeSeam
            @description="A workspace members panel built from Frontile's Avatar,
              Button, Chip, Divider, Input, Table, and ProgressBar components,
              rendered simultaneously in the light and dark themes and divided by
              a draggable seam."
          >
            <:specimen>
              <AppSpecimen />
            </:specimen>
          </ThemeSeam>
          <p
            class="mt-4 font-caption text-caption-sm text-neutral-firm max-w-2xl"
          >
            <span class="hidden sm:inline">Drag the seam.</span>
            Both sides are the same markup. Nothing was restyled, duplicated, or
            patched up for dark mode.
          </p>
        </div>
      </section>

      {{! ------------------------------------------------------------------ }}
      {{! Specimen wall — breadth, as doors }}
      {{! ------------------------------------------------------------------ }}
      <section class="ambient ambient--wall py-24 sm:py-28 bg-primary-subtle">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="max-w-2xl mb-14 reveal">
            <p class="eyebrow mb-4">The library</p>
            <h2
              class="font-header text-header-2xl sm:text-header-3xl text-neutral-bolder text-balance"
            >Start anywhere</h2>
            <p class="mt-4 font-body text-body-sm text-neutral-firm text-pretty">
              Every tile below is the real component, rendered by the library, and a
              link straight into its documentation.
            </p>
          </div>

          <div class="specimen-wall">
            <SpecimenTile
              @name="Button"
              @path="/docs/components/buttons/button"
              @note="Five intents, three appearances, four sizes"
            >
              <div class="flex flex-wrap gap-2 justify-center">
                <Button @intent="primary" @size="sm">Primary</Button>
                <Button @appearance="outlined" @size="sm">Outlined</Button>
              </div>
            </SpecimenTile>

            <SpecimenTile
              @name="Table"
              @path="/docs/components/collections/table"
              @note="Sorting, selection, sticky headers, typed columns"
              @isWide={{true}}
            >
              <Table @columns={{this.columns}} @items={{this.members}} />
            </SpecimenTile>

            <SpecimenTile
              @name="Field"
              @path="/docs/components/forms/field"
              @note="Labels, hints, and validation wired together"
            >
              <Field @name="tile-email" as |field|>
                <field.Input
                  @label="Email"
                  @size="sm"
                  @value="ada@example.com"
                />
              </Field>
            </SpecimenTile>

            <SpecimenTile
              @name="Switch"
              @path="/docs/components/forms/switch"
              @note="Labelled by the component, not by you"
            >
              <div class="flex flex-col gap-3">
                <Switch @label="Email digest" @isSelected={{true}} />
                <Switch @label="Push alerts" @isSelected={{false}} />
              </div>
            </SpecimenTile>

            <SpecimenTile
              @name="Chip"
              @path="/docs/components/buttons/chip"
              @note="Status, filters, and removable tags"
            >
              <div class="flex flex-wrap gap-2 justify-center">
                <Chip @intent="primary" @size="sm">Active</Chip>
                <Chip @intent="success" @size="sm" @withDot={{true}}>Live</Chip>
                <Chip @intent="danger" @size="sm">Failed</Chip>
              </div>
            </SpecimenTile>

            <SpecimenTile
              @name="Avatar"
              @path="/docs/components/utilities/avatar"
              @note="Initials, images, and shape variants"
            >
              <div class="flex gap-2 justify-center">
                <Avatar @size="sm" @name="Ada Okonkwo" />
                <Avatar @size="md" @name="Bruno Salas" />
                <Avatar @size="lg" @name="Chen Wei" />
              </div>
            </SpecimenTile>

            <SpecimenTile
              @name="ProgressBar"
              @path="/docs/components/status/progress-bar"
              @note="Determinate, indeterminate, and labelled"
            >
              <div class="w-full space-y-3">
                <ProgressBar
                  @intent="primary"
                  @label="Upload"
                  @progress={{72}}
                />
                <ProgressBar @intent="success" @progress={{100}} @size="sm" />
              </div>
            </SpecimenTile>

            <SpecimenTile
              @name="Skeleton"
              @path="/docs/components/utilities/skeleton"
              @note="Shapes that match the content they stand in for"
            >
              <div class="w-full flex items-center gap-3">
                <Skeleton @shape="circle" @size="md" />
                <div class="flex-1 space-y-2">
                  <Skeleton @shape="text" @size="sm" />
                  <Skeleton @shape="text" @size="sm" />
                </div>
              </div>
            </SpecimenTile>

            <SpecimenTile
              @name="ButtonGroup"
              @path="/docs/components/buttons/button-group"
              @note="Segmented and toggling groups"
            >
              <ButtonGroup @size="sm" as |g|>
                <g.ToggleButton @isSelected={{true}}>Day</g.ToggleButton>
                <g.ToggleButton>Week</g.ToggleButton>
                <g.ToggleButton>Month</g.ToggleButton>
              </ButtonGroup>
            </SpecimenTile>

            <SpecimenTile
              @name="Checkbox"
              @path="/docs/components/forms/checkbox"
              @note="Grouped, indeterminate, and validated"
            >
              <div class="flex flex-col gap-2">
                <Checkbox @label="Ship weekly report" @checked={{true}} />
                <Checkbox @label="Include drafts" @checked={{false}} />
              </div>
            </SpecimenTile>

            <SpecimenTile
              @name="Spinner"
              @path="/docs/components/utilities/spinner"
              @note="Four sizes, inherits the current intent"
            >
              <div class="flex items-center gap-4">
                <Spinner @size="sm" />
                <Spinner @size="md" />
                <Spinner @size="lg" />
              </div>
            </SpecimenTile>

            <SpecimenTile
              @name="RadioGroup"
              @path="/docs/components/forms/radio"
              @note="Grouped, labelled, and keyboard-navigable"
            >
              <RadioGroup @name="tile-theme" @value="dark" as |Radio|>
                <Radio @label="Light mode" @value="light" />
                <Radio @label="Dark mode" @value="dark" />
              </RadioGroup>
            </SpecimenTile>

            <SpecimenTile
              @name="Notifications"
              @path="/docs/components/notifications/notifications"
              @note="Toasts with live regions and auto-dismiss"
            >
              <div class="w-full">
                <NotificationCard
                  @notification={{this.toast}}
                  @placement="top-right"
                />
              </div>
            </SpecimenTile>

          </div>
        </div>
      </section>

      {{! ------------------------------------------------------------------ }}
      {{! Overlays — the things a specimen tile cannot show }}
      {{! ------------------------------------------------------------------ }}
      <section class="py-24 sm:py-28">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div
            class="grid grid-cols-1 lg:grid-cols-[minmax(0,26rem)_1fr] gap-10 items-start"
          >
            <div class="reveal">
              <p class="eyebrow mb-4">Overlays</p>
              <h2
                class="font-header text-header-2xl text-neutral-bolder text-balance"
              >The parts you have to open</h2>
              <p class="mt-4 font-body text-body-sm text-neutral-firm text-pretty">
                Overlays are where component libraries usually leak: focus
                escapes, the background scrolls, Escape does nothing. Open these
                and try to break them, then read how the focus trap is built.
              </p>
              <div class="mt-6 flex flex-wrap gap-3">
                <Button @intent="primary" @onPress={{this.openModal}}>
                  Open a modal
                </Button>
                <Button @appearance="outlined" @onPress={{this.openDrawer}}>
                  Open a drawer
                </Button>
              </div>
              <p class="mt-4 font-body text-body-sm text-neutral-firm">
                <DocfyLink
                  @to="/docs/accessibility/focus-management"
                  class="text-primary-firm underline"
                >Read the focus management guide</DocfyLink>
              </p>
            </div>

            <div
              class="rounded-xl border border-neutral-soft bg-surface-canvas p-6 reveal"
            >
              <Dropdown as |d|>
                <d.Trigger @intent="primary" @size="sm">
                  Row actions
                </d.Trigger>
                <d.Menu as |Item|>
                  <Item @key="view" @description="Open in read-only mode">
                    <:start><ViewIcon /></:start>
                    <:default>View details</:default>
                  </Item>
                  <Item @key="edit" @description="Change roles and seats">
                    <:start><EditIcon /></:start>
                    <:default>Edit member</:default>
                  </Item>
                  <Item
                    @key="share"
                    @description="Send an invitation"
                    @withDivider={{true}}
                  >
                    <:start><ShareIcon /></:start>
                    <:default>Share</:default>
                  </Item>
                  <Item @key="archive" @description="Keep the record, revoke access">
                    <:start><ArchiveIcon /></:start>
                    <:default>Archive</:default>
                  </Item>
                  <Item
                    @key="remove"
                    @intent="danger"
                    @description="Permanently remove"
                  >
                    <:start><DeleteIcon /></:start>
                    <:default>Remove member</:default>
                  </Item>
                </d.Menu>
              </Dropdown>
              <p class="mt-4 font-body text-body-sm text-neutral-firm">
                Arrow keys move, typeahead jumps, Escape closes and returns focus
                to the trigger. Descriptions and shortcuts are arguments, not
                markup you assemble.
              </p>
            </div>
          </div>
        </div>

        <Modal
          @isOpen={{this.isModalOpen}}
          @onClose={{this.closeModal}}
          @size="md"
          as |modal|
        >
          <modal.Header>Invite a member</modal.Header>
          <modal.Body>
            <p class="font-body text-body-sm text-neutral-firm mb-4">
              Focus is trapped inside this dialog, the page behind it will not
              scroll, and Escape closes it. Tab around and see.
            </p>
            <Field @name="invite-email" as |field|>
              <field.Input @label="Email address" @type="email" />
            </Field>
            <div class="mt-4">
              <Switch
                @label="Notify by email"
                @isSelected={{this.notifyByEmail}}
                @onChange={{this.setNotifyByEmail}}
              />
            </div>
          </modal.Body>
          <modal.Footer class="flex justify-end gap-3">
            <Button @onPress={{this.closeModal}}>Cancel</Button>
            <Button @intent="primary" @onPress={{this.closeModal}}>
              Send invite
            </Button>
          </modal.Footer>
        </Modal>

        <Drawer
          @isOpen={{this.isDrawerOpen}}
          @onClose={{this.closeDrawer}}
          @placement="right"
          @size="md"
          as |drawer|
        >
          <drawer.Header>Member details</drawer.Header>
          <drawer.Body>
            <div class="flex items-center gap-3 mb-6">
              <Avatar @size="lg" @name="Bruno Salas" />
              <div>
                <p
                  class="font-header text-header-sm text-neutral-strong"
                >Bruno Salas</p>
                <p
                  class="font-caption text-caption-sm text-neutral-firm"
                >bruno@example.com</p>
              </div>
            </div>
            <ProgressBar
              @intent="primary"
              @label="Storage used"
              @progress={{42}}
            />
            <div class="mt-6 flex flex-wrap gap-2">
              <Chip @size="sm">Editor</Chip>
              <Chip @size="sm" @intent="success" @withDot={{true}}>Active</Chip>
            </div>
          </drawer.Body>
          <drawer.Footer class="flex justify-end">
            <Button @onPress={{this.closeDrawer}}>Close</Button>
          </drawer.Footer>
        </Drawer>
      </section>

      {{! ------------------------------------------------------------------ }}
      {{! Theming laboratory }}
      {{! ------------------------------------------------------------------ }}
      <section
        class="ambient ambient--lab py-24 sm:py-28 bg-secondary-subtle dark:bg-surface-canvas"
      >
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="max-w-2xl mb-14 reveal">
            <p class="eyebrow mb-4">Theming</p>
            <h2
              class="font-header text-header-2xl sm:text-header-3xl text-neutral-bolder text-balance"
            >Make it look like your product</h2>
            <p class="mt-4 font-body text-body-sm text-neutral-firm text-pretty">
              Frontile's colors are semantic roles at named levels, not a numbered
              scale. Swap the ramp and every component follows, in both
              themes, with no rebuild.
            </p>
          </div>

          <div class="reveal">
            <ThemeLab />
          </div>

          <div class="mt-10 flex flex-wrap gap-3 reveal">
            <LinkButton
              @to="/docs/theming/design-tokens/colors"
              @appearance="outlined"
            >Color tokens</LinkButton>
            <LinkButton
              @to="/docs/theming/component-styles"
              @appearance="outlined"
            >Restyle a component</LinkButton>
            <LinkButton
              @to="/docs/theming/configuration/theme-switching"
              @appearance="outlined"
            >Theme switching</LinkButton>
          </div>
        </div>
      </section>

      {{! ------------------------------------------------------------------ }}
      {{! Prove the two claims that matter }}
      {{! ------------------------------------------------------------------ }}
      <section class="ambient ambient--proof py-24 sm:py-28 bg-surface-canvas">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="max-w-2xl mb-14 reveal">
            <p class="eyebrow mb-4">Built in</p>
            <h2
              class="font-header text-header-2xl sm:text-header-3xl text-neutral-bolder text-balance"
            >The work you don't have to do</h2>
            <p class="mt-4 font-body text-body-sm text-neutral-firm text-pretty">
              Keyboard behaviour, ARIA state, and template types arrive with the
              components. Both of these are running right now, so try them rather
              than take our word for it.
            </p>
          </div>

          <div class="space-y-14">
            <div class="reveal">
              <h3
                class="font-header text-header-lg text-neutral-bolder mb-2"
              >Keyboard and ARIA, already wired</h3>
              <p class="font-body text-body-sm text-neutral-firm mb-6 max-w-2xl">
                Tab into the list and use the arrow keys, Home, End, or type a
                letter.
              </p>
              <KeyboardProof />
            </div>

            <Divider />

            <div class="reveal">
              <h3
                class="font-header text-header-lg text-neutral-bolder mb-2"
              >Type errors, before runtime</h3>
              <p class="font-body text-body-sm text-neutral-firm mb-6 max-w-2xl">
                Glint checks component arguments inside the template, so a
                mismatched collection is a build error rather than a blank cell.
              </p>
              <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 items-start">
                <CodePanel
                  @code={{this.signatureSnippet}}
                  @language="typescript"
                  @label="columns.ts"
                />
                <CodePanel
                  @code={{this.templateSnippet}}
                  @language="handlebars"
                  @label="members.gts"
                />
              </div>
            </div>
          </div>
        </div>
      </section>

      {{! ------------------------------------------------------------------ }}
      {{! Full inventory — every door, counted honestly }}
      {{! ------------------------------------------------------------------ }}
      <section class="ambient ambient--inventory py-24 sm:py-28">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="max-w-2xl mb-14 reveal">
            <p class="eyebrow mb-4">Every component</p>
            <h2
              class="font-header text-header-2xl sm:text-header-3xl text-neutral-bolder text-balance"
            >Grouped by the job</h2>
            <p class="mt-4 font-body text-body-sm text-neutral-firm text-pretty">
              Everything Frontile documents today, with the deprecated legacy
              packages left out. Every name is a link.
            </p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-x-10 gap-y-10">
            {{#each this.inventory as |category|}}
              <div class="reveal">
                <h3
                  class="font-header text-header-md text-neutral-bolder mb-1"
                >{{category.name}}</h3>
                <p
                  class="font-caption text-caption-sm text-neutral-firm mb-4"
                >{{category.summary}}</p>
                <ul class="inventory-list">
                  {{#each category.items as |item|}}
                    <li>
                      <DocfyLink @to={{item.path}} class="inventory-list__link">
                        {{item.name}}
                      </DocfyLink>
                    </li>
                  {{/each}}
                </ul>
              </div>
            {{/each}}
          </div>
        </div>
      </section>

      {{! ------------------------------------------------------------------ }}
      {{! Close — every door, one more time }}
      {{! ------------------------------------------------------------------ }}
      <section class="ambient ambient--close py-24 sm:py-28">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="reveal">
            <p class="eyebrow mb-4">Start here</p>
            <h2
              class="font-header text-header-2xl sm:text-header-3xl text-neutral-bolder text-balance"
            >Pick a component and start reading.</h2>
            <p class="mt-4 font-body text-body-sm text-neutral-firm text-pretty">
              Every component's documentation is built around live, interactive
              demos of the component itself: the same ones running on this page,
              with the source beside each of them. Start wherever your interface
              is thinnest.
            </p>
          </div>

          <div class="mt-8 flex flex-wrap items-center gap-3 reveal">
            <LinkButton
              @route="docs.get-started"
              @intent="primary"
              @size="lg"
            >Read the docs</LinkButton>
            <LinkButton
              @href="https://github.com/josemarluedke/frontile"
              @appearance="outlined"
              @size="lg"
            >GitHub</LinkButton>
          </div>

          <div
            class="mt-10 rounded-xl border border-neutral-soft bg-surface-canvas p-6 reveal"
          >
            <h3
              class="font-header text-header-md text-neutral-bolder mb-2"
            >Readable by your agent, too</h3>
            <p class="font-body text-body-sm text-neutral-firm">
              Frontile publishes
              <code
                class="font-code text-code-sm text-primary-firm"
              >llms.txt</code>
              and
              <code
                class="font-code text-code-sm text-primary-firm"
              >llms-full.txt</code>
              to the llms.txt standard, mirrors every page as plain Markdown at
              the same URL plus
              <code
                class="font-code text-code-sm text-primary-firm"
              >.md</code>, and puts a one-click handoff to ChatGPT or Claude on
              each one. Point your coding agent at a component's real
              documentation instead of hoping it guessed the API.
            </p>
          </div>

          <div class="mt-10 reveal">
            <CodePanel
              @code="pnpm install frontile @frontile/theme"
              @isTerminal={{true}}
            />
            <p class="mt-3 font-body text-body-sm text-neutral-firm">
              Two packages, a Tailwind v4 stylesheet, and one
              <code class="font-code text-code-sm text-primary-firm">@source</code>
              line so Tailwind stops purging Frontile's classes. The
              <DocfyLink
                @to="/docs/get-started/installation"
                class="text-primary-firm underline"
              >installation guide</DocfyLink>
              has the exact paths.
            </p>
          </div>
        </div>
      </section>

      {{! A fixed, pointer-transparent grain layer. Last in the DOM and above
          the bands so it actually reads on them; Frontile's overlays portal out
          to the document body at a far higher stacking level, so modals and
          drawers are unaffected. }}
      <div class="grain" aria-hidden="true"></div>

    </div>
  </template>
}
