import Route from '@ember/routing/route';
import { gray, blue, green, red, yellow } from '@frontile/theme/colors';
import { htmlSafe } from '@ember/template';

export default class IndexRoute extends Route {
  model() {
    return {
      htmlSafe,
      groups: [
        { name: 'Gray', colors: gray },
        { name: 'Blue', colors: blue },
        { name: 'Green', colors: green },
        { name: 'Red', colors: red },
        { name: 'Yellow', colors: yellow }
      ]
    };
  }
}
