# Package Consolidation Migration Guide

## Overview

Starting with version **0.18.0**, Frontile consolidates seven separate `@frontile/*` packages into a single `frontile` package:

- `@frontile/buttons`
- `@frontile/collections`
- `@frontile/forms`
- `@frontile/overlays`
- `@frontile/notifications`
- `@frontile/status`
- `@frontile/utilities`

**Why?** Modern Ember.js applications use explicit imports via `.gts`/`.gjs` template tag format. With explicit imports, bundlers can tree-shake unused code automatically, making the multi-package architecture unnecessary overhead. A single package simplifies installation, version management, and dependency resolution without sacrificing bundle size.

**Timeline:**

| Version | What happens |
|---------|--------------|
| **0.18.0** | The old `@frontile/*` packages become thin deprecation wrappers that re-export from `frontile`. All existing import paths continue to work, but emit deprecation warnings at build time. |
| **0.19.0** | The old `@frontile/*` wrapper packages are removed. You must update imports to use `frontile` directly. |

## Quick Start

Update your app in two steps:

### 1. Swap packages

```bash
# Remove old packages
npm uninstall @frontile/buttons @frontile/collections @frontile/forms \
  @frontile/overlays @frontile/notifications @frontile/status @frontile/utilities

# Install the consolidated package (if not already installed)
npm install frontile @frontile/theme
```

If you use **pnpm** or **yarn**, substitute the appropriate commands:

```bash
# pnpm
pnpm remove @frontile/buttons @frontile/collections @frontile/forms \
  @frontile/overlays @frontile/notifications @frontile/status @frontile/utilities
pnpm add frontile @frontile/theme

# yarn
yarn remove @frontile/buttons @frontile/collections @frontile/forms \
  @frontile/overlays @frontile/notifications @frontile/status @frontile/utilities
yarn add frontile @frontile/theme
```

### 2. Update imports

