import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { LinkTo } from '@ember/routing';
import { DocfyLink } from '@docfy/ember';
import {
  Button,
  Input,
  Select,
  Field,
  Checkbox,
  Radio,
  Switch,
  ProgressBar,
  Spinner,
  Avatar,
  Chip,
  Divider,
  Modal,
  Drawer,
  Dropdown,
} from 'frontile';
import {
  CheckIcon,
  PaletteIcon,
  MoonIcon,
  BookIcon,
  TargetIcon,
  AccessibilityIcon,
  ComponentIcon,
  RocketIcon,
  SparklesIcon,
  UserIcon,
  SettingsIcon,
  LogoutIcon,
  ChevronDownIcon,
  ViewIcon,
  EditIcon,
  DuplicateIcon,
  ShareIcon,
  DownloadIcon,
  ArchiveIcon,
  DeleteIcon,
} from '../components/icons';
import FeatureCard from '../components/homepage/feature-card';
import ComponentPackageCard from '../components/homepage/component-package-card';
import SectionHeader from '../components/homepage/section-header';
import CodeBlock from '../components/homepage/code-block';
import ComponentDemoCard from '../components/homepage/component-demo-card';

class IndexPage extends Component {
  @tracked isModalOpen = false;
  @tracked isDrawerOpen = false;
  @tracked selectedCountry: string | null = null;
  @tracked email = '';
  @tracked fullName = '';

  countries = [
    { key: 'us', label: 'United States' },
    { key: 'ca', label: 'Canada' },
    { key: 'uk', label: 'United Kingdom' },
    { key: 'au', label: 'Australia' },
    { key: 'de', label: 'Germany' },
  ];

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
  handleCountryChange(key: string | null): void {
    this.selectedCountry = key;
  }

  @action
  handleEmailChange(value: string): void {
    this.email = value;
  }

  @action
  handleNameChange(value: string): void {
    this.fullName = value;
  }

  <template>
    <div class="min-h-screen bg-surface-app">
      {{! Hero Section }}
      <section
        class="relative overflow-hidden bg-surface-canvas pt-20 pb-24 sm:pt-24 sm:pb-32"
      >
        <div
          class="hero-glow-orb hero-glow-orb--brand hidden sm:block"
          aria-hidden="true"
        ></div>
        <div
          class="hero-glow-orb hero-glow-orb--accent hidden sm:block"
          aria-hidden="true"
        ></div>
        <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center">
            <h1
              class="text-5xl sm:text-6xl lg:text-7xl font-bold tracking-tight text-neutral-bolder mb-6"
            >
              Production-Ready UI Components
              <span
                class="block mt-2 bg-gradient-to-r from-brand-strong to-accent-strong bg-clip-text text-transparent"
              >for Ember.js</span>
            </h1>
            <p
              class="mt-6 text-xl sm:text-2xl text-neutral-bolder max-w-4xl mx-auto leading-relaxed"
            >
              Build accessible, beautiful applications with 30+ TypeScript-typed
              components, Tailwind Variants theming, and built-in dark mode
              support
            </p>
            <div class="mt-10 flex flex-col sm:flex-row gap-4 justify-center">
              <LinkTo @route="docs.get-started">
                <Button @intent="primary" @size="lg" @class="flex items-center">
                  Get Started
                  <svg
                    class="ml-2 w-5 h-5"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M13 7l5 5m0 0l-5 5m5-5H6"
                    />
                  </svg>
                </Button>
              </LinkTo>
            </div>
          </div>
        </div>
      </section>

      {{! Quick Install Section }}
      <section class="py-16 bg-surface-canvas section-divider-gradient">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center">
            <p
              class="text-sm font-semibold text-neutral-bolder uppercase tracking-wide mb-4"
            >Quick Install</p>
            <div class="install-terminal max-w-lg mx-auto">
              <div class="install-terminal__dots" aria-hidden="true">
                <span
                  class="install-terminal__dot install-terminal__dot--red"
                ></span>
                <span
                  class="install-terminal__dot install-terminal__dot--yellow"
                ></span>
                <span
                  class="install-terminal__dot install-terminal__dot--green"
                ></span>
              </div>
              <div class="install-terminal__command">
                <span class="install-terminal__prompt">$</span>
                pnpm install frontile @frontile/theme
              </div>
            </div>
            <p class="mt-4 text-sm text-neutral-bolder">
              Also available via npm and yarn
            </p>
          </div>
        </div>
      </section>

