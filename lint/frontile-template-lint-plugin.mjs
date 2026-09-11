import RequireDataPart from './rules/require-data-part.mjs';
import RequireRootDataComponent from './rules/require-root-data-component.mjs';

export default {
  name: 'frontile',
  rules: {
    'frontile/require-data-part': RequireDataPart,
    'frontile/require-root-data-component': RequireRootDataComponent
  }
};
