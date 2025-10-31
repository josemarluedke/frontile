import Component from '@glimmer/component';
import validateFormat from 'ember-changeset-validations/validators/format';
import validatePresence from 'ember-changeset-validations/validators/presence';
import countries from './countries';
import ChangesetForm from '@frontile/changeset-form/components/changeset-form/index';
import { Button } from 'frontile';
// @ts-ignore
import changeset from 'ember-changeset/helpers/changeset';

export const myValidations = {
  firstName: validatePresence(true),
  lastName: validatePresence(true),
  email: validateFormat({ type: 'email' }),
  countries: validatePresence(true)
};

interface ExampleArgs {}

export default class Example extends Component<ExampleArgs> {
  validations = myValidations;
  countries = countries.map((c) => c.name);

  model = {
    firstName: null,
    lastName: null,
    email: 'frontile@example.com',
    comments: 'Changeset forms are great! 🚀',
    countries: [
      'Brazil',
      'India',
      'Israel',
      'Japan',
      'United Kingdom',
      'United States'
    ],

    hungry: true,
    humble: true,
    curious: true,
    favoriteMeal: 'lunch'
  };

  <template>
    {{! @glint-nocheck }}
    {{#let (changeset this.model this.validations) as |changeset|}}
      <ChangesetForm @changeset={{changeset}} as |Form|>
        <Form.Input
          @label="First Name"
          @fieldName="firstName"
          placeholder="What is your first name?"
        />
        <Form.Input
          @label="Last Name"
          @fieldName="lastName"
          @containerClass="mt-4"
          placeholder="What is your family name?"
        />
        <Form.Input
          @label="Email Address"
          @fieldName="email"
          type="email"
          @containerClass="mt-4"
        />
        <Form.Textarea
          @label="Comments"
          @fieldName="comments"
          @containerClass="mt-4"
        />
        <Form.Select
          @label="Countries"
          @fieldName="countries"
          @isMultiple={{true}}
          @options={{this.countries}}
          @allowClear={{true}}
          @containerClass="mt-4"
          as |option|
        >
          {{option}}
        </Form.Select>
        <Form.CheckboxGroup
          @label="Core Values"
          @isInline={{true}}
          @containerClass="mt-4"
          as |Checkbox|
        >
          <Checkbox @label="Hungry" @fieldName="hungry" />
          <Checkbox @label="Humble" @fieldName="humble" />
          <Checkbox @label="Curious" @fieldName="curious" />
        </Form.CheckboxGroup>
        <Form.RadioGroup
          @label="Favorite Meal"
          @containerClass="mt-4"
          @fieldName="favoriteMeal"
          as |Radio|
        >
          <Radio @label="Breakfast" @value="breakfast" />
          <Radio @label="Lunch" @value="lunch" />
          <Radio @label="Dinner" @value="dinner" />
        </Form.RadioGroup>
        <Button @type="submit" @class="my-4" disabled={{changeset.isInvalid}}>
          Submit
        </Button>
        <div class="mb-4">
          <p>
            isPristine:
            {{changeset.isPristine}}
          </p>
          <p>
            isValid:
            {{changeset.isValid}}
          </p>
          <p>
            isInvalid:
            {{changeset.isInvalid}}
          </p>
        </div>
      </ChangesetForm>
    {{/let}}
  </template>
}
