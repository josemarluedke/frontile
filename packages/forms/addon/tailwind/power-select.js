const map = require('lodash/map');
const fromPairs = require('lodash/fromPairs');
const isEmpty = require('lodash/isEmpty');
const svgToDataUri = require('mini-svg-data-uri');
const { merge, flattenOptions, replaceIconDeclarations } = require('./helpers');

function resolveOptions(userOptions, theme) {
  return merge(
    require('./power-select-options')({ theme }),
    fromPairs(map(userOptions, (value, key) => [key, flattenOptions(value)]))
  );
}

module.exports = function({ addComponents, theme }) {
  function add(element, options) {
    if (isEmpty(options)) {
      return;
    }

    addComponents(
      replaceIconDeclarations(
        {
          [`.ember-power-select-${element}`]: options
        },
        ({ icon = options.icon, iconColor = options.iconColor }) => {
          return {
            backgroundImage: `url("${svgToDataUri(
              typeof icon === 'function' ? icon(iconColor) : icon
            )}")`
          };
        }
      )
    );

    if (options['&:focus']) {
      addComponents({
        [`.ember-power-select-${element}-active`]: options['&:focus']
      });
    }
  }

  const options = resolveOptions(theme('ember-power-select'), theme).default;

  add('trigger', options.trigger);
  add('placeholder', options.placeholder);
  add('status-icon', options.statusIcon);
  add('dropdown', options.dropdown);
  add('options', options.options);
  add('option', options.option);
  add('clear-btn', options.clearBtn);
  add('search', options.search);
  add('search-input', options.searchInput);
  add('group', options.group);
  add('group-name', options.groupName);
  add('trigger-multiple-input', options.triggerMultipleInput);
  add('multiple-options', options.multipleOptions);
  add('multiple-option', options.multipleOption);
  add('multiple-remove-btn', options.multipleRemoveBtn);
};
