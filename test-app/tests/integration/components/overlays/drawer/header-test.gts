import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { DrawerHeader as Header } from 'frontile/overlays';

module(
  'Integration | Component | @frontile/overlays/Drawer::Header',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders, content, html attributes, and @labelledById', async function (assert) {
      await render(
        <template>
          <Header
            @labelledById="hello"
            data-test-id="header"
            class="other-class"
          >
            My Header
          </Header>
        </template>
      );

      assert.dom('[data-test-id="header"]').hasText('My Header');
      assert.dom('[data-test-id="header"]').hasAttribute('id', 'hello');
      assert.dom('[data-test-id="header"]').hasClass('other-class');
    });

    test('it renders @title and @description when given no block', async function (assert) {
      await render(
        <template>
          <Header
            @labelledById="hello"
            @title="Drawer title"
            @description="Supporting text"
            @titleClass="drawer__title"
            @descriptionClass="drawer__description"
            data-test-id="header"
          />
        </template>
      );

      assert
        .dom('[data-test-id="header"] .drawer__title')
        .hasText('Drawer title');
      assert
        .dom('[data-test-id="header"] .drawer__description')
        .hasText('Supporting text');
    });

    test('it yields Icon, Title and Description', async function (assert) {
      await render(
        <template>
          <Header
            @labelledById="hello"
            @iconClass="drawer__icon"
            @titleClass="drawer__title"
            @descriptionClass="drawer__description"
            data-test-id="header"
            as |h|
          >
            <h.Icon><span data-test-id="svg">icon</span></h.Icon>
            <h.Title>Block title</h.Title>
            <h.Description>Block description</h.Description>
          </Header>
        </template>
      );

      assert
        .dom('[data-test-id="header"] .drawer__icon [data-test-id="svg"]')
        .exists();
      assert
        .dom('[data-test-id="header"] .drawer__title')
        .hasText('Block title');
      assert
        .dom('[data-test-id="header"] .drawer__description')
        .hasText('Block description');
    });

    test('yielded Title and Description fall back to the args', async function (assert) {
      await render(
        <template>
          <Header
            @labelledById="hello"
            @title="Arg title"
            @description="Arg description"
            @titleClass="drawer__title"
            @descriptionClass="drawer__description"
            data-test-id="header"
            as |h|
          >
            <h.Title />
            <h.Description />
          </Header>
        </template>
      );

      assert.dom('[data-test-id="header"] .drawer__title').hasText('Arg title');
      assert
        .dom('[data-test-id="header"] .drawer__description')
        .hasText('Arg description');
    });

    test('a block suppresses the args form', async function (assert) {
      await render(
        <template>
          <Header
            @labelledById="hello"
            @title="Arg title"
            @titleClass="drawer__title"
            data-test-id="header"
          >
            Freeform only
          </Header>
        </template>
      );

      assert.dom('[data-test-id="header"]').hasText('Freeform only');
      assert.dom('[data-test-id="header"] .drawer__title').doesNotExist();
    });
  }
);