      {{! Key Features Grid }}
      <section class="py-24 bg-surface-app section-divider-gradient">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <SectionHeader
            @title="Built for Modern Ember Development"
            @subtitle="Everything you need to build production-ready applications"
          />

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <FeatureCard
              @title="Modern Ember"
              @description="Built with modern Ember standards. Full v2 addon format with template tags (GTS/GJS), Glimmer components, and type-safe templates powered by Glint."
              @iconBg="bg-brand-subtle"
            >
              <:icon>
                <SparklesIcon class="w-6 h-6 text-brand-strong" />
              </:icon>
            </FeatureCard>

            <FeatureCard
              @title="Accessibility First"
              @description="WAI-ARIA compliant components with full keyboard navigation, screen reader optimization, and built-in focus management."
              @iconBg="bg-success-subtle"
            >
              <:icon>
                <AccessibilityIcon class="w-6 h-6 text-success-strong" />
              </:icon>
            </FeatureCard>

            <FeatureCard
              @title="Tailwind Variants Theming"
              @description="Highly customizable styling system with class conflict resolution included. Replace default styles with your own styling without CSS-in-JS overhead."
              @iconBg="bg-accent-subtle"
            >
              <:icon>
                <PaletteIcon class="w-6 h-6 text-accent-strong" />
              </:icon>
            </FeatureCard>

            <FeatureCard
              @title="Dark Mode Ready"
              @description="Built-in theme switching with all components supporting dark mode. Semantic color tokens with zero configuration needed."
              @iconBg="bg-brand-subtle"
            >
              <:icon>
                <MoonIcon class="w-6 h-6 text-brand-strong" />
              </:icon>
            </FeatureCard>

            <FeatureCard
              @title="TypeScript + Glint"
              @description="Fully typed component signatures with type-safe templates. Generic type support for data structures with full IDE IntelliSense."
              @iconBg="bg-brand-subtle"
            >
              <:icon>
                <BookIcon class="w-6 h-6 text-brand-strong" />
              </:icon>
            </FeatureCard>

            <FeatureCard
              @title="Production Ready"
              @description="30+ battle-tested components including an advanced data table with sorting/selection, comprehensive form system, and overlay management."
              @iconBg="bg-success-subtle"
            >
              <:icon>
                <RocketIcon class="w-6 h-6 text-success-strong" />
              </:icon>
            </FeatureCard>
          </div>
        </div>
      </section>

      {{! Component Showcase with Live Demos }}
      <section class="py-24 bg-surface-canvas section-divider-gradient">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <SectionHeader
            @title="Components That Work Together"
            @subtitle="From simple buttons to advanced data tables, every component is designed for real-world applications"
          />

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-12">
            {{! Buttons Demo }}
            <ComponentDemoCard @title="Flexible Button System">
              <div class="space-y-4">
                <div class="flex flex-wrap gap-3">
                  <Button @intent="default">Default</Button>
                  <Button @intent="primary">Primary</Button>
                  <Button @intent="success">Success</Button>
                  <Button @intent="warning">Warning</Button>
                  <Button @intent="danger">Danger</Button>
                </div>
                <div class="flex flex-wrap gap-3">
                  <Button
                    @intent="primary"
                    @appearance="outlined"
                  >Outlined</Button>
                  <Button
                    @intent="primary"
                    @appearance="minimal"
                  >Minimal</Button>
                </div>
                <div class="">
                  <Button @intent="primary" @size="xs">Extra Small</Button>
                  <Button @intent="primary" @size="sm">Small</Button>
                  <Button @intent="primary" @size="md">Medium</Button>
                  <Button @intent="primary" @size="lg">Large</Button>
                </div>
              </div>
            </ComponentDemoCard>

