---
name: landing-page-sync
description: "Sync the GitHub Pages landing page and step reader with workshop source-of-truth data (CLI version, module list, stats)."
tools:
  - search/textSearch
  - search/fileSearch
  - read/readFile
  - edit/editFiles
  - edit/multiEditFiles
user-invocable: true
disable-model-invocation: false
target: vscode
---

<instructions>
You MUST treat `.github/copilot-instructions.md` as the single source of truth for VALIDATED_CLI_VERSION, MODULE_COUNT, and WORKSHOP_DURATION.
You MUST treat the files in `docs/workshop/` as the source of truth for module titles, descriptions, and ordering.
You MUST sync `docs/index.html` stats (version, module count, duration) with the values from copilot-instructions.md.
You MUST sync the module list in `docs/index.html` (the `.parts-list` section) with the workshop module files.
You MUST sync the `steps` array in `docs/step.html` with the workshop module files.
You MUST extract each module's title from its first `# ` heading line.
You MUST extract each module's short description from its first non-empty paragraph or subtitle after the heading.
You MUST preserve the existing HTML structure, CSS classes, and layout when making edits.
You MUST NOT modify CSS files, JavaScript files, or the GitHub Actions workflow.
You MUST NOT change module file names, numbering, or content in `docs/workshop/`.
You MUST report every change made as a summary list after completing the sync.
You SHOULD flag any module that exists in `docs/workshop/` but is missing from the landing page.
You SHOULD flag any landing page entry that references a module not present in `docs/workshop/`.
</instructions>

<constants>
SOURCE_OF_TRUTH_FILE: ".github/copilot-instructions.md"

LANDING_PAGE: "docs/index.html"

STEP_READER: "docs/step.html"

WORKSHOP_DIR: "docs/workshop"

MODULE_GLOB: "docs/workshop/[0-9][0-9]-*.md"

STAT_SELECTORS: YAML<<
version:
  label: "Copilot CLI"
  pattern: "v[0-9]+\\.[0-9]+\\.[0-9]+"
module_count:
  label: "Modules"
  pattern: "[0-9]+"
duration:
  label: "Duration"
  pattern: "~[0-9]+\\.?[0-9]*h"
>>

STEP_ID_RULES: TEXT<<
- 00-index.md -> id: "index"
- NN-slug.md -> id: "NN-slug"
- file field: "workshop/NN-slug.md"
>>
</constants>

<formats>
<format id="SYNC_REPORT" name="Sync Report" purpose="Summary of all changes applied during the landing page sync.">
## Landing Page Sync Report

**Source versions**
- VALIDATED_CLI_VERSION: <CLI_VERSION>
- MODULE_COUNT: <MODULE_COUNT>
- WORKSHOP_DURATION: <DURATION>

**Changes applied**
<CHANGES>

**Warnings**
<WARNINGS>
WHERE:
- <CLI_VERSION> is String.
- <MODULE_COUNT> is Integer.
- <DURATION> is String.
- <CHANGES> is String; bullet list of edits or "None — landing page is already in sync."
- <WARNINGS> is String; bullet list of issues or "None."
</format>
</formats>

<runtime>
CLI_VERSION: ""
MODULE_COUNT: ""
DURATION: ""
MODULES: []
CHANGES: []
WARNINGS: []
</runtime>

<triggers>
<trigger event="user_message" target="sync-landing-page" />
</triggers>

<processes>
<process id="sync-landing-page" name="Sync Landing Page">
RUN `read-sources`
RUN `update-stats`
RUN `update-module-list`
RUN `update-step-reader`
RUN `report`
</process>

<process id="read-sources" name="Read Source of Truth">
USE `read/readFile` where: path=SOURCE_OF_TRUTH_FILE
CAPTURE CLI_VERSION from VALIDATED_CLI_VERSION value
CAPTURE MODULE_COUNT from MODULE_COUNT value
CAPTURE DURATION from WORKSHOP_DURATION value
USE `search/fileSearch` where: pattern=MODULE_GLOB
CAPTURE MODULES from matched file list sorted by name
</process>

<process id="update-stats" name="Update Stats Section">
USE `read/readFile` where: path=LANDING_PAGE
IF stat-value for "Copilot CLI" differs from CLI_VERSION:
  USE `edit/editFiles` where: new="v{CLI_VERSION}", old="current version string", path=LANDING_PAGE
  SET CHANGES := CHANGES + "Updated CLI version to v{CLI_VERSION}"
IF stat-value for "Modules" differs from MODULE_COUNT:
  USE `edit/editFiles` where: new=MODULE_COUNT, old="current count", path=LANDING_PAGE
  SET CHANGES := CHANGES + "Updated module count to {MODULE_COUNT}"
IF stat-value for "Duration" differs from DURATION:
  USE `edit/editFiles` where: new=DURATION, old="current duration", path=LANDING_PAGE
  SET CHANGES := CHANGES + "Updated duration to {DURATION}"
</process>

<process id="update-module-list" name="Update Module List in Landing Page">
FOR each module in MODULES:
  USE `read/readFile` where: path=module.path
  CAPTURE module.title from first heading
  CAPTURE module.description from first paragraph
IF module list in LANDING_PAGE differs from MODULES:
  USE `edit/editFiles` where: new="rebuilt parts-list HTML", old="current parts-list HTML", path=LANDING_PAGE
  SET CHANGES := CHANGES + "Updated module list entries"
IF any module in MODULES is missing from LANDING_PAGE:
  SET WARNINGS := WARNINGS + "Module {module.id} exists in workshop but missing from landing page"
IF any entry in LANDING_PAGE references a non-existent module:
  SET WARNINGS := WARNINGS + "Landing page references non-existent module {entry.id}"
</process>

<process id="update-step-reader" name="Update Step Reader Array">
USE `read/readFile` where: path=STEP_READER
IF steps array differs from MODULES:
  USE `edit/editFiles` where: new="rebuilt steps array", old="current steps array", path=STEP_READER
  SET CHANGES := CHANGES + "Updated step reader steps array"
</process>

<process id="report" name="Emit Sync Report">
RETURN: format="SYNC_REPORT"
</process>
</processes>

<input>
USER_INPUT is an optional message; the agent runs the full sync regardless of input content.
</input>
