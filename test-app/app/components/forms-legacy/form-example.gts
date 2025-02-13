import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';

import FormInput from '@frontile/forms-legacy/components/form-input';
import FormTextarea from '@frontile/forms-legacy/components/form-textarea';
import FormSelect from '@frontile/forms-legacy/components/form-select';
import FormCheckbox from '@frontile/forms-legacy/components/form-checkbox';
import FormCheckboxGroup from '@frontile/forms-legacy/components/form-checkbox-group';
import FormRadioGroup from '@frontile/forms-legacy/components/form-radio-group';

interface FormExampleArgs {}

export default class FormExample extends Component<FormExampleArgs> {
  @tracked size = '';
  @tracked isInline = false;

  @tracked firstName!: string;
  @tracked email!: string;
  @tracked accountType!: string;
  @tracked bio!: string;
  @tracked interests: string[] = [];

  @tracked country?: unknown;

  countries = [
    { name: 'United States', code: 'US' },
    { name: 'Spain', code: 'ES' },
    { name: 'Portugal', code: 'PT', disabled: true },
    { name: 'Russia', code: 'RU', disabled: true },
    { name: 'Latvia', code: 'LV' },
    { name: 'Brazil', code: 'BR' },
    { name: 'United Kingdom', code: 'GB' }
  ];

  get firstNameErrors(): string[] {
    if (this.firstName) {
      return [];
    } else {
      return ["First name can't be blank"];
    }
  }

  get emailErrors(): string[] {
    if (this.email && this.email.includes('@')) {
      return [];
    } else {
      return ['Email must be a valid email address'];
    }
  }

  get accountTypeErrors(): string[] {
    if (this.accountType === 'other') {
      return ['Other is not a real option, please select something else'];
    }
    return [];
  }

  get interestsErrors(): string[] {
    if (this.interests.length == 0) {
      return ['At least one option must be selected'];
    } else {
      return [];
    }
  }

  get countryErrors(): string[] {
    if (this.country) {
      return [];
    } else {
      return ["Country can't be blank"];
    }
  }

  get isIoTChecked(): boolean {
    return this.interests.includes('IoT');
  }

  get isMusicChecked(): boolean {
    return this.interests.includes('Music');
  }

  get isEntertainmentTChecked(): boolean {
    return this.interests.includes('Entertainment');
  }

  @action setCountry(value: unknown): void {
    this.country = value;
  }

  @action setField(
    fieldName: 'firstName' | 'email' | 'accountType' | 'isInline' | 'size',
    value: string | boolean
  ): void {
    this[fieldName] = value as never;
  }

  @action setInterest(interest: string, isChecked: boolean): void {
    if (isChecked) {
      this.interests = [...this.interests, interest];
    } else {
      this.interests = this.interests.filter((element) => {
        return element !== interest;
      });
    }
  }

  <template>
    {{! @glint-nocheck }}
    <div class="p-4 bg-content1 border border-default-300 rounded">
      <FormRadioGroup
        @label="Size"
        @value={{this.size}}
        @onChange={{fn this.setField "size"}}
        @isInline={{true}}
        as |Radio|
      >
        <Radio @value="sm" @label="sm" />
        <Radio @value="lg" @label="lg" />
        <Radio @value @label="default" />
      </FormRadioGroup>

      <FormCheckboxGroup @isInline={{true}} @label="Settings" as |Checkbox|>
        <Checkbox
          @label="isInline"
          @checked={{this.isInline}}
          @onChange={{fn this.setField "isInline"}}
        />
      </FormCheckboxGroup>
    </div>

    <FormInput
      @label="First Name"
      @hint="Your first name"
      @value={{this.firstName}}
      @onChange={{fn this.setField "firstName"}}
      @errors={{this.firstNameErrors}}
      placeholder="Joe"
      @containerClass="mt-4"
      @size={{this.size}}
    />

    <FormInput
      @label="Email"
      @value={{this.email}}
      @onChange={{fn this.setField "email"}}
      @errors={{this.emailErrors}}
      @containerClass="mt-4"
      @size={{this.size}}
    />

    <FormSelect
      @isMultiple={{false}}
      @size={{this.size}}
      @containerClass="mt-4"
      @hint="Select your country of residence"
      @errors={{this.countryErrors}}
      @allowClear={{true}}
      @label="Country"
      @searchEnabled={{true}}
      @searchField="name"
      @options={{this.countries}}
      @selected={{this.country}}
      @onChange={{this.setCountry}}
      as |country|
    >
      {{country.name}}
    </FormSelect>

    <FormRadioGroup
      @label="Account Type"
      @value={{this.accountType}}
      @onChange={{fn this.setField "accountType"}}
      @errors={{this.accountTypeErrors}}
      @containerClass="mt-4"
      @size={{this.size}}
      @isInline={{this.isInline}}
      as |Radio|
    >
      <Radio @value="personal" @label="Personal" />
      <Radio
        @value="business"
        @label="Business"
        @hint="If this account is for business"
      />
      <Radio @value="other" @label="Other" />
    </FormRadioGroup>

    <FormCheckboxGroup
      @label="Interests"
      @errors={{this.interestsErrors}}
      @containerClass="mt-4"
      @size={{this.size}}
      @isInline={{this.isInline}}
      as |Checkbox|
    >
      <Checkbox
        @label="IoT"
        @hint="Internet of things"
        @checked={{this.isIoTChecked}}
        @onChange={{fn this.setInterest "IoT"}}
      />
      <Checkbox
        @label="Music"
        @checked={{this.isMusicChecked}}
        @onChange={{fn this.setInterest "Music"}}
      />
      <Checkbox
        @label="Entertainment"
        @hint="Movies and TV series"
        @checked={{this.isEntertainmentTChecked}}
        @onChange={{fn this.setInterest "Entertainment"}}
      />
    </FormCheckboxGroup>

    <FormTextarea
      @label="Bio"
      @value={{this.bio}}
      @onChange={{fn this.setField "bio"}}
      @containerClass="mt-4"
      @size={{this.size}}
    />

    <FormCheckbox @containerClass="mt-4" @size={{this.size}}>
      I agree to the
      <a href="#" class="underline">
        privacy policy
      </a>
    </FormCheckbox>
  </template>
}
