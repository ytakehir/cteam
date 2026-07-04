---
name: create-issue
description: Use when creating a new GitHub Issue — for out-of-scope items, follow-ups, TODOs, and secondary spikes
---

# Create Issue

## Label Selection
- **priority**: default `medium`; `high` if blocking, `low` if trivial
- **domain**: infer from files/subsystem (`frontend`/`backend`/`infra`/`db`/`auth`)
- **type**: infer from action (`feature`/`bug`/`refactor`/`test`/`docs`/`performance`/`research`)
- **status**: always `todo`
- **size**: `s` < 1hr, `m` < 4hr, `l` > 4hr

## Body Template

    ## Context
    Why this Issue exists (link parent Issue/PR if applicable)

    ## Requirements
    - [ ] Requirement 1
    - [ ] Requirement 2

    ## Notes
    Constraints, references, related decisions

## Command

    gh issue create \
      --title "{imperative, concise title}" \
      --body "{body}" \
      --label "status:todo,priority:{p},type:{t},domain:{d},size:{s}"

## Rules
- Title: imperative mood, concise
- Always: status + priority + type labels minimum
- Link parent Issue/PR when created from another task
- English only
