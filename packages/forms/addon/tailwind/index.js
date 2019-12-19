const map = require('lodash/map');
const fromPairs = require('lodash/fromPairs');
const isEmpty = require('lodash/isEmpty');
const svgToDataUri = require('mini-svg-data-uri');
const { merge, flattenOptions, replaceIconDeclarations } = require('./helpers');

function resolveOptions(userOptions, theme) {
  return merge(
    {
      default: require('./default-options')({ theme })
    },
    fromPairs(map(userOptions, (value, key) => [key, flattenOptions(value)]))
  );
}

module.exports = function({ addComponents, theme }) {
  function addRelatedComponents(key, options, modifier) {
    if (options.container !== undefined) {
      addComponents({
        [`.form-${key}-container${modifier}`]: options.container
      });
    }

    if (options.label !== undefined) {
      addComponents({
        [`.form-${key}-container${modifier} > .form-field-label${modifier}`]: options.label
      });
    }

    if (options.hint !== undefined) {
      let hint = options.hint;

      if (hint['&::before'] !== undefined) {
        hint = merge(options.hint, {
          '&::before': {
            fontSize: options.fontSize || '1rem'
          }
        });
      }

      addComponents({
        [`.form-${key}-container${modifier} > .form-field-hint${modifier}`]: hint
      });
    }

    if (options.feedback !== undefined) {
      addComponents({
        [`.form-${key}-container${modifier} > .form-field-feedback${modifier}`]: options.feedback
      });
    }
  }

  function addLabel(options, modifier = '') {
    if (isEmpty(options)) {
      return;
    }

    addComponents({ [`.form-field-label${modifier}`]: options });
  }

  function addHint(options, modifier = '') {
    if (isEmpty(options)) {
      return;
    }

    addComponents({ [`.form-field-hint${modifier}`]: options });
  }

  function addFeedback(options, modifier = '') {
    if (isEmpty(options)) {
      return;
    }

    addComponents({ [`.form-field-feedback${modifier}`]: options });
  }

  function addInput(options, modifier = '') {
    if (isEmpty(options)) {
      return;
    }

    addComponents({ [`.form-input${modifier}`]: options });
    addRelatedComponents('input', options, modifier);
  }

  function addTextarea(options, modifier = '') {
    if (isEmpty(options)) {
      return;
    }

    addComponents({ [`.form-textarea${modifier}`]: options });
    addRelatedComponents('textarea', options, modifier);
  }

  function addCheckbox(options, modifier = '') {
    if (isEmpty(options)) {
      return;
    }

    addComponents(
      replaceIconDeclarations(
        {
          [`.form-checkbox${modifier}`]: merge(
            options.borderWidth === undefined
              ? {}
              : {
                  '&::-ms-check': {
                    '@media not print': {
                      borderWidth: options.borderWidth
                    }
                  }
                },
            options
          )
        },
        ({ icon = options.icon, iconColor = options.iconColor }) => {
          return {
            '&:checked': {
              backgroundImage: `url("${svgToDataUri(
                typeof icon === 'function' ? icon(iconColor) : icon
              )}")`
            }
          };
        }
      )
    );

    addRelatedComponents('checkbox', options, modifier);
  }

  function addRadio(options, modifier = '') {
    if (isEmpty(options)) {
      return;
    }

    addComponents(
      replaceIconDeclarations(
        {
          [`.form-radio${modifier}`]: merge(
            options.borderWidth === undefined
              ? {}
              : {
                  '&::-ms-check': {
                    '@media not print': {
                      borderWidth: options.borderWidth
                    }
                  }
                },
            options
          )
        },
        ({ icon = options.icon, iconColor = options.iconColor }) => {
          return {
            '&:checked': {
              backgroundImage: `url("${svgToDataUri(
                typeof icon === 'function' ? icon(iconColor) : icon
              )}")`
            }
          };
        }
      )
    );

    addRelatedComponents('radio', options, modifier);
  }

  function addCheckboxGroup(options, modifier = '') {
    if (isEmpty(options)) {
      return;
    }

    addComponents({ [`.form-checkbox-group-container${modifier}`]: options });

    // Make sure to remove container as group styles are the container
    delete options.container;

    addRelatedComponents('checkbox-group', options, modifier);
  }

  function addRadioGroup(options, modifier = '') {
    if (isEmpty(options)) {
      return;
    }

    addComponents({ [`.form-radio-group-container${modifier}`]: options });

    // Make sure to remove container as group styles are the container
    delete options.container;

    addRelatedComponents('radio-group', options, modifier);
  }

  function registerComponents() {
    const options = resolveOptions(theme('@frontile/forms'), theme);

    Object.keys(options).forEach(key => {
      const modifier = key === 'default' ? undefined : `-${key}`;

      addLabel(options[key].label || {}, modifier);
      addInput(options[key].input || {}, modifier);
      addTextarea(options[key].textarea || {}, modifier);
      addCheckbox(options[key].checkbox || {}, modifier);
      addRadio(options[key].radio || {}, modifier);
      addHint(options[key].hint || {}, modifier);
      addFeedback(options[key].feedback || {}, modifier);
      addCheckboxGroup(options[key].checkboxGroup || {}, modifier);
      addRadioGroup(options[key].radioGroup || {}, modifier);
    });
  }

  registerComponents();
};
