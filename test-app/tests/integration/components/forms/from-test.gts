import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  click,
  fillIn,
  triggerEvent,
  triggerKeyEvent
} from '@ember/test-helpers';

import {
  Form,
  Input,
  Checkbox,
  RadioGroup,
  Textarea,
  NativeSelect,
  Select,
  type FormResultData
} from '@frontile/forms';
import { cell } from 'ember-resources';

module('Integration | Component | @frontile/forms/Form', function (hooks) {
  setupRenderingTest(hooks);

  const inputData = cell<FormResultData>();
  const submitData = cell<FormResultData>();
  const onChange = (
    data: FormResultData,
    eventType: 'input' | 'submit',
    _event: Event | SubmitEvent
  ) => {
    if (eventType === 'input') {
      inputData.current = data;
    } else {
      submitData.current = data;
    }
  };

  const countries = ['Argentina', 'Brazil', 'Chile', 'United States'];

  hooks.beforeEach(async function () {
    await render(
      <template>
        <Form data-test-form @onChange={{onChange}}>
          <Input @name="firstName" />
          <Checkbox @name="acceptTerms" />
          <RadioGroup @name="interests" as |Radio|>
            <Radio @label="Music" @value="music" />
            <Radio @label="IoT" @value="iot" />
          </RadioGroup>
          <Textarea @name="bio" />
          <NativeSelect @name="country" @items={{countries}} />

          <Select
            @name="traveledTo"
            @items={{countries}}
            @selectionMode="multiple"
          />
          <button type="submit">Submit</button>
        </Form>
      </template>
    );
  });

  test('it updates data as oninput event happens', async function (assert) {
    await fillIn('[name="firstName"]', 'John');
    assert.equal(inputData.current['firstName'], 'John');

    await fillIn('[name="bio"]', 'My bio');
    assert.equal(inputData.current['bio'], 'My bio');

    await click('[name="acceptTerms"]');
    assert.equal(inputData.current['acceptTerms'], true);

    await click('[value="music"]');
    assert.equal(inputData.current['interests'], 'music');

    await selectNativeOptionByKey('[name="country"]', 'Brazil');
    assert.equal(inputData.current['country'], 'Brazil');

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="Chile"]');
    await click('[data-component="listbox"] [data-key="Argentina"]');
    assert.deepEqual(inputData.current['traveledTo'], ['Argentina', 'Chile']);
  });

  test('it updates data on submit event', async function (assert) {
    await fillIn('[name="firstName"]', 'John');
    await click('[name="acceptTerms"]');
    await click('[value="music"]');
    await fillIn('[name="bio"]', 'My bio');
    await selectNativeOptionByKey('[name="country"]', 'Brazil');

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="Chile"]');
    await click('[data-component="listbox"] [data-key="Argentina"]');
    await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'Escape'); // Close the select

    assert.equal(submitData.current, undefined);
    await click('[data-test-form] button[type="submit"]');

    assert.deepEqual(submitData.current, {
      firstName: 'John',
      acceptTerms: true,
      interests: 'music',
      bio: 'My bio',
      country: 'Brazil',
      traveledTo: ['Argentina', 'Chile']
    });
  });
});

function selectNativeOptionByKey(
  selectSelector: string,
  key: string
): Promise<void> {
  return changeOption('selectNativeOptionByKey', selectSelector, key, false);
}

async function changeOption(
  functionName: string,
  selectSelector: string,
  key: string,
  toggle: boolean
): Promise<void> {
  const select = document.querySelector(selectSelector);
  if (!select) {
    throw new Error(
      `You called "${functionName}('${selectSelector}', '${key}')" but no select was found using selector "${selectSelector}"`
    );
  }
  const option = select.querySelector(`[data-key="${key}"]`) as
    | HTMLOptionElement
    | undefined;
  if (!option) {
    throw new Error(
      `You called "${functionName}('${selectSelector}', '${key}')" but no option with key "${key}" was found`
    );
  }
  if (option.selected && toggle) {
    option.selected = false;
  } else {
    option.selected = true;
  }
  await triggerEvent(select, 'change');

  let parent = select.parentElement;
  while (parent) {
    if (parent.tagName === 'FORM') {
      await triggerEvent(parent, 'input');
      break;
    }
    parent = parent.parentElement;
  }
}