            {{! Form Inputs Demo }}
            <ComponentDemoCard
              @title="Form Components"
              @description="Complete form components with labels, validation, and consistent styling"
            >
              <div class="space-y-4">
                <Field @name="email" as |field|>
                  <field.Input
                    @label="Email Address"
                    @type="email"
                    @placeholder="Enter your email"
                    @value={{this.email}}
                    @onInput={{this.handleEmailChange}}
                  />
                </Field>
                <Field @name="fullName" as |field|>
                  <field.Input
                    @label="Full Name"
                    @placeholder="John Doe"
                    @value={{this.fullName}}
                    @onInput={{this.handleNameChange}}
                  />
                </Field>
                <Field @name="country" as |field|>
                  <field.SingleSelect
                    @label="Country"
                    @placeholder="Select your country"
                    @items={{this.countries}}
                    @selectedKey={{this.selectedCountry}}
                    @onSelectionChange={{this.handleCountryChange}}
                  />
                </Field>
                <div class="flex items-center gap-6 pt-2">
                  <Checkbox>Remember me</Checkbox>
                  <Switch />
                </div>
              </div>
            </ComponentDemoCard>

            {{! Chips & Avatars }}
            <ComponentDemoCard @title="Chips & Avatars">
              <div class="space-y-4">
                <div class="flex flex-wrap gap-2">
                  <Chip>Default Chip</Chip>
                  <Chip @intent="primary">Primary</Chip>
                  <Chip @intent="success">Success</Chip>
                  <Chip @intent="warning">Warning</Chip>
                  <Chip @intent="danger">Danger</Chip>
                </div>
                <div class="flex flex-wrap gap-3 items-center">
                  <Avatar @size="xs" @name="John Doe" />
                  <Avatar @size="sm" @name="Jane Smith" />
                  <Avatar @size="md" @name="Bob Wilson" />
                  <Avatar @size="lg" @name="Alice Brown" />
                </div>
              </div>
            </ComponentDemoCard>

            {{! Progress & Loading States }}
            <ComponentDemoCard @title="Status Indicators">
              <div class="space-y-4">
                <div>
                  <p class="text-sm text-neutral-bolder mb-2">Progress Bar</p>
                  <ProgressBar
                    @intent="primary"
                    @progress={{75}}
                    @max={{100}}
                  />
                </div>
                <div>
                  <p class="text-sm text-neutral-bolder mb-2">Loading States</p>
                  <div class="flex gap-3 items-center">
                    <Spinner @size="sm" />
                    <Spinner @size="md" />
                    <Spinner @size="lg" />
                  </div>
                </div>
                <Divider />
                <p class="text-sm text-neutral-bolder">
                  Visual feedback for user actions and system processes
                </p>
              </div>
            </ComponentDemoCard>

            {{! Dropdown Menu Demo }}
            <ComponentDemoCard
              @title="Dropdown Menu"
              @description="Context menus with keyboard navigation and accessibility"
            >
              <div class="flex justify-center">
                <Dropdown as |d|>
                  <d.Trigger @intent="primary" @size="sm">
                    Dropdown
                  </d.Trigger>

                  <d.Menu as |Item|>
                    <Item
                      @key="view"
                      @description="Open in read-only mode"
                      @shortcut="⌘O"
                    >
                      <:start><ViewIcon /></:start>
                      <:default>View Details</:default>
                    </Item>
                    <Item
                      @key="edit"
                      @description="Make changes to project"
                      @shortcut="⌘E"
                    >
                      <:start><EditIcon /></:start>
                      <:default>Edit Project</:default>
                    </Item>
                    <Item
                      @key="duplicate"
                      @description="Create a copy"
                      @shortcut="⌘D"
                      @withDivider={{true}}
                    >
                      <:start><DuplicateIcon /></:start>
                      <:default>Duplicate</:default>
                    </Item>
                    <Item
                      @key="share"
                      @intent="primary"
                      @description="Invite team members"
                      @shortcut="⌘⇧S"
                    >
                      <:start><ShareIcon /></:start>
                      <:default>Share</:default>
                    </Item>
                    <Item
                      @key="export"
                      @intent="success"
                      @description="Download as file"
                    >
                      <:start><DownloadIcon /></:start>
                      <:default>Export</:default>
                    </Item>
                    <Item
                      @key="archive"
                      @intent="warning"
                      @description="Move to archived projects"
                      @withDivider={{true}}
                    >
                      <:start><ArchiveIcon /></:start>
                      <:default>Archive Project</:default>
                    </Item>
                    <Item
                      @key="delete"
                      @intent="danger"
                      @description="Permanently delete"
                      @class="text-danger"
                      @shortcut="⌘⌫"
                    >
                      <:start><DeleteIcon /></:start>
                      <:default>Delete Project</:default>
                    </Item>
                  </d.Menu>
                </Dropdown>
              </div>
            </ComponentDemoCard>