Replace `@frontile/<package>` with `frontile/<package>` (or just `frontile`) in your source files. See the [Import Path Changes](#import-path-changes) section below for details.

## Import Path Changes

Three import styles are supported with the consolidated package:

### Flat barrel import

Import everything from one place:

```typescript
import { Button, Modal, Input, ProgressBar } from 'frontile';
```

### Scoped sub-exports (by category)

Import from a category-specific path. This mirrors the old package names without the `@frontile/` prefix:

```typescript
import { Button, ButtonGroup, Chip } from 'frontile/buttons';
import { Modal, Drawer, Overlay, Popover } from 'frontile/overlays';
import { Input, Select, Checkbox, Textarea } from 'frontile/forms';
import { Table, Listbox, Dropdown } from 'frontile/collections';
import { NotificationCard, NotificationsContainer } from 'frontile/notifications';
import { ProgressBar } from 'frontile/status';
import { Avatar, Collapsible, Divider, Spinner } from 'frontile/utilities';
```

### Direct component file imports

For maximum control and tree-shaking, import directly from the component file:

```typescript
import Button from 'frontile/components/buttons/button';
import Modal from 'frontile/components/overlays/modal';
import Header from 'frontile/components/overlays/modal/header';
import Input from 'frontile/components/forms/input';
```

## Import Mapping Table

The table below shows how old import paths map to the new paths.

### Barrel imports

| Old Import | New Import |
|---|---|
| `from '@frontile/buttons'` | `from 'frontile/buttons'` or `from 'frontile'` |
| `from '@frontile/forms'` | `from 'frontile/forms'` or `from 'frontile'` |
| `from '@frontile/collections'` | `from 'frontile/collections'` or `from 'frontile'` |
| `from '@frontile/overlays'` | `from 'frontile/overlays'` or `from 'frontile'` |
| `from '@frontile/notifications'` | `from 'frontile/notifications'` or `from 'frontile'` |
| `from '@frontile/status'` | `from 'frontile/status'` or `from 'frontile'` |
| `from '@frontile/utilities'` | `from 'frontile/utilities'` or `from 'frontile'` |

### Sub-path imports

| Old Import | New Import |
|---|---|
| `from '@frontile/overlays/components/modal'` | `from 'frontile/components/overlays/modal'` |
| `from '@frontile/overlays/components/modal/header'` | `from 'frontile/components/overlays/modal/header'` |
| `from '@frontile/overlays/components/drawer'` | `from 'frontile/components/overlays/drawer'` |
| `from '@frontile/overlays/components/overlay'` | `from 'frontile/components/overlays/overlay'` |
| `from '@frontile/overlays/components/popover'` | `from 'frontile/components/overlays/popover'` |
| `from '@frontile/forms/test-support'` | `from 'frontile/test-support'` |
| `from '@frontile/utilities/utils/safe-styles'` | `from 'frontile/utils/safe-styles'` |
| `from '@frontile/notifications/services/notifications'` | `from 'frontile/services/notifications'` |

## Automated Migration Script

Save the following script as `migrate-frontile.sh` and run it from your project root to update all import paths automatically.

```bash
#!/bin/bash
# Migrate Frontile imports from @frontile/* to frontile
# Run from your project root
#
# Usage:
#   chmod +x migrate-frontile.sh
#   ./migrate-frontile.sh

set -euo pipefail

echo "Migrating @frontile/* imports to frontile..."

# Sub-path imports (must run BEFORE barrel imports to avoid partial matches)
find app tests -name '*.ts' -o -name '*.gts' -o -name '*.js' -o -name '*.gjs' | \
  xargs sed -i '' \
    -e "s|from '@frontile/overlays/components/|from 'frontile/components/overlays/|g" \
    -e "s|from '@frontile/notifications/services/|from 'frontile/services/|g" \
    -e "s|from '@frontile/forms/test-support|from 'frontile/test-support|g" \
    -e "s|from '@frontile/utilities/utils/|from 'frontile/utils/|g" \
    -e "s|from '@frontile/collections/utils/|from 'frontile/utils/|g"

# Barrel imports
find app tests -name '*.ts' -o -name '*.gts' -o -name '*.js' -o -name '*.gjs' | \
  xargs sed -i '' \
    -e "s|from '@frontile/buttons'|from 'frontile/buttons'|g" \
    -e "s|from '@frontile/collections'|from 'frontile/collections'|g" \
    -e "s|from '@frontile/forms'|from 'frontile/forms'|g" \
    -e "s|from '@frontile/overlays'|from 'frontile/overlays'|g" \
    -e "s|from '@frontile/notifications'|from 'frontile/notifications'|g" \
    -e "s|from '@frontile/status'|from 'frontile/status'|g" \
    -e "s|from '@frontile/utilities'|from 'frontile/utilities'|g"

echo "Done! Review the changes with: git diff"
```

**Note:** The `sed -i ''` syntax is for macOS. On Linux, use `sed -i` (without the empty quotes) instead.

## Packages NOT Affected

The following packages are **not** part of this consolidation. Their imports remain unchanged:

- **`@frontile/theme`** -- The styling system. Stays as a separate package because it provides Tailwind CSS configuration and has a distinct role in the build pipeline.
- **`@frontile/forms-legacy`** -- Legacy form components. Will be dropped before v1.0.
- **`@frontile/changeset-form`** -- Changeset integration. Will be dropped before v1.0.

## Deprecation Timeline

| Version | Status |
|---------|--------|
| **0.18.0** | Old `@frontile/*` packages become thin wrappers that re-export from `frontile`. They emit deprecation warnings at build time. All existing import paths continue to work. |
| **0.19.0** | Old `@frontile/*` wrapper packages are removed. You must update imports to use `frontile` directly. |

During the **0.18.x** cycle, you can migrate at your own pace. Both old and new import paths work simultaneously. However, we recommend migrating sooner rather than later to avoid a last-minute rush before 0.19.0.

## For .hbs Template Users

If you use `.hbs` templates (not `.gts`/`.gjs`), components remain auto-importable through the deprecated wrapper packages during the 0.18.x cycle. However, you should plan to migrate to `.gts` explicit imports before 0.19.0, as the wrapper packages will be removed.

During 0.18.x, `.hbs` users should:

1. Keep the deprecated `@frontile/*` packages installed so that auto-imports continue to work.
2. Plan migration to `.gts`/`.gjs` template format for new code.
3. Use explicit imports in any new `.gts`/`.gjs` files.

Once you have migrated all templates to `.gts`/`.gjs`, you can remove the deprecated wrapper packages and use the new `frontile` imports exclusively.
