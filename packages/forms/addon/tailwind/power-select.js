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
  function add(element, options, modifier) {
    if (isEmpty(options)) {
      return;
    }

    addComponents(
      replaceIconDeclarations(
        {
          [`.ember-power-select-${element}${modifier}`]: options
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

  const options = resolveOptions(theme('ember-power-select'), theme);
  Object.keys(options).forEach(key => {
    const modifier = key === 'default' ? '' : `-${key}`;

    add('trigger', options[key].trigger, modifier);
    add('placeholder', options[key].placeholder, modifier);
    add('status-icon', options[key].statusIcon, modifier);
    add('dropdown', options[key].dropdown, modifier);
    add('options', options[key].options, modifier);
    add('option', options[key].option, modifier);
    add('clear-btn', options[key].clearBtn, modifier);
    add('search', options[key].search, modifier);
    add('search-input', options[key].searchInput, modifier);
    add('group', options[key].group, modifier);
    add('group-name', options[key].groupName, modifier);
    add('trigger-multiple-input', options[key].triggerMultipleInput, modifier);
    add('multiple-options', options[key].multipleOptions, modifier);
    add('multiple-option', options[key].multipleOption, modifier);
    add('multiple-remove-btn', options[key].multipleRemoveBtn, modifier);
  });
};
