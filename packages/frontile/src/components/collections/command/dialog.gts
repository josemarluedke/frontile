import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { modifier } from 'ember-modifier';
import { useStyles } from '@frontile/theme';
import { Overlay } from '../../overlays/overlay';
import { Command, type CommandSignature } from './command';
import type { OverlaySignature } from '../../overlays/overlay';

/**
 * Matches a keyboard event against a shortcut like `mod+k`, `ctrl+shift+p` or
 * a bare `/`.
 *
 * `mod` is Cmd on Apple platforms and Ctrl elsewhere, which is what users of
 * either expect from a palette.
 */
function matchesShortcut(event: KeyboardEvent, shortcut: string): boolean {
  const parts = shortcut.toLowerCase().split('+');
  const key = parts[parts.length - 1]!;

  if (event.key.toLowerCase() !== key) {
    return false;
  }

  const wants = (name: string) => parts.includes(name);
  const isApple = /Mac|iPhone|iPad|iPod/i.test(
    globalThis.navigator?.platform ?? ''
  );
  const mod = isApple ? event.metaKey : event.ctrlKey;

  if (wants('mod') !== mod) {
    return false;
  }

  if (!wants('mod')) {
    if (wants('ctrl') !== event.ctrlKey) return false;
    if (wants('cmd') !== event.metaKey) return false;
  }

  if (wants('shift') !== event.shiftKey) return false;
  if (wants('alt') !== event.altKey) return false;

  return true;
}

const EDITABLE = ['INPUT', 'TEXTAREA', 'SELECT'];

/**
 * True when the user is typing into a field, where an unmodified shortcut like
 * `/` is a character they meant to type rather than a command.
 */
function isTypingInField(target: EventTarget | null): boolean {
  const element = target as HTMLElement | null;

  if (!element) {
    return false;
  }

  return (
    EDITABLE.includes(element.tagName) || element.isContentEditable === true
  );
}

export interface CommandDialogSignature<T> {
  Args: CommandSignature<T>['Args'] & {
    isOpen: boolean;
    onClose?: () => void;

    /**
     * Opens the palette from anywhere in the document, e.g. `"mod+k"` or
     * `"/"`. Requires `@onOpen`. Pass an array to accept more than one.
     *
     * An unmodified shortcut is ignored while the user is typing in a field,
     * so `/` still types a slash in a text input.
     */
    shortcut?: string | string[];

    onOpen?: () => void;

    backdrop?: OverlaySignature['Args']['backdrop'];
    disableTransitions?: OverlaySignature['Args']['disableTransitions'];
    didClose?: OverlaySignature['Args']['didClose'];
  };
  Element: CommandSignature<T>['Element'];
  Blocks: CommandSignature<T>['Blocks'];
}

/**
 * A `Command` palette in a dialog, with an optional global shortcut.
 */
class CommandDialog<T = unknown> extends Component<CommandDialogSignature<T>> {
  setupShortcut = modifier(() => {
    const handler = (event: KeyboardEvent) => {
      const { shortcut } = this.args;

      if (!shortcut) {
        return;
      }

      const shortcuts = Array.isArray(shortcut) ? shortcut : [shortcut];
      const matched = shortcuts.find((candidate) =>
        matchesShortcut(event, candidate)
      );

      if (!matched) {
        return;
      }

      // A bare character shortcut must not steal keystrokes from a field.
      if (!matched.includes('+') && isTypingInField(event.target)) {
        return;
      }

      event.preventDefault();
      this.args.onOpen?.();
    };

    document.addEventListener('keydown', handler);

    return () => {
      document.removeEventListener('keydown', handler);
    };
  });

  get classNames() {
    const { commandDialog } = useStyles();
    const { base, panel } = commandDialog();

    return { base: base(), panel: panel() };
  }

  get transition() {
    return { name: 'overlay-transition--command' };
  }

  <template>
    {{! The shortcut listener lives on a zero-size element so it is installed
        whether or not the dialog is open. }}
    <span hidden {{this.setupShortcut}}></span>

    <Overlay
      @isOpen={{@isOpen}}
      @onClose={{@onClose}}
      @didClose={{@didClose}}
      @backdrop={{if @backdrop @backdrop "faded"}}
      @transition={{this.transition}}
      @disableTransitions={{@disableTransitions}}
      data-test-id="command-dialog"
    >
      <div class={{this.classNames.base}}>
        <div
          class={{this.classNames.panel}}
          data-test-id="command-dialog-panel"
        >
          <Command
            @items={{@items}}
            @groupBy={{@groupBy}}
            @groups={{@groups}}
            @filter={{@filter}}
            @searchFields={{@searchFields}}
            @disableFiltering={{@disableFiltering}}
            @query={{@query}}
            @onQueryChange={{@onQueryChange}}
            @onSearch={{@onSearch}}
            @searchDebounce={{@searchDebounce}}
            @isLoading={{@isLoading}}
            @onSelect={{@onSelect}}
            @disabledKeys={{@disabledKeys}}
            @label={{@label}}
            @placeholder={{@placeholder}}
            @size={{@size}}
            @class={{@class}}
            @classes={{@classes}}
            ...attributes
            as |c|
          >
            {{yield
              (hash
                query=c.query
                resultCount=c.resultCount
                isLoading=c.isLoading
                Input=c.Input
                List=c.List
                Footer=c.Footer
              )
            }}
          </Command>
        </div>
      </div>
    </Overlay>
  </template>
}

export { CommandDialog };
export default CommandDialog;