            {{! Modal Demo }}
            <ComponentDemoCard
              @title="Modal Dialog"
              @description="Accessible modal overlays with backdrop and focus trap"
            >
              <div class="flex justify-center">
                <Button @intent="primary" @onPress={{this.openModal}}>
                  Open Modal
                </Button>
              </div>
              <Modal
                @isOpen={{this.isModalOpen}}
                @onClose={{this.closeModal}}
                @size="md"
                as |modal|
              >
                <modal.Header>
                  Welcome to Frontile
                </modal.Header>
                <modal.Body>
                  <p class="text-neutral-bolder">
                    This is a fully accessible modal dialog with keyboard
                    navigation, focus trapping, and backdrop click-to-close
                    functionality.
                  </p>
                  <p class="text-neutral-bolder mt-4">
                    Try pressing
                    <kbd
                      class="px-2 py-1 bg-surface-overlay-subtle rounded text-sm font-mono"
                    >Escape</kbd>
                    to close!
                  </p>
                </modal.Body>
                <modal.Footer class="flex justify-end gap-3">
                  <Button @intent="default" @onPress={{this.closeModal}}>
                    Cancel
                  </Button>
                  <Button @intent="primary" @onPress={{this.closeModal}}>
                    Got it
                  </Button>
                </modal.Footer>
              </Modal>
            </ComponentDemoCard>

            {{! Drawer Demo }}
            <ComponentDemoCard
              @title="Drawer / Side Panel"
              @description="Slide-out panels for navigation or additional content"
            >
              <div class="flex justify-center">
                <Button @intent="primary" @onPress={{this.openDrawer}}>
                  Open Drawer
                </Button>
              </div>
              <Drawer
                @isOpen={{this.isDrawerOpen}}
                @onClose={{this.closeDrawer}}
                @placement="right"
                @size="md"
                as |drawer|
              >
                <drawer.Header>
                  Navigation Menu
                </drawer.Header>
                <drawer.Body>
                  <div class="space-y-4">
                    <div class="p-4 bg-surface-overlay-subtle rounded-lg">
                      <h4
                        class="font-semibold text-neutral-bolder mb-2"
                      >Components</h4>
                      <p class="text-sm text-neutral-bolder">Browse all 30+
                        components</p>
                    </div>
                    <div class="p-4 bg-surface-overlay-subtle rounded-lg">
                      <h4
                        class="font-semibold text-neutral-bolder mb-2"
                      >Documentation</h4>
                      <p class="text-sm text-neutral-bolder">Learn how to use
                        Frontile</p>
                    </div>
                    <div class="p-4 bg-surface-overlay-subtle rounded-lg">
                      <h4
                        class="font-semibold text-neutral-bolder mb-2"
                      >Examples</h4>
                      <p class="text-sm text-neutral-bolder">See components in
                        action</p>
                    </div>
                  </div>
                </drawer.Body>
                <drawer.Footer class="flex justify-end">
                  <Button @intent="default" @onPress={{this.closeDrawer}}>
                    Close
                  </Button>
                </drawer.Footer>
              </Drawer>
            </ComponentDemoCard>
          </div>

        </div>
      </section>

      {{! Component Inventory }}
      <section class="py-24 bg-surface-app section-divider-gradient">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <SectionHeader @title="30+ Components, Organized by Purpose" />

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <ComponentPackageCard
              @name="Buttons"
              @count={{5}}
              @description="Button, ButtonGroup, Chip, CloseButton, ToggleButton"
              @gradient="bg-brand-subtle"
              @borderColor="border-brand-soft"
              @countColor="text-brand-strong"
            >
              <:icon>
                <ComponentIcon class="w-5 h-5 text-brand-strong mr-2" />
              </:icon>
            </ComponentPackageCard>

            <ComponentPackageCard
              @name="Forms"
              @count={{10}}
              @description="Input, Select, Textarea, Checkbox, Radio, Switch, Field, Label & more"
              @gradient="bg-success-subtle"
              @borderColor="border-success-soft"
              @countColor="text-success-strong"
            >
              <:icon>
                <ComponentIcon class="w-5 h-5 text-success-strong mr-2" />
              </:icon>
            </ComponentPackageCard>

