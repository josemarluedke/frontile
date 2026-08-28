/* eslint-disable ember/no-runloop */
import { tracked } from '@glimmer/tracking';
import { cancel, debounce, later } from '@ember/runloop';
import { modifier } from 'ember-modifier';
import type { Timer } from '@ember/runloop';
import { getElementById } from '../-private/dom';

type SelectionMode = 'none' | 'single' | 'multiple';
type AutoActivateMode = 'none' | 'first' | 'selected';

interface ListItemArgs {
  key: string;
  textValue?: string;
  isSelected?: boolean;
  isDisabled?: boolean;
  isActive?: boolean;

  /**
   * The entry of the collection this item was rendered from, so consumers of a
   * selection can reach their own object rather than only its key and text.
   *
   * Undefined when there is no such object: an item written out in block form
   * is not backed by a collection entry, so nothing is invented for it.
   */
  item?: unknown;
}

/**
 * What `register` needs: every display flag resolved, and the source item
 * carried along if the caller has one.
 */
type ListItemRegistration = Required<Omit<ListItemArgs, 'item'>> &
  Pick<ListItemArgs, 'item'>;

class ListItem {
  el: HTMLLIElement | HTMLOptionElement;
  key: string;
  textValue: string;

  // Not tracked, and deliberately so. This is fixed at registration: the
  // element and its source entry arrive together, and a change to either
  // re-runs `setupItem`, which unregisters this item and registers a fresh
  // one. Making it tracked would add a settable tag to a class whose every
  // other field needs the mirror guards below to stay clear of Glimmer's
  // read-then-write assertion, for a value that is never written again.
  item?: unknown;

  // Ember's tracked setter dirties a tag unconditionally — it never compares
  // against the current value. That makes a redundant write more than wasted
  // work here: Glimmer reads an attribute and writes it to the DOM inside a
  // single autotracking frame, and writing `tabindex` onto the focused item
  // blurs it, so the browser dispatches `focusout` synchronously and this
  // item's own listeners run *inside* the frame that just consumed `isActive`.
  // Dirtying a tag that frame already consumed trips a backtracking-rerender
  // assertion, so every field below only writes on a real change.
  //
  // Each comparison reads a plain mirror rather than the tracked field itself.
  // Reading the tracked field would *consume* its tag, so the write that
  // followed would dirty a tag the current frame had just consumed — precisely
  // the failure these guards exist to prevent. For the same reason, code that
  // reads a field only to decide whether to write it should read the mirror;
  // `isActiveUntracked` exposes that for the one caller outside this class.
  @tracked private _isSelected: boolean;
  @tracked private _isDisabled: boolean;
  @tracked private _isActive: boolean;

  private isSelectedMirror: boolean;
  private isDisabledMirror: boolean;
  private isActiveMirror: boolean;

  get isSelected(): boolean {
    return this._isSelected;
  }

  set isSelected(value: boolean) {
    if (this.isSelectedMirror !== value) {
      this.isSelectedMirror = value;
      this._isSelected = value;
    }
  }

  get isDisabled(): boolean {
    return this._isDisabled;
  }

  set isDisabled(value: boolean) {
    if (this.isDisabledMirror !== value) {
      this.isDisabledMirror = value;
      this._isDisabled = value;
    }
  }

  get isActive(): boolean {
    return this._isActive;
  }

  set isActive(value: boolean) {
    if (this.isActiveMirror !== value) {
      this.isActiveMirror = value;
      this._isActive = value;
    }
  }

  /**
   * The three flags read without consuming their tags, for write decisions and
   * for `ListManager`'s tab-stop bookkeeping -- which has to look at every
   * sibling and must not drag every sibling's tag into the frame that does so.
   */
  get isActiveUntracked(): boolean {
    return this.isActiveMirror;
  }

  get isSelectedUntracked(): boolean {
    return this.isSelectedMirror;
  }

  get isDisabledUntracked(): boolean {
    return this.isDisabledMirror;
  }

