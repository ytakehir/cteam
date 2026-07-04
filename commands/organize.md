# Vault Organize

Process all files in `~/vault/Raw/` — analyze, enrich, and file them appropriately.

## When to use

When the user runs `/organize`, or when triggered by a scheduled task.

## Steps

1. List all files in `~/vault/Raw/` (exclude `Raw/processed/`)
2. If empty, report "Raw/ is empty" and stop
3. For each file:

### a. Analyze the content deeply

Before doing anything, read the full content and extract:

- **Core topic**: what is this really about?
- **Key insights**: what's most valuable here? (2–5 bullet points)
- **Connections**: what existing vault notes does this relate to? (search vault)
- **Type**: article / idea / conversation / reference / decision / research
- **Project relevance**: does this relate to a current Work/ project?

### b. Enrich the content

Rewrite the note before filing it:

- Add a clear, descriptive title if missing
- Add a 2–3 sentence summary at the top capturing the core value
- Expand the key insights section
- Add `[[wikilinks]]` to related vault notes found during analysis
- Add frontmatter:

  ```
  ---
  date: YYYY-MM-DD
  source: {URL if present}
  type: {article | idea | conversation | reference | decision | research}
  tags: [{relevant tags}]
  status: active
  ---
  ```

### c. Determine destination

**→ `Work/{project}/`** if:

- Directly about a current project (code, feature, bug, decision)
- Technical reference needed for a specific project
- Session or conversation about a project

**→ `Personal/`** if:

- General interest (music, news, design, culture, ideas)
- Cross-project technical knowledge
- Chat conversation content
- Has a URL but not clearly project-specific

**→ Both** if it spans work and personal: write enriched version to `Work/`, create a summary note in `Personal/` with link

**→ Leave in `Raw/`** with `#review` tag if truly ambiguous — do not force

### d. Write to destination

- For `Work/{project}/`: choose right subfolder (`decisions/` `logs/` `architecture/` `features/` `research/`)
      - Filename: `YYYY-MM-DD-{kebab-title}.md`
- If it reveals a decision → also create a `decisions/` note

### e. Archive original

Move original from `Raw/` to `Raw/archived/` — do NOT delete.
The processed/ folder is a safety net. Periodically ask the user if it's safe to clear.

## Report at end

For each file processed:

- Original filename
- Destination path
- Summary of key insights extracted
- Related notes linked

Total: N files processed, N archived to Raw/processed/
