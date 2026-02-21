import { buildWaiter } from '@ember/test-waiters';
const waiter = buildWaiter('frontile:triggerFormInputEvent)');

function triggerFormInputEvent(element?: HTMLElement | null): void {
  if (!element) return;
  const waiterToken = waiter.beginAsync();

  setTimeout(() => {
    let parent = element.parentElement;
    while (parent) {
      if (parent.tagName === 'FORM') {
        (parent as HTMLFormElement).dispatchEvent(
          new Event('input', { bubbles: true })
        );
        break;
      }
      parent = parent.parentElement;
    }

    waiter.endAsync(waiterToken);
  }, 0);
}

export { triggerFormInputEvent };
export {
  flattenData,
  unflattenData,
  hasNestedData,
  deepEqual
} from './nested-data';
