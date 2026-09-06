/**
 * Common icons used in documentation examples
 *
 * Each icon wraps a Lucide icon (via unplugin-icons' `~icons/lucide/*` virtual
 * modules, compiled to a Glimmer template-only component by `compiler: 'ember'`
 * in site/vite.config.mjs) with this file's stable size class, so every `.md`
 * demo that imports from `site/components/icons` keeps working unchanged.
 */
import type { TOC } from '@ember/component/template-only';
import IconEye from '~icons/lucide/eye';
import IconPencil from '~icons/lucide/pencil';
import IconCopy from '~icons/lucide/copy';
import IconShare2 from '~icons/lucide/share-2';
import IconDownload from '~icons/lucide/download';
import IconArchive from '~icons/lucide/archive';
import IconTrash2 from '~icons/lucide/trash-2';
import IconPlus from '~icons/lucide/plus';
import IconFilter from '~icons/lucide/filter';
import IconChevronDown from '~icons/lucide/chevron-down';
import IconStar from '~icons/lucide/star';
import IconSearch from '~icons/lucide/search';
import IconSun from '~icons/lucide/sun';
import IconMoon from '~icons/lucide/moon';
import IconUser from '~icons/lucide/user';
import IconCheck from '~icons/lucide/check';
import IconCode from '~icons/lucide/code';
import IconPalette from '~icons/lucide/palette';
import IconBookOpen from '~icons/lucide/book-open';
import IconTarget from '~icons/lucide/target';
import IconAccessibility from '~icons/lucide/accessibility';
import IconSparkles from '~icons/lucide/sparkles';
import IconComponent from '~icons/lucide/component';
import IconPackage from '~icons/lucide/package';
import IconRocket from '~icons/lucide/rocket';
import IconSettings from '~icons/lucide/settings';
import IconLogOut from '~icons/lucide/log-out';

type IconSignature = TOC<{ Element: SVGSVGElement }>;

export const ViewIcon: IconSignature = <template>
  <IconEye class="size-icon-lg" ...attributes />
</template>;

export const EditIcon: IconSignature = <template>
  <IconPencil class="size-icon-lg" ...attributes />
</template>;

export const DuplicateIcon: IconSignature = <template>
  <IconCopy class="size-icon-lg" ...attributes />
</template>;

export const ShareIcon: IconSignature = <template>
  <IconShare2 class="size-icon-lg" ...attributes />
</template>;

export const DownloadIcon: IconSignature = <template>
  <IconDownload class="size-icon-lg" ...attributes />
</template>;

export const ArchiveIcon: IconSignature = <template>
  <IconArchive class="size-icon-lg" ...attributes />
</template>;

export const DeleteIcon: IconSignature = <template>
  <IconTrash2 class="size-icon-lg" ...attributes />
</template>;

export const PlusIcon: IconSignature = <template>
  <IconPlus class="size-icon-lg" ...attributes />
</template>;

export const FilterIcon: IconSignature = <template>
  <IconFilter class="size-icon-lg" ...attributes />
</template>;

export const ChevronDownIcon: IconSignature = <template>
  <IconChevronDown class="size-icon-md" ...attributes />
</template>;

export const StarIcon: IconSignature = <template>
  <IconStar class="size-icon-lg" ...attributes />
</template>;

export const SearchIcon: IconSignature = <template>
  <IconSearch class="size-icon-md" ...attributes />
</template>;

export const SunIcon: IconSignature = <template>
  <IconSun class="size-icon-sm" ...attributes />
</template>;

export const MoonIcon: IconSignature = <template>
  <IconMoon class="size-icon-sm" ...attributes />
</template>;

export const UserIcon: IconSignature = <template>
  <IconUser class="size-icon-sm" ...attributes />
</template>;

export const CheckIcon: IconSignature = <template>
  <IconCheck class="size-icon-lg" ...attributes />
</template>;

export const CodeIcon: IconSignature = <template>
  <IconCode class="size-icon-lg" ...attributes />
</template>;

export const PaletteIcon: IconSignature = <template>
  <IconPalette class="size-icon-lg" ...attributes />
</template>;

export const BookIcon: IconSignature = <template>
  <IconBookOpen class="size-icon-lg" ...attributes />
</template>;

export const TargetIcon: IconSignature = <template>
  <IconTarget class="size-icon-lg" ...attributes />
</template>;

export const AccessibilityIcon: IconSignature = <template>
  <IconAccessibility class="size-icon-lg" ...attributes />
</template>;

export const SparklesIcon: IconSignature = <template>
  <IconSparkles class="size-icon-lg" ...attributes />
</template>;

export const ComponentIcon: IconSignature = <template>
  <IconComponent class="size-icon-lg" ...attributes />
</template>;

export const PackageIcon: IconSignature = <template>
  <IconPackage class="size-icon-lg" ...attributes />
</template>;

export const RocketIcon: IconSignature = <template>
  <IconRocket class="size-icon-lg" ...attributes />
</template>;

export const SettingsIcon: IconSignature = <template>
  <IconSettings class="size-icon-lg" ...attributes />
</template>;

export const LogoutIcon: IconSignature = <template>
  <IconLogOut class="size-icon-lg" ...attributes />
</template>;
