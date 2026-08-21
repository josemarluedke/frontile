import Component from '@glimmer/component';
import {
  Avatar,
  Button,
  ButtonGroup,
  Chip,
  Divider,
  Field,
  ProgressBar,
  Table,
  type ColumnConfig,
  type SortItem,
} from 'frontile';
import {
  SearchIcon,
  FilterIcon,
  PlusIcon,
  DuplicateIcon,
  ViewIcon,
  EditIcon,
  DeleteIcon,
} from '../icons';

/**
 * A composed application panel built only from Frontile components, used as the
 * specimen inside the hero's theme seam.
 *
 * Three constraints shape what's in here:
 *
 * 1. It is rendered twice — once per theme — so it must be safe to duplicate.
 *    Both copies are marked `inert` by the seam, which keeps duplicated
 *    controls out of the tab order and the accessibility tree.
 * 2. Nothing that portals to the document body may appear. Modal, Drawer,
 *    Dropdown, Popover, and Select all render through a portal, which would
 *    escape the seam's `clip-path` and leak the wrong theme across the whole
 *    page. Every control here renders in place. That rules out the Table's
 *    yielded `ColumnVisibility` menu too, which is a Dropdown.
 * 3. The seam clips vertically down the middle, so the columns that carry the
 *    most meaning are leftmost. What sits on the right is what the visitor
 *    earns by dragging.
 *
 * Because both copies are inert, every piece of state here is a resting state
 * rather than an interaction: the table arrives already sorted so the sort
 * indicator is visible, already has rows selected so the checkboxes and the
 * selection styling are visible, and the filter group has a segment chosen.
 */

interface Member {
  id: string;
  workerId: string;
  name: string;
  email: string;
  role: string;
  workerType: string;
}

const members: Member[] = [
  {
    id: '1',
    workerId: '#4586932',
    name: 'Kate Moore',
    email: 'kate@acme.com',
    role: 'Chief Executive Officer',
    workerType: 'Employee',
  },
  {
    id: '2',
    workerId: '#4586933',
    name: 'John Smith',
    email: 'john@acme.com',
    role: 'Chief Technology Officer',
    workerType: 'Employee',
  },
  {
    id: '3',
    workerId: '#4586935',
    name: 'Mike Wilson',
    email: 'mike@acme.com',
    role: 'VP of Engineering',
    workerType: 'Employee',
  },
  {
    id: '4',
    workerId: '#4586936',
    name: 'Alex Turner',
    email: 'alex@acme.com',
    role: 'Product Manager',
    workerType: 'Contractor',
  },
  {
    id: '5',
    workerId: '#4586937',
    name: 'Emma Davis',
    email: 'emma@acme.com',
    role: 'Senior Designer',
    workerType: 'Contractor',
  },
];

function isEmployee(workerType: string): boolean {
  return workerType === 'Employee';
}

export default class AppSpecimen extends Component {
  columns = [
    { key: 'workerId', name: 'Worker ID' },
    { key: 'name', name: 'Member', isSortable: true },
    { key: 'role', name: 'Role', isSortable: true },
    { key: 'workerType', name: 'Type', isSortable: true },
    { key: 'actions', name: 'Actions' },
  ] as const satisfies ColumnConfig<Member>[];

  /**
   * Sorted on arrival so the header renders its sort indicator rather than a
   * plain label.
   *
   * The direction is a cast string rather than `SortDirection.Ascending`:
   * `SortDirection` is a runtime enum upstream, but Frontile re-exports it from
   * its barrel as a *type* only, so its members are unreachable from
   * `frontile`. The value here is the enum's own — `"ascending"`.
   */
  initialSort: SortItem<Member> = {
    property: 'name',
    direction: 'ascending' as SortItem<Member>['direction'],
  };

  /**
   * The Table owns sort *state*, not sort *order* — `@initialSort` seeds the
   * indicator, but the rows arrive in whatever order the consumer hands over
   * unless `@onSort` is supplied. Providing it is what makes the header honest.
   */
  sortItems = (items: Member[], sort: SortItem<Member>): Member[] => {
    const key = sort.property as keyof Member;
    const factor = String(sort.direction) === 'descending' ? -1 : 1;

    return [...items].sort(
      (a, b) => String(a[key]).localeCompare(String(b[key])) * factor
    );
  };

  /** Two rows chosen so the selected styling and the header's mixed-state
      select-all checkbox are both on show. */
  selectedKeys = ['1', '3'];

  <template>
    <div
      class="bg-surface-app text-neutral-firm rounded-xl border border-neutral-soft overflow-hidden shadow-sm"
    >
      {{! Panel header }}
      <div class="flex items-center gap-3 px-5 py-4">
        <Avatar @size="sm" @name="Acme Inc" />
        <div class="min-w-0">
          <p class="font-header text-header-sm text-neutral-strong truncate">
            Workspace members
          </p>
          <p class="font-caption text-caption-sm text-neutral-firm">
            {{! The plan used to be a Chip sitting immediately left of Invite,
                where two pills side by side read as two buttons. As a word in
                the subtitle it is unmistakably a label. }}
            Team plan · 5 of 20 seats used
          </p>
        </div>
        <div class="ml-auto flex items-center">
          <Button @intent="primary" @size="sm">
            <PlusIcon />
            Invite
          </Button>
        </div>
      </div>