            <ComponentPackageCard
              @name="Collections"
              @count={{3}}
              @description="Table, Listbox, Dropdown"
              @gradient="bg-accent-subtle"
              @borderColor="border-accent-soft"
              @countColor="text-accent-strong"
            >
              <:icon>
                <ComponentIcon class="w-5 h-5 text-accent-strong mr-2" />
              </:icon>
            </ComponentPackageCard>

            <ComponentPackageCard
              @name="Overlays"
              @count={{5}}
              @description="Modal, Drawer, Popover, Overlay, Portal"
              @gradient="bg-warning-subtle"
              @borderColor="border-warning-soft"
              @countColor="text-warning-strong"
            >
              <:icon>
                <ComponentIcon class="w-5 h-5 text-warning-strong mr-2" />
              </:icon>
            </ComponentPackageCard>

            <ComponentPackageCard
              @name="Notifications"
              @count={{1}}
              @description="NotificationCard + Container"
              @gradient="bg-warning-subtle"
              @borderColor="border-warning-soft"
              @countColor="text-warning-strong"
            >
              <:icon>
                <ComponentIcon class="w-5 h-5 text-warning-strong mr-2" />
              </:icon>
            </ComponentPackageCard>

            <ComponentPackageCard
              @name="Status"
              @count={{1}}
              @description="ProgressBar"
              @gradient="bg-success-subtle"
              @borderColor="border-success-soft"
              @countColor="text-success-strong"
            >
              <:icon>
                <ComponentIcon class="w-5 h-5 text-success-strong mr-2" />
              </:icon>
            </ComponentPackageCard>

            <ComponentPackageCard
              @name="Utilities"
              @count={{5}}
              @description="Avatar, Collapsible, Divider, Spinner, VisuallyHidden"
              @gradient="bg-neutral-subtle"
              @borderColor="border-neutral-soft"
              @countColor="text-neutral-firm"
            >
              <:icon>
                <ComponentIcon class="w-5 h-5 text-neutral-firm mr-2" />
              </:icon>
            </ComponentPackageCard>

            <ComponentPackageCard
              @name="Theme"
              @count={{16}}
              @description="Styling system with Tailwind Variants"
              @gradient="bg-accent-subtle"
              @borderColor="border-accent-soft"
              @countColor="text-accent-strong"
            >
              <:icon>
                <PaletteIcon class="w-5 h-5 text-accent-strong mr-2" />
              </:icon>
            </ComponentPackageCard>
          </div>
        </div>
      </section>

      {{! Accessibility Section }}
      <section class="py-24 bg-success-subtle">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <SectionHeader
            @title="Accessible by Default"
            @subtitle="Not as an afterthought, but built into every component from the ground up"
            @iconBg="bg-success-subtle"
          >
            <:icon>
              <AccessibilityIcon class="w-8 h-8 text-success-strong" />
            </:icon>
          </SectionHeader>

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <div
              class="flex items-start p-6 bg-surface-overlay-subtle rounded-lg shadow-md border border-success-soft hover:border-success-medium transition-colors duration-200"
            >
              <CheckIcon
                class="w-6 h-6 text-success-strong mr-3 mt-1 flex-shrink-0"
              />
              <div>
                <h3 class="font-bold text-neutral-bolder mb-2">Keyboard
                  Navigation</h3>
                <p class="text-neutral-bolder text-sm">
                  Full keyboard support for all interactive components
                </p>
              </div>
            </div>

            <div
              class="flex items-start p-6 bg-surface-overlay-subtle rounded-lg shadow-md border border-success-soft hover:border-success-medium transition-colors duration-200"
            >
              <CheckIcon
                class="w-6 h-6 text-success-strong mr-3 mt-1 flex-shrink-0"
              />
              <div>
                <h3 class="font-bold text-neutral-bolder mb-2">Screen Reader
                  Support</h3>
                <p class="text-neutral-bolder text-sm">
                  Proper ARIA labels and live regions
                </p>
              </div>
            </div>

            <div
              class="flex items-start p-6 bg-surface-overlay-subtle rounded-lg shadow-md border border-success-soft hover:border-success-medium transition-colors duration-200"
            >
              <CheckIcon
                class="w-6 h-6 text-success-strong mr-3 mt-1 flex-shrink-0"
              />
              <div>
                <h3 class="font-bold text-neutral-bolder mb-2">Focus Management</h3>
                <p class="text-neutral-bolder text-sm">
                  Visible focus indicators and logical tab order
                </p>
              </div>
            </div>

