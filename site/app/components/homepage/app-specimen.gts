import Component from '@glimmer/component';
import {
  Avatar,
  Button,
  Chip,
  Divider,
  Field,
  ProgressBar,
  Table,
  type ColumnConfig
} from 'frontile';
import { SearchIcon } from '../icons';

/**
 * A composed application panel built only from Frontile components, used as the
 * specimen inside the hero's theme seam.
 *
 * Two constraints shape what's in here:
 *
 * 1. It is rendered twice — once per theme — so it must be safe to duplicate.
 *    Both copies are marked `inert` by the seam, which keeps duplicated
 *    controls out of the tab order and the accessibility tree.
 * 2. Nothing that portals to `<body>` may appear. Modal, Drawer, Dropdown,
 *    Popover, and Select all render through a portal, which would escape the
 *    seam's `clip-path` and leak the wrong theme across the whole page. Every
 *    control here renders in place.
 */

interface Member {
  id: string;
  name: string;
  email: string;
  role: string;
  status: string;
}

const members: Member[] = [
  {
    id: '1',
    name: 'Ada Okonkwo',
    email: 'ada@example.com',
    role: 'Owner',
    status: 'active'
  },
  {
    id: '2',
    name: 'Bruno Salas',
    email: 'bruno@example.com',
    role: 'Editor',
    status: 'active'
  },
  {
    id: '3',
    name: 'Chen Wei',
    email: 'chen@example.com',
    role: 'Viewer',
    status: 'invited'
  }
];

function isActive(status: string): boolean {
  return status === 'active';
}

export default class AppSpecimen extends Component {
  columns = [
    { key: 'name', name: 'Member' },
    { key: 'role', name: 'Role' },
    { key: 'status', name: 'Status' }
  ] as const satisfies ColumnConfig<Member>[];

  isActive = isActive;

  <template>
    <div
      class="bg-surface-app text-neutral-firm rounded-xl border border-neutral-soft overflow-hidden shadow-sm"
    >
      {{! Panel header }}
      <div class="flex items-center gap-3 px-5 py-4">
        <Avatar @size="sm" @name="Ada Okonkwo" />
        <div class="min-w-0">
          <p class="font-header text-header-sm text-neutral-strong truncate">
            Workspace members
          </p>
          <p class="font-caption text-caption-sm text-neutral-firm">
            3 of 20 seats used
          </p>
        </div>
        <div class="ml-auto flex items-center gap-2">
          <Chip @intent="primary" @size="sm">Team plan</Chip>
          <Button @intent="primary" @size="sm">Invite</Button>
        </div>
      </div>

      <Divider />

      <div class="grid grid-cols-1 sm:grid-cols-[1fr_15rem]">
        {{! Table column }}
        <div class="p-5 min-w-0">
          <div class="mb-4">
            <Field @name="specimen-search" as |field|>
              <field.Input placeholder="Search members" @size="sm">
                <:startContent>
                  <SearchIcon class="size-icon-sm text-neutral" />
                </:startContent>
              </field.Input>
            </Field>
          </div>

          <Table @columns={{this.columns}} @items={{members}}>
            <:cell as |c|>
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

              <c.For @key="role">
                {{! Roles are categories, not states. Colour-coding them would
                    spend the semantic hues on decoration and leave the status
                    column with no signal of its own. }}
                <Chip
                  @size="sm"
                  @appearance="faded"
                >{{c.row.data.role}}</Chip>
              </c.For>

              <c.For @key="status">
                {{#if (this.isActive c.row.data.status)}}
                  <Chip
                    @size="sm"
                    @appearance="faded"
                    @intent="success"
                    @withDot={{true}}
                  >Active</Chip>
                {{else}}
                  {{!-- Neutral rather than warning: a pending invitation is not
                        a warning, and Frontile's warning chip measures 3.2 to
                        4.0 to 1 at this size in both schemes, under the 4.5
                        threshold whichever appearance is used. The dot carries
                        the pending reading. --}}
                  <Chip @size="sm" @appearance="faded" @withDot={{true}}>
                    Invited
                  </Chip>
                {{/if}}
              </c.For>

              <c.Default>{{c.value}}</c.Default>
            </:cell>
          </Table>
        </div>

        {{! Side rail }}
        <div
          class="p-5 bg-surface-canvas border-t sm:border-t-0 sm:border-l border-neutral-soft"
        >
          <ProgressBar
            @intent="primary"
            @label="Seat usage"
            @progress={{3}}
            @maxValue={{20}}
            @valueLabel="3 of 20"
          />

          <div class="mt-5">
            <p
              class="font-label text-label-2xs text-neutral-firm uppercase mb-3"
            >Roles in use</p>
            <div class="flex flex-wrap gap-2">
              <Chip @size="sm">Owner</Chip>
              <Chip @size="sm">Editor</Chip>
              <Chip @size="sm">Viewer</Chip>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
}
