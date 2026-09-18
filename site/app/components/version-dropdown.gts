import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Dropdown, VisuallyHidden } from 'frontile';
import { currentDomain, stripScheme } from 'site/utils/origin';
import { ChevronDownIcon } from './icons';

interface Version {
  key: string;
  label: string;
  /** Shown only in the menu, next to the label. */
  note?: string;
  url: string;
  isLatest: boolean;
}

/**
 * Every line of the docs, always. The previous version of this list appended
 * `next` only when the reader was already on `next.frontile.dev`, which meant
 * the in-development docs were reachable from nowhere but themselves. A version
 * switcher that hides a version is a switcher with a hole in it.
 *
 * URLs are absolute so a jump works from any of the version subdomains;
 * `urlFor` collapses the current domain back to `/` so switching to the
 * version you are already on is an in-app no-op rather than a full page load.
 */
const VERSIONS: Version[] = [
  {
    key: 'next',
    label: 'Next',
    note: 'v0.19 dev',
    url: 'https://next.frontile.dev/',
    isLatest: false,
  },
  {
    key: 'v0.18',
    label: 'v0.18',
    note: 'latest',
    url: 'https://frontile.dev/',
    isLatest: true,
  },
  {
    key: 'v0.17',
    label: 'v0.17',
    url: 'https://v0.17.frontile.dev/',
    isLatest: false,
  },
  {
    key: 'v0.16',
    label: 'v0.16',
    url: 'https://v0.16.frontile.dev/',
    isLatest: false,
  },
];

interface VersionDropdownSignature {
  Element: HTMLDivElement;
}

export default class VersionDropdown extends Component<VersionDropdownSignature> {
  versions = VERSIONS;

  get latestVersion(): Version {
    return (
      this.versions.find((v) => v.isLatest) ?? (this.versions[0] as Version)
    );
  }

  get currentVersion(): Version {
    const domain = currentDomain();

    const matched = this.versions.find(
      (version) => domain === stripScheme(version.url)
    );

    return matched ?? this.latestVersion;
  }

  get selectedKeys(): string[] {
    return [this.currentVersion.key];
  }

  labelFor = (version: Version): string => {
    return version.note ? `${version.label} (${version.note})` : version.label;
  };

  @action
  onVersionSelect(key: string): void {
    const version = this.versions.find((v) => v.key === key);
    if (!version) {
      return;
    }

    // Already here — don't reload the page just to land where we are.
    if (stripScheme(version.url) === currentDomain()) {
      return;
    }

    window.location.href = version.url;
  }

  <template>
    <div ...attributes>
      <Dropdown as |d|>
        <d.Trigger
          @variant="plain"
          @class="flex items-center gap-1 px-2 py-1 text-xs font-medium transition rounded-md text-neutral-firm bg-neutral-subtle hover:bg-neutral-soft hover:text-neutral-strong outline-none focus-visible:ring"
        >
          <VisuallyHidden>Documentation version:</VisuallyHidden>
          <span>{{this.currentVersion.label}}</span>
          <ChevronDownIcon class="size-3" />
        </d.Trigger>

        <d.Menu
          @onAction={{this.onVersionSelect}}
          @selectedKeys={{this.selectedKeys}}
          as |Item|
        >
          {{#each this.versions as |version|}}
            <Item @key={{version.key}}>
              {{this.labelFor version}}
            </Item>
          {{/each}}
        </d.Menu>
      </Dropdown>
    </div>
  </template>
}