            <div
              class="flex items-start p-6 bg-surface-overlay-subtle rounded-lg shadow-md border border-success-soft hover:border-success-medium transition-colors duration-200"
            >
              <CheckIcon
                class="w-6 h-6 text-success-strong mr-3 mt-1 flex-shrink-0"
              />
              <div>
                <h3 class="font-bold text-neutral-bolder mb-2">WAI-ARIA
                  Compliant</h3>
                <p class="text-neutral-bolder text-sm">
                  Follows authoring practices guidelines
                </p>
              </div>
            </div>

            <div
              class="flex items-start p-6 bg-surface-overlay-subtle rounded-lg shadow-md border border-success-soft hover:border-success-medium transition-colors duration-200"
            >
              <CheckIcon
                class="w-6 h-6 text-success-strong mr-3 mt-1 flex-shrink-0"
              />
              <div>
                <h3 class="font-bold text-neutral-bolder mb-2">High Contrast</h3>
                <p class="text-neutral-bolder text-sm">
                  Works with OS high contrast modes
                </p>
              </div>
            </div>

            <div
              class="flex items-start p-6 bg-surface-overlay-subtle rounded-lg shadow-md border border-success-soft hover:border-success-medium transition-colors duration-200"
            >
              <CheckIcon
                class="w-6 h-6 text-success-strong mr-3 mt-1 flex-shrink-0"
              />
              <div>
                <h3 class="font-bold text-neutral-bolder mb-2">Motion
                  Preferences</h3>
                <p class="text-neutral-bolder text-sm">
                  Respects prefers-reduced-motion
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {{! TypeScript Excellence }}
      <section class="py-24 bg-surface-canvas">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <SectionHeader
            @title="Type Safety from Components to Templates"
            @subtitle="Catch errors at compile-time, not runtime"
            @iconBg="bg-brand-subtle"
          >
            <:icon>
              <BookIcon class="w-8 h-8 text-brand-strong" />
            </:icon>
          </SectionHeader>

          <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div
              class="p-8 bg-surface-overlay-subtle rounded-xl border border-brand-soft"
            >
              <h3 class="text-lg font-bold text-neutral-bolder mb-4">Component
                Signatures</h3>
              <CodeBlock
                @code="interface Signature {
  Args: {
    rows: T[];
    columns: Column<T>[];
    onSort?: (col: Column<T>) => void;
  };
}"
              />
            </div>

            <div
              class="p-8 bg-surface-overlay-subtle rounded-xl border border-brand-soft"
            >
              <h3 class="text-lg font-bold text-neutral-bolder mb-4">Template
                Type Checking</h3>
              <CodeBlock
                @code="<Table
  @rows={{this.users}}
  @columns={{this.columns}}
/>
// ✅ Glint validates args
// ❌ Type errors at build"
              />
            </div>

            <div
              class="p-8 bg-surface-overlay-subtle rounded-xl border border-brand-soft"
            >
              <h3 class="text-lg font-bold text-neutral-bolder mb-4">Generic
                Support</h3>
              <CodeBlock
                @code="Table<User>
Listbox<Country>