  constructor(
    el: HTMLLIElement | HTMLOptionElement,
    args: ListItemRegistration
  ) {
    this.el = el;
    this.key = args.key;
    this.textValue = args.textValue;
    this.item = args.item;
    this._isSelected = this.isSelectedMirror = args.isSelected;
    this._isDisabled = this.isDisabledMirror = args.isDisabled;
    this._isActive = this.isActiveMirror = args.isActive;
  }
}

interface ListManagerArgs {
  selectionMode?: SelectionMode;
  selectedKeys?: string[];
  disabledKeys?: string[];
  allowEmpty?: boolean;
  autoActivateMode?: AutoActivateMode;
  onAction?: (key: string) => void;
  onSelectionChange?: (key: string[]) => void;
  onListItemsChange?: (items: ListItem[], action: 'add' | 'remove') => void;
  onActiveItemChange?: (key?: string, item?: ListItem) => void;
}

class ListManager {
  #items: ListItem[] = [];

  /**
   * The one pending "the list changed" task, and what the batch behind it did.
   *
   * Registration is per item, but everything that follows it -- ordering the
   * list against the document, telling the consumer what the list now holds,
   * and moving the active item -- belongs to the *batch*. Doing it per
   * registration made a 500-option Select order 500 nodes 500 times over and
   * queue 500 timers, each ordering them again, none of them cancelled. One
   * timer, replaced whenever another item registers or unregisters, does the
   * work once against the finished DOM.
   *
   * Deferring is not only cheaper, it is more accurate: mid-batch the document
   * still holds the elements Glimmer is about to tear down, so the orders
   * computed then were partly garbage (see `#orderedItems`).
   */
  #pendingTimer?: Timer;
  #pendingAdd = false;
  #pendingRemove = false;
  #pendingAction?: 'add' | 'remove';

  /**
   * Whether the `setup` modifier has been torn down without being re-installed.
   *
   * Destructors normally run children first, so every item has unregistered by
   * the time `setup` tears down and cancelling there is enough. This flag
   * covers the other order: once `setup` has gone, a late unregister records
   * what it did but queues nothing, so no flush can fire against a tree that
   * no longer exists. `setup` clears it, which is what makes a re-run -- where
   * the destructor runs purely as a prelude to the body -- harmless.
   */
  #isTornDown = false;

  /**
   * The item that owns the composite's tab stop, by key.
   *
   * The ARIA listbox pattern allows exactly one tabbable option: the options
   * are stepped *into* once and then navigated with the arrow keys. Every
   * selected option carrying `tabindex="0"` turned an eight-selection
   * multi-select into eight tab stops. The active item owns the stop, falling
   * back to the first selection, then to the first option a user can act on --
   * so a list nobody has touched yet is still reachable by Tab.
   *
   * Held as one tracked value rather than derived inside each option's getter:
   * a getter that had to look at every sibling would consume every sibling's
   * `isActive` tag, and the writes this class makes while Glimmer renders
   * would then dirty tags the same frame had just consumed. `#refreshTabStop`
   * reads the plain mirrors for the same reason, and this field is written
   * through a mirror guard of its own -- see `ListItem` above for the whole
   * story.
   */
  @tracked private _tabStopKey?: string;
  private tabStopKeyMirror?: string;

  searchKeys: string = '';
  args: ListManagerArgs = {
    selectionMode: 'none',
    selectedKeys: [],
    disabledKeys: [],
    allowEmpty: false,
    autoActivateMode: 'none'
  };

  constructor(args: ListManagerArgs = {}) {
    this.updateArgs(args);
  }

