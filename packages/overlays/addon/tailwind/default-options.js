// const defaultTheme = require('tailwindcss/resolveConfig')(
// require('tailwindcss/defaultConfig')
// ).theme;

const defaultConfig = {
  // empty for now
};

function defaultOptions(/*{ config }*/) {
  return {
    default: {
      transitions: {
        fade: {
          enter: {
            opacity: 0
          },
          enterActive: {
            opacity: 1,
            transition: 'opacity 0.2s linear'
          },
          leave: {
            opacity: 1
          },
          leaveActive: {
            opacity: 0,
            transition: 'opacity 0.2s linear'
          }
        },
        zoom: {
          enter: {
            opacity: 0,
            transform: 'scale(0.8)'
          },
          enterActive: {
            opacity: 1,
            transform: 'scale(1)',
            transition: 'all 0.2s ease-in-out'
          },
          leave: {
            opacity: 1,
            transform: 'scale(1)'
          },
          leaveActive: {
            opacity: 0,
            transform: 'scale(0.8)',
            transition: 'all 0.2s ease-in-out'
          }
        }
      },

      overlay: {
        zIndex: 50,
        overflow: 'auto',
        '-webkit-overflow-scrolling': 'touch',

        jsIsOpen: {
          overflow: 'hidden'
        },

        backdrop: {
          position: 'fixed',
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          overflow: 'auto',
          backgroundColor: 'rgba(0, 0, 0, 0.45)',
          userSelect: 'none'
        },

        content: {
          position: 'relative'
        }
      }
    },
    'in-place': {
      overlay: {
        position: 'absolute',

        backdrop: {
          position: 'absolute'
        }
      }
    }
  };
}

module.exports = {
  defaultConfig,
  defaultOptions
};
