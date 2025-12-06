import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Dropdown } from 'frontile';

interface VersionDropdownSignature {
  Element: HTMLDivElement;
}

export default class VersionDropdown extends Component<VersionDropdownSignature> {
  baseVersions = [
    {
      key: 'v0.17',
      label: 'v0.17',
      url: '/',
      isLatest: true,
    },
    {
      key: 'v0.16',
      label: 'v0.16',
      url: 'https://v0.16.frontile.dev/',
      isLatest: false,
    },
  ];

  get versions() {
    const currentDomain = window.location.origin.replace(/^https?:\/\//, '');

    // Only add the Next version if we're on the next subdomain
    if (currentDomain.includes('next')) {
      return [
        ...this.baseVersions,
        {
          key: 'next',
          label: 'Next',
          url: 'https://next.frontile.dev/',
          isLatest: false,
        },
      ];
    }

    return this.baseVersions;
  }

  get latestVersion() {
    return this.versions.find((v) => v.isLatest);
  }

  get currentVersion() {
    const currentDomain = window.location.origin.replace(/^https?:\/\//, '');

    // Check if domain contains "next" and return the Next version
    if (currentDomain.includes('next')) {
      const nextVersion = this.versions.find((v) => v.key === 'next');
      if (nextVersion) {
        return nextVersion;
      }
    }

    // Try to find a version that matches the current domain
    const matchedVersion = this.versions.find((version) => {
      // For root URLs, skip this comparison
      if (version.url === '/') {
        return false;
      }
      const versionDomain = version.url
        .replace(/^https?:\/\//, '')
        .replace(/\/$/, '');
      return currentDomain === versionDomain;
    });

    // Return matched version or latest version as fallback
    return matchedVersion || this.latestVersion;
  }

  @action
  onVersionSelect(key: string) {
    const version = this.versions.find((v) => v.key === key);
    if (version) {
      window.location.href = version.url;
    }
  }

  get selectedKeys() {
    return this.currentVersion ? [this.currentVersion.key] : [];
  }

  getVersionLabel(version: { label: string; isLatest: boolean }) {
    return version.isLatest ? `${version.label} (latest)` : version.label;
  }

  <template>
    <div ...attributes>
      <Dropdown as |d|>
        <d.Trigger
          @appearance="minimal"
          @class="flex items-center gap-2 px-3 py-2 text-sm font-medium text-neutral-medium bg-neutral-subtle border border-neutral-subtle rounded-lg hover:bg-neutral-subtle focus:bg-neutral-subtle transition-all duration-200"
        >
          <span>{{this.getVersionLabel this.currentVersion}}</span>
          <svg
            class="w-4 h-4 text-neutral-soft"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M19 9l-7 7-7-7"
            />
          </svg>
        </d.Trigger>

        <d.Menu
          @onAction={{this.onVersionSelect}}
          @selectedKeys={{this.selectedKeys}}
          as |Item|
        >
          {{#each this.versions as |version|}}
            <Item @key={{version.key}}>
              {{this.getVersionLabel version}}
            </Item>
          {{/each}}
        </d.Menu>
      </Dropdown>
    </div>
  </template>
}