  /**
   * Registered items that are still in the document, in DOM order.
   *
   * The order cannot be maintained eagerly as items register: Glimmer moves
   * the element of an item that persists across an update instead of
   * re-creating it (no registration to react to), and it installs the
   * modifiers of newly rendered items before tearing down the ones they
   * replace — so a sort at registration time both misses later moves and
   * compares against detached elements, which `compareDocumentPosition`
   * orders arbitrarily. Deriving the order from the document when it is
   * needed keeps navigation in step with what the user sees.
   */
  get #orderedItems(): ListItem[] {
    return this.#items
      .filter((item) => item.el.isConnected)
      .sort((a, b) => {
        const position = a.el.compareDocumentPosition(b.el);
        if (position & Node.DOCUMENT_POSITION_FOLLOWING) return -1;
        if (position & Node.DOCUMENT_POSITION_PRECEDING) return 1;
        return 0;
      });
  }

  /** Whether any registered item is still in the document. */
  get #hasVisibleItems(): boolean {
    return this.#items.some((item) => item.el.isConnected);
  }

  /** Whether `key` is the single option that carries `tabindex="0"`. */
  isTabStop(key: string): boolean {
    return this._tabStopKey === key;
  }

  private set tabStopKey(value: string | undefined) {
    if (this.tabStopKeyMirror !== value) {
      this.tabStopKeyMirror = value;
      this._tabStopKey = value;
    }
  }

  /**
   * Work out which option owns the tab stop, reading only the untracked
   * mirrors so nothing is consumed on a path that can run mid-render.
   *
   * Only called from places where the answer can actually have changed and
   * where the DOM is worth ordering once: an activation, a selection update,
   * and the batch flush. Notably *not* from `unregister` -- see there.
   */
  #refreshTabStop(): void {
    let active: ListItem | undefined;
    let selected: ListItem | undefined;
    let first: ListItem | undefined;

    for (const item of this.#orderedItems) {
      if (item.isDisabledUntracked) continue;
      if (!first) first = item;
      if (!selected && item.isSelectedUntracked) selected = item;
      if (!active && item.isActiveUntracked) active = item;
      if (active) break;
    }

    this.tabStopKey = (active || selected || first)?.key;
  }

  register(
    el: HTMLLIElement | HTMLOptionElement,
    args: ListItemRegistration
  ): void {
    const newItem = new ListItem(el, args);
    if (
      this.args.autoActivateMode == 'first' &&
      !this.#hasVisibleItems &&
      !args.isDisabled
    ) {
      newItem.isActive = true;
      this.args.onActiveItemChange?.(newItem.key, newItem);
    }
    this.#items.push(newItem);

    // A first, cheap guess at the tab stop, so a freshly rendered list has a
    // tabbable option before the batch flush gets to work out the real answer.
    // Deliberately no `#refreshTabStop()` here: that orders the document, and
    // ordering it once per registration is the cost this batching removes.
    if (typeof this.tabStopKeyMirror === 'undefined' && !args.isDisabled) {
      this.tabStopKey = newItem.key;
    }

    this.#scheduleListChange('add');
  }

  unregister(el: HTMLLIElement | HTMLOptionElement): void {
    this.#items = this.#items.filter((item) => item.el !== el);

    // The tab stop is left pointing at the item that just went, and the flush
    // below corrects it a tick later. Clearing it here would write tracked
    // state while Glimmer tears down the elements it is replacing -- the same
    // render pass in which the surviving options have already read it for
    // their `tabindex` -- which is exactly the backtracking-rerender hazard
    // `ListItem` documents. For the tick in between, no option is tabbable;
    // the alternative is an assertion.

    this.#scheduleListChange('remove');
  }

  /**
   * Note what the batch did and make sure exactly one flush is queued for it.
   *
   * Always queued, even with no `onListItemsChange` and no auto-activation:
   * the tab stop has to be re-derived after any change to the membership, and
   * the flush is the only place the document is ordered once per batch rather
   * than once per item.
   */
  #scheduleListChange(action: 'add' | 'remove'): void {
    if (action === 'add') {
      this.#pendingAdd = true;
    } else {
      this.#pendingRemove = true;
    }
    this.#pendingAction = action;

    if (this.#isTornDown) {
      return;
    }

    cancel(this.#pendingTimer);
    this.#pendingTimer = later(this, this.#flushListChange, 1);
  }

  #flushListChange(): void {
    this.#pendingTimer = undefined;

    const added = this.#pendingAdd;
    const removed = this.#pendingRemove;
    const action = this.#pendingAction;
    this.#pendingAdd = false;
    this.#pendingRemove = false;
    this.#pendingAction = undefined;

    if (action && typeof this.args.onListItemsChange === 'function') {
      this.args.onListItemsChange(this.#orderedItems, action);
    }

    if (this.args.autoActivateMode === 'none' || !this.#hasVisibleItems) {
      this.#refreshTabStop();
      return;
    }

    if (added) {
      if (this.args.autoActivateMode === 'first') {
        this.setFirstOptionActive();
      } else {
        this.setSelectedOptionActive();
      }
    } else if (removed && this.args.autoActivateMode === 'first') {
      // The active item may have been the one that went.
      this.setFirstOptionActive();
    }

    this.#refreshTabStop();
  }

  /**
   * Drop whatever the current batch had queued.
   *
   * `ListManager` is a plain class, so the only teardown it can hook is the
   * destructor of the `setup` modifier that installed it -- which is where
   * this is called from. That destructor also runs when `setup`'s arguments
   * change, so `setup` re-queues a flush that was still pending; only a real
   * teardown never reaches the body again, and there the timer stays cancelled.
   */
  teardown(): void {
    cancel(this.#pendingTimer);
    this.#pendingTimer = undefined;
    this.#isTornDown = true;
  }

  /** Re-queue a batch that `teardown` cancelled but that has not run yet. */
  #resumePendingListChange(): void {
    this.#isTornDown = false;

    if (this.#pendingAction && !this.#pendingTimer) {
      this.#pendingTimer = later(this, this.#flushListChange, 1);
    }
  }

  at(el?: HTMLLIElement | HTMLOptionElement): ListItem | undefined {
    return this.#items.find((item) => item.el === el);
  }

  atKey(key: string): ListItem | undefined {
    return this.#items.find((item) => item.key === key);
  }

  updateArgs(args: ListManagerArgs): void {
    this.args.selectedKeys = args.selectedKeys || [];
    this.args.disabledKeys = args.disabledKeys || [];
    this.args.allowEmpty = args.allowEmpty || false;
    this.args.autoActivateMode = args.autoActivateMode || 'none';

    for (let i = 0; i < this.#items.length; i++) {
      const item = this.#items[i] as ListItem;
      item.isSelected = this.isKeySelected(item.key);
      item.isDisabled = this.isKeyDisabled(item.key);
    }

    if (args.selectionMode) {
      this.args.selectionMode = args.selectionMode;
    }

    // Callbacks are replaced whenever the caller *mentions* them, rather than
    // whenever it passes a truthy one.
    //
    // A manager is built once, in a component's field initializer, and only
    // `setup` runs again when arguments change -- so a callback that `setup`
    // does not carry can never be refreshed, and a `Listbox` whose `@onAction`
    // is rebuilt each render (`{{fn this.pick group.id}}` inside an
    // `{{#each}}`) went on calling the closure from its first render forever.
    //
    // The key has to decide it, not the value: `setup` names every callback it
    // owns, passing undefined when the consumer gave none, and that undefined
    // must win. A caller that owns only some of them -- NativeSelect hands its
    // own `onSelectionChange` to the constructor and only `onListItemsChange`
    // to `setup` -- leaves the rest unmentioned, and those keep what they have.
    if ('onAction' in args) {
      this.args.onAction = args.onAction;
    }

    if ('onSelectionChange' in args) {
      this.args.onSelectionChange = args.onSelectionChange;
    }

    if ('onListItemsChange' in args) {
      this.args.onListItemsChange = args.onListItemsChange;
    }

    if ('onActiveItemChange' in args) {
      this.args.onActiveItemChange = args.onActiveItemChange;
    }

    // The selection this just wrote onto the items may have moved the tab stop.
    this.#refreshTabStop();
  }

  selectActiveItem(): void {
    const item = this.#activeItem;
    if (item) {
      item.el.click();
    }
  }

  selectItem(item?: ListItem): void {
    if (item) {
      if (this.args.selectionMode !== 'none') {
        this.activateItem(item);
      }
      if (typeof this.args.onAction === 'function') {
        this.args.onAction(item.key);
      }

      if (
        typeof this.args.onSelectionChange === 'function' &&
        this.args.selectionMode !== 'none'
      ) {
        this.args.onSelectionChange(this.#toggleSelectedItem(item));
      }
    }
  }

  activateItem(item?: ListItem): void {
    // `isActiveUntracked`, not `isActive`: this read only decides whether to
    // write, and consuming the tag here would put the write below in the same
    // frame as a read of it — the hazard `ListItem` documents.
    if (item && !item.isActiveUntracked) {
      this.#clearActive();
      item.isActive = true;
      this.#refreshTabStop();
      this.args.onActiveItemChange?.(item.key, item);

      // Ensure the item is scrolled into view
      requestAnimationFrame(() => {
        // The list may have been torn down between the write above and the
        // frame; scrolling a detached element to nowhere is pointless.
        if (item.el.isConnected) {
          item.el.scrollIntoView({ block: 'nearest', inline: 'nearest' });
        }
      });
    }
  }

  setNextOptionActive(): void {
    const items = this.#orderedItems;
    for (let i = this.#indexOfActiveItem(items) + 1; i < items.length; i++) {
      const item = items[i];
      if (item && !item.isDisabled && !item.isActive) {
        this.activateItem(item);
        break;
      }
    }
  }

  setPreviousOptionActive(): void {
    const items = this.#orderedItems;
    for (let i = this.#indexOfActiveItem(items) - 1; i >= 0; i--) {
      const item = items[i];
      if (item && !item.isDisabled && !item.isActive) {
        this.activateItem(item);
        break;
      }
    }
  }

  setFirstOptionActive(): void {
    const items = this.#orderedItems;
    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      if (item && !item.isDisabled) {
        this.activateItem(item);
        break;
      }
    }
  }

  setSelectedOptionActive(): void {
    const items = this.#orderedItems;
    let activated = false;

    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      if (item && !item.isDisabled && item.isSelected) {
        this.activateItem(item);
        activated = true;
        break;
      }
    }

    if (!activated) {
      this.setFirstOptionActive();
    }
  }

  setLastOptionActive(): void {
    const items = this.#orderedItems;
    for (let i = items.length - 1; i >= 0; i--) {
      const item = items[i];
      if (item && !item.isDisabled) {
        this.activateItem(item);
        break;
      }
    }
  }

  search(key: string): void {
    debounce(this, this.#clearSearch, 500);
    this.searchKeys += key.toLowerCase();

    const items = this.#orderedItems;
    for (let i = 0; i < items.length; i++) {
      const item = items[i] as ListItem;

      if (
        !item.isDisabled &&
        this.searchKeys &&
        item.textValue.trim().toLowerCase().startsWith(this.searchKeys)
      ) {
        this.activateItem(item);
        break;
      }
    }
  }

  isKeyDisabled(key: string): boolean {
    return this.args.disabledKeys?.includes(key) || false;
  }

  isKeySelected(key: string): boolean {
    return this.args.selectedKeys?.includes(key) || false;
  }

  #indexOfActiveItem(items: ListItem[]): number {
    let item = items.find((i) => i.isActive);

    if (!item) {
      item = items.find((i) => i.isSelected);
    }
    if (!item) {
      return -1;
    }
    return items.indexOf(item);
  }

  /**
   * The selection `#toggleSelectedItem` starts from: the keys that are
   * selected right now, ordered the way it rebuilds them.
   */
  #selectionSnapshot(): string[] {
    const selectedKeys: string[] = [];

    const items = this.#orderedItems;

    // A selection is not the rendered list's to discard. Rebuilding purely
    // from `#orderedItems` drops every selected key whose item is not on
    // screen right now -- filtered out, most obviously -- so toggling one
    // option in a filtered multi-select used to wipe the rest of the
    // selection. Carry those keys over from the authoritative list instead.
    //
    // They go first so the rebuilt array keeps the shape it always had: when
    // nothing is hidden this set is empty and the result is exactly the DOM
    // -ordered scan below, unchanged.
    //
    // `multiple` only. Single mode replaces the selection outright, so it
    // never lost anything here, and carrying a key over would change what
    // counts as "the last selection" for the `allowEmpty` rule
    // (`canDeselectKey`).
    if (this.args.selectionMode === 'multiple') {
      const renderedKeys = new Set(items.map((_item) => _item.key));
      for (const key of this.args.selectedKeys || []) {
        if (!renderedKeys.has(key)) {
          selectedKeys.push(key);
        }
      }
    }

    for (let i = 0; i < items.length; i++) {
      const _item = items[i] as ListItem;
      if (_item.isSelected) {
        selectedKeys.push(_item.key);
      }
    }

    return selectedKeys;
  }

  #toggleSelectedItem(item: ListItem): string[] {
    let selectedKeys = this.#selectionSnapshot();

    if (canDeselectKey(selectedKeys, item.key, this.args.allowEmpty)) {
      const indexToRemove = selectedKeys.indexOf(item.key);
      selectedKeys.splice(indexToRemove, 1);
    } else {
      if (this.args.selectionMode === 'single') {
        selectedKeys = [item.key];
      } else if (!selectedKeys.includes(item.key)) {
        selectedKeys.push(item.key);
      }
    }

    return selectedKeys;
  }

  get #activeItem(): ListItem | undefined {
    return this.#orderedItems.find((item) => item.isActive);
  }

  #clearSearch(): void {
    this.searchKeys = '';
  }

  #clearActive(): void {
    for (let i = 0; i < this.#items.length; i++) {
      // No `isActive` check: the setter already skips unchanged values, and
      // reading it here would consume every item's tag on a path that can run
      // mid-render.
      (this.#items[i] as ListItem).isActive = false;
    }
  }

  setup = modifier(
    (
      _el: HTMLUListElement | HTMLSelectElement,
      _: unknown[],
      args: ListManagerArgs
    ) => {
      this.updateArgs(args);

      // This modifier's destructor also runs before every re-invocation, so a
      // flush it cancelled while the list was still very much alive has to be
      // put back. Only a real teardown never reaches this line again.
      this.#resumePendingListChange();

      return (): void => {
        this.teardown();
      };
    }
  );

  setupItem = modifier(
    (
      el: HTMLLIElement | HTMLOptionElement,
      _: unknown[],
      args: Pick<ListItemArgs, 'key' | 'textValue' | 'item'> & {
        onRegister?: (item: ListItem) => void;
        disableEvents?: boolean;
      }
    ) => {
      let textValue = args.textValue;
      if (
        typeof textValue === 'undefined' ||
        textValue === '' ||
        textValue === null
      ) {
        // `aria-labelledby` is not a selector: it holds a *space-separated
        // list* of ids, and those ids are resolved against the whole
        // document, not against this element's subtree. Treating the raw
        // value as `#id` therefore turned a multi-id label into a descendant
        // selector that matches nothing, missed labels living outside the
        // item — leaving `textValue` empty and type-ahead search broken — and
        // threw outright on any id that is not a valid CSS identifier.
        const labelledBy = el.getAttribute('aria-labelledby');
        const labelId = labelledBy?.trim().split(/\s+/)[0];

        if (labelId) {
          const labelElement = getElementById(el.ownerDocument, labelId);
          if (labelElement) {
            textValue = labelElement.textContent?.trim() || '';
          }
        }

        // Still nothing — either there was no label, or the id it named is
        // not in the document — so fall back to the item's own text.
        if (!textValue) {
          textValue = el.textContent?.trim() || '';
        }
      }

      this.register(el as HTMLLIElement, {
        key: args.key,
        textValue: textValue || '',
        item: args.item,
        isActive: false,
        isDisabled: this.isKeyDisabled(args.key),
        isSelected: this.isKeySelected(args.key)
      });
      const item = this.at(el);
      if (item && typeof args.onRegister === 'function') {
        args.onRegister(item);
      }

      const mouseEnter = (): void => {
        this.activateItem(item);
      };

      const mouseLeave = (): void => {
        if (item) {
          item.isActive = false;
        }
      };

      // Glimmer mutates this item's DOM during a render — rewriting `tabindex`
      // on the focused item, or clearing the block that contains it — and the
      // browser reacts by blurring the element and dispatching `focusout`
      // synchronously, inside the frame that just consumed `isActive` (see
      // `ListItem` above). Those blurs carry no `relatedTarget`.
      //
      // Neither do some genuine ones: clicking a non-focusable region,
      // switching tab or window, or moving focus to browser chrome. Ignoring
      // every targetless blur therefore trades a possibly-stale highlight for
      // never writing tracked state mid-render. That is a good trade here —
      // for a roving-tabindex widget, keeping the active item across a blur is
      // closer to the ARIA pattern than clearing it.
      const focusOut = (event: Event): void => {
        if ((event as FocusEvent).relatedTarget === null) {
          return;
        }
        mouseLeave();
      };

      if (!args.disableEvents) {
        el.addEventListener('mouseenter', mouseEnter);
        el.addEventListener('mouseleave', mouseLeave);

        el.addEventListener('focusin', mouseEnter);
        el.addEventListener('focusout', focusOut);
      }

      return (): void => {
        this.unregister(el);

        if (!args.disableEvents) {
          el.removeEventListener('mouseenter', mouseEnter);
          el.removeEventListener('mouseleave', mouseLeave);

          el.removeEventListener('focusin', mouseEnter);
          el.removeEventListener('focusout', focusOut);
        }
      };
    }
  );
}