// Full type inference
// for your data"
              />
            </div>
          </div>

          <div class="mt-12 grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
            <div>
              <div
                class="text-3xl font-bold text-brand-strong mb-2 stat-glow"
              >100%</div>
              <div class="text-sm text-neutral-bolder">TypeScript Coverage</div>
            </div>
            <div>
              <div
                class="text-3xl font-bold text-brand-strong mb-2 stat-glow"
              >Glint</div>
              <div class="text-sm text-neutral-bolder">Template Types</div>
            </div>
            <div>
              <div
                class="text-3xl font-bold text-brand-strong mb-2 stat-glow"
              >30+</div>
              <div class="text-sm text-neutral-bolder">Typed Components</div>
            </div>
            <div>
              <div
                class="text-3xl font-bold text-brand-strong mb-2 stat-glow"
              >Full</div>
              <div class="text-sm text-neutral-bolder">IDE IntelliSense</div>
            </div>
          </div>
        </div>
      </section>

      {{! Theming Section }}
      <section class="py-24 bg-accent-subtle">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <SectionHeader
            @title="Flexible Theming System"
            @subtitle="Semantic color tokens with built-in light and dark mode support"
            @iconBg="bg-accent-subtle"
          >
            <:icon>
              <PaletteIcon class="w-8 h-8 text-accent-strong" />
            </:icon>
          </SectionHeader>

          <div class="max-w-4xl mx-auto">
            <div
              class="p-8 bg-surface-overlay-subtle rounded-xl shadow-lg border border-accent-soft"
            >
              <h3 class="text-xl font-bold text-neutral-bolder mb-6">Semantic
                Theme System</h3>
              <CodeBlock
                @code="const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  defaultTheme: 'light',
  themes: {
    light: {
      colors: {
        brand: {
          subtle: '#eff6ff',
          soft: '#93c5fd',
          medium: '#3b82f6',
          strong: '#1e40af'
        },
        neutral: {
          subtle: '#f5f5f5',
          soft: '#a3a3a3',
          medium: '#525252',
          strong: '#171717'
        }
      }
    },
    dark: {
      colors: {
        brand: {
          subtle: '#1e3a8a',
          soft: '#3b82f6',
          medium: '#60a5fa',
          strong: '#dbeafe'
        }
      }
    }
  }
});

// Note: on-{color}-{level} classes are automatically generated"
                @language="javascript"
              />
              <p class="text-neutral-bolder mt-6 mb-6">
                Customize light and dark themes with semantic colors that adapt
                automatically. Use tokens like
                <code
                  class="px-1 py-0.5 bg-surface-overlay-soft rounded text-sm font-mono"
                >bg-brand-medium</code>,
                <code
                  class="px-1 py-0.5 bg-surface-overlay-soft rounded text-sm font-mono"
                >text-danger-strong</code>, and
                <code
                  class="px-1 py-0.5 bg-surface-overlay-soft rounded text-sm font-mono"
                >text-neutral-strong</code>
                for consistent theming across your application.
              </p>
              <div class="flex justify-center">
                <DocfyLink @to="/docs/theming/overview">
                  <Button
                    @intent="primary"
                    @size="md"
                    @class="flex items-center"
                  >
                    Learn More About Theming
                    <svg
                      class="ml-2 w-4 h-4"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M13 7l5 5m0 0l-5 5m5-5H6"
                      />
                    </svg>
                  </Button>
                </DocfyLink>
              </div>
            </div>
          </div>
        </div>
      </section>

      {{! Get Started / CTA Section }}
      <section class="py-24 cta-gradient-bg">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 class="text-4xl sm:text-5xl font-bold text-white mb-6">
            Ready to Build?
          </h2>
          <p class="text-xl text-white/80 mb-10 max-w-2xl mx-auto">
            Join the growing community of developers building accessible,
            beautiful Ember.js applications with Frontile
          </p>

          <div
            class="flex flex-col sm:flex-row gap-4 justify-center items-center mb-12"
          >
            <LinkTo @route="docs.get-started">
              <Button @intent="default" @size="lg" @class="flex items-center">
                Get Started
                <svg
                  class="ml-2 w-5 h-5"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M13 7l5 5m0 0l-5 5m5-5H6"
                  />
                </svg>
              </Button>
            </LinkTo>
            <a
              href="https://github.com/josemarluedke/frontile"
              target="_blank"
              rel="noopener noreferrer"
            >
              <Button @intent="primary" @size="lg" @class="flex items-center">
                <svg
                  class="mr-2 w-6 h-6"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    fill-rule="evenodd"
                    d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
                    clip-rule="evenodd"
                  />
                </svg>
                View on GitHub
              </Button>
            </a>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div class="cta-card">
              <h3 class="font-bold mb-2 text-white">Quick Start</h3>
              <p class="text-white/80 text-sm">
                Installation, setup, and your first component in minutes
              </p>
            </div>
            <div class="cta-card">
              <h3 class="font-bold mb-2 text-white">Browse Components</h3>
              <p class="text-white/80 text-sm">
                Interactive examples and API documentation
              </p>
            </div>
            <div class="cta-card">
              <h3 class="font-bold mb-2 text-white">Join Community</h3>
              <p class="text-white/80 text-sm">
                GitHub discussions and issue tracker
              </p>
            </div>
          </div>
        </div>
      </section>

    </div>
  </template>
}

export default IndexPage;