      <Divider />

      {{! Toolbar: search, a segmented filter with a segment already chosen, and
          a filter button carrying a count }}
      <div
        class="px-5 py-4 flex flex-wrap items-center gap-3 bg-surface-canvas"
      >
        <div class="min-w-0 grow sm:grow-0 sm:w-64">
          <Field @name="specimen-search" as |field|>
            <field.Input placeholder="Search members" @size="sm">
              <:startContent>
                <SearchIcon class="size-icon-sm text-neutral" />
              </:startContent>
            </field.Input>
          </Field>
        </div>

        <ButtonGroup @size="xs" as |g|>
          <g.ToggleButton @isSelected={{true}}>All</g.ToggleButton>
          <g.ToggleButton>Employees</g.ToggleButton>
          <g.ToggleButton>Contractors</g.ToggleButton>
        </ButtonGroup>

        <Button @appearance="outlined" @size="xs" class="ml-auto">
          <FilterIcon />
          Filters
          <Chip @size="sm" @appearance="faded">2</Chip>
        </Button>
      </div>

      {{! Table: selectable, pre-sorted, with an icon action group per row.
          Inset to the same 20px gutter as the header, toolbar, and footer, so
          the rows read as bands inside the panel rather than running into its
          border. }}
      <div class="px-5 py-2">
        <Table
          @columns={{this.columns}}
          @items={{members}}
          @selectionMode="multiple"
          @selectedKeys={{this.selectedKeys}}
          @initialSort={{this.initialSort}}
          @onSort={{this.sortItems}}
          @isScrollable={{true}}
        >
          <:cell as |c|>
            <c.For @key="workerId">
              <div class="flex items-center gap-2">
                <span
                  class="font-code text-code-sm text-neutral-firm"
                >{{c.row.data.workerId}}</span>
                <Button
                  @appearance="minimal"
                  @size="xs"
                  @class="px-0 size-7 shrink-0"
                  aria-label="Copy worker ID"
                >
                  <DuplicateIcon />
                </Button>
              </div>
            </c.For>

            <c.For @key="name">
              <div class="flex items-center gap-2 min-w-0">
                <Avatar @name={{c.row.data.name}} @size="xs" />
                <div class="min-w-0">
                  <p
                    class="font-label text-label-xs text-neutral-strong truncate"
                  >{{c.row.data.name}}</p>
                  <p
                    class="font-caption text-caption-sm text-neutral-firm truncate"
                  >{{c.row.data.email}}</p>
                </div>
              </div>
            </c.For>

            <c.For @key="workerType">
              {{! Employment type is a category, not a state, so it takes the
                  neutral chip. Colour-coding it would spend a semantic hue on
                  decoration and leave real status with no signal of its own. }}
              {{#if (isEmployee c.row.data.workerType)}}
                <Chip @size="sm" @appearance="faded">Employee</Chip>
              {{else}}
                <Chip @size="sm" @appearance="outlined">Contractor</Chip>
              {{/if}}
            </c.For>

            <c.For @key="actions">
              <div class="flex items-center gap-1.5">
                <Button
                  @appearance="soft"
                  @size="xs"
                  @class="px-0 size-7 shrink-0"
                  aria-label="View member"
                >
                  <ViewIcon />
                </Button>
                <Button
                  @appearance="soft"
                  @intent="primary"
                  @size="xs"
                  @class="px-0 size-7 shrink-0"
                  aria-label="Edit member"
                >
                  <EditIcon />
                </Button>
                <Button
                  @appearance="soft"
                  @intent="danger"
                  @size="xs"
                  @class="px-0 size-7 shrink-0"
                  aria-label="Remove member"
                >
                  <DeleteIcon />
                </Button>
              </div>
            </c.For>

            <c.Default>{{c.value}}</c.Default>
          </:cell>
        </Table>
      </div>

      {{! Footer strip. A full-width footer rather than a right rail: the seam
          cuts vertically, and a rail would spend the panel's right half on
          something the visitor only sees at the very end of the drag. }}
      <div
        class="px-5 py-4 bg-surface-canvas border-t border-neutral-soft flex flex-wrap items-center gap-x-8 gap-y-4"
      >
        <p class="font-label text-label-xs text-neutral-firm">
          2 of 5 selected
        </p>
        <div class="w-56 shrink-0 max-w-full">
          <ProgressBar
            @intent="primary"
            @label="Seat usage"
            @progress={{5}}
            @maxValue={{20}}
            @valueLabel="5 of 20"
            @size="sm"
          />
        </div>
        <div class="ml-auto flex items-center gap-2">
          <Button @appearance="outlined" @size="xs">Export</Button>
          <Button @appearance="minimal" @size="xs">Manage roles</Button>
        </div>
      </div>
    </div>
  </template>
}