/**
 * The `allowEmpty` deselect rule, in one place.
 *
 * Given the keys that make up a selection, whether `key` may be taken out of
 * it: a key that is not in the selection has nothing to remove, and the last
 * remaining key only goes when emptying the selection is allowed.
 *
 * `selectionMode` deliberately plays no part. It decides how a selection is
 * built, not whether it may shrink -- see `#selectionSnapshot`.
 */
function canDeselectKey(
  selectedKeys: string[],
  key: string,
  allowEmpty: boolean = false
): boolean {
  if (!selectedKeys.includes(key)) {
    return false;
  }
  return (allowEmpty && selectedKeys.length == 1) || selectedKeys.length > 1;
}

function keyAndLabelForItem(item: unknown): { key: string; label: string } {
  // Handle primitive types directly
  if (typeof item === 'string' || typeof item === 'number') {
    const value = item.toString();
    return { key: value, label: value };
  }

  // If the item is an object, try to extract key and label using common property names
  if (typeof item === 'object' && item !== null) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const typedItem = item as any;

    // Try to use the 'key' property first; if not available, use 'id'
    let keyProp = typedItem.key || typedItem.id;
    if (keyProp === undefined) {
      keyProp = item.toString();
    }

    // Determine the label by checking multiple possible properties
    let labelProp =
      typedItem.label || typedItem.value || typedItem.name || typedItem.title;
    if (labelProp === undefined) {
      labelProp = item.toString();
    }

    return { key: keyProp.toString(), label: labelProp.toString() };
  }

  // Fallback if item does not match expected types
  return { key: '', label: '' };
}

/**
 * Default option-matching used by Select and Autocomplete:
 * case-insensitive "contains".
 */
function defaultFilter(itemValue: string, filterValue: string): boolean {
  return itemValue.toLowerCase().includes(filterValue.toLowerCase());
}

export type {
  ListItem,
  ListItemArgs,
  ListItemRegistration,
  SelectionMode,
  AutoActivateMode
};
export { ListManager, canDeselectKey, keyAndLabelForItem, defaultFilter };
