import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { AppLayout } from 'frontile';
import type { TOC } from '@ember/component/template-only';

// Placeholder icons: one outline path each, so the demo needs no icon package.
const HomeIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg
    viewBox="0 0 24 24"
    width="20"
    height="20"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    aria-hidden="true"
    ...attributes
  ><path d="M3 11l9-8 9 8v10H3z" /></svg>
</template>;

const ServicesIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg
    viewBox="0 0 24 24"
    width="20"
    height="20"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    aria-hidden="true"
    ...attributes
  ><path d="M4 14h16v6H4zM8 17h.01M6 10a8 8 0 0 1 12 0" /></svg>
</template>;

const BillingIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg
    viewBox="0 0 24 24"
    width="20"
    height="20"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    aria-hidden="true"
    ...attributes
  ><path d="M6 3h12v18l-3-2-3 2-3-2-3 2zM9 8h6M9 12h6" /></svg>
</template>;

const ShopIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg
    viewBox="0 0 24 24"
    width="20"
    height="20"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    aria-hidden="true"
    ...attributes
  ><path d="M4 9l1-5h14l1 5M5 9v11h14V9" /></svg>
</template>;

const ReferralIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg
    viewBox="0 0 24 24"
    width="20"
    height="20"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    aria-hidden="true"
    ...attributes
  ><path d="M12 20l-8-8a5 5 0 0 1 8-6 5 5 0 0 1 8 6z" /></svg>
</template>;

const SupportIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg
    viewBox="0 0 24 24"
    width="20"
    height="20"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    aria-hidden="true"
    ...attributes
  ><path d="M4 5h16v11H9l-5 4z" /></svg>
</template>;

const SearchIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg
    viewBox="0 0 24 24"
    width="20"
    height="20"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    aria-hidden="true"
    ...attributes
  ><path d="M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14zM21 21l-5-5" /></svg>
</template>;

/**
 * The platform-style shell: a stacked rail on desktop, a top bar and a tab bar
 * with a More sheet on a phone. The account tile, avatar and brandmark are
 * plain placeholder markup, not Frontile. Names and counts are made up.
 */
export default class PlatformShell extends Component {
  @tracked page = 'overview';

  get pageName(): string {
    const names: Record<string, string> = {
      overview: 'Overview',
      services: 'Services',
      billing: 'Billing',
      marketplace: 'Marketplace',
      referrals: 'Referral program',
      support: 'Support'
    };
    return names[this.page] ?? 'Overview';
  }

  go = (page: string): void => {
    this.page = page;
  };

  is = (page: string): boolean => this.page === page;

  <template>
    <AppLayout
      @variant="attached"
      @mobileNav="bottom"
      @scrollMode="page"
      as |layout|
    >
      <layout.Sidebar
        @size="rail"
        @collapsible="none"
        @label="Main navigation"
        class="theme-inverse"
        as |sidebar|
      >
        <sidebar.Header>
          <div data-test-brand class="flex flex-col items-center gap-2 py-2">
            <span
              aria-hidden="true"
              class="inline-block size-6 rounded-sm bg-primary"
            ></span>
            <button
              type="button"
              data-test-account-tile
              aria-label="Switch account · Sample Owner"
              class="text-xs"
            >Sample Owner</button>
          </div>
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item
            @layout="stacked"
            @icon={{HomeIcon}}
            @shortLabel="Overview"
            @badge={{2}}
            @badgeLabel="2 open orders"
            @isActive={{this.is "overview"}}
            {{on "click" (fn this.go "overview")}}
          >Overview</sidebar.Item>
          <sidebar.Item
            @layout="stacked"
            @icon={{ServicesIcon}}
            @shortLabel="Services"
            @isActive={{this.is "services"}}
            {{on "click" (fn this.go "services")}}
          >Services</sidebar.Item>
          <sidebar.Item
            @layout="stacked"
            @icon={{BillingIcon}}
            @shortLabel="Billing"
            @isActive={{this.is "billing"}}
            {{on "click" (fn this.go "billing")}}
          >Billing</sidebar.Item>
          <sidebar.Item
            @layout="stacked"
            @icon={{ShopIcon}}
            @shortLabel="Marketplace"
            @isActive={{this.is "marketplace"}}
            {{on "click" (fn this.go "marketplace")}}
          >Marketplace</sidebar.Item>
          <sidebar.Item
            @layout="stacked"
            @icon={{ReferralIcon}}
            @shortLabel="Referrals"
            @isActive={{this.is "referrals"}}
            {{on "click" (fn this.go "referrals")}}
          >Referral program</sidebar.Item>
          <sidebar.Item
            @layout="stacked"
            @icon={{SupportIcon}}
            @shortLabel="Support"
            @isActive={{this.is "support"}}
            {{on "click" (fn this.go "support")}}
          >Support</sidebar.Item>
        </sidebar.Body>
        <sidebar.Footer>
          <button
            type="button"
            data-test-avatar
            aria-label="Your account"
            class="mx-auto block size-8 rounded-full bg-primary"
          ></button>
        </sidebar.Footer>
      </layout.Sidebar>

      <layout.Navbar class="md:hidden">
        <span
          aria-hidden="true"
          class="inline-block size-6 rounded-sm bg-primary"
        ></span>
        <button
          type="button"
          data-test-account-line
          aria-label="Switch account · Sample Owner"
          class="flex min-w-0 flex-col text-start"
        >
          <span class="text-xs">{{this.pageName}}</span>
          <span class="truncate text-sm font-medium">Sample Owner</span>
        </button>
        <button type="button" aria-label="Search" class="ms-auto">
          <SearchIcon />
        </button>
        <button
          type="button"
          data-test-avatar-top
          aria-label="Your account"
          class="size-8 rounded-full bg-primary"
        ></button>
      </layout.Navbar>

      <layout.Main>
        <h1 data-test-page class="px-4 py-6 text-xl font-semibold">
          {{this.pageName}}
        </h1>
      </layout.Main>

      <layout.BottomNav as |nav|>
        <nav.Item
          @icon={{HomeIcon}}
          @badge={{2}}
          @badgeLabel="2 open orders"
          @isActive={{this.is "overview"}}
          {{on "click" (fn this.go "overview")}}
        >Overview</nav.Item>
        <nav.Item
          @icon={{ServicesIcon}}
          @isActive={{this.is "services"}}
          {{on "click" (fn this.go "services")}}
        >Services</nav.Item>
        <nav.Item
          @icon={{BillingIcon}}
          @isActive={{this.is "billing"}}
          {{on "click" (fn this.go "billing")}}
        >Billing</nav.Item>
        <nav.Item
          @icon={{ShopIcon}}
          @isActive={{this.is "marketplace"}}
          {{on "click" (fn this.go "marketplace")}}
        >Marketplace</nav.Item>
        <nav.Item
          @icon={{ReferralIcon}}
          @isActive={{this.is "referrals"}}
          {{on "click" (fn this.go "referrals")}}
        >Referral program</nav.Item>
        <nav.More as |more|>
          <more.Item
            @icon={{SupportIcon}}
            @isActive={{this.is "support"}}
            {{on "click" (fn this.go "support")}}
          >Support</more.Item>
        </nav.More>
      </layout.BottomNav>
    </AppLayout>
  </template>
}
