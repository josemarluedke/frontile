import Component from '@glimmer/component';
import validateFormat from 'ember-changeset-validations/validators/format';
import validatePresence from 'ember-changeset-validations/validators/presence';
import countries from './countries';

export const myValidations = {
  firstName: validatePresence(true),
  lastName: validatePresence(true),
  email: validateFormat({ type: 'email' }),
  countries: validatePresence(true)
};

interface ExampleArgs {}

export default class Example extends Component<ExampleArgs> {
  validations = myValidations;
  countries = countries.map(c => c.name);

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
}
