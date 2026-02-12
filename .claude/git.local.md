---
enabled: true
# Commit Message Conventions
scopes:
  - ai
  - widget
  - strategy
  - spec
  - integration
  - option
  - docs
  - ci
types:
  - feat
  - fix
  - docs
  - refactor
  - test
  - chore
  - perf
  - style
# Branch Naming Conventions
branch_prefixes:
  feature: feature/*
  fix: fix/*
  hotfix: hotfix/*
  refactor: refactor/*
  docs: docs/*
# .gitignore Generation Defaults
gitignore:
  os: [macos, linux, windows]
  languages: [ruby, shell]
  frameworks: []
  tools: [rspec, github-actions]
---

# Project-Specific Git Settings

This file configures the `@git/` plugin for this project. The settings above in the YAML frontmatter define valid scopes, types, and branch naming conventions that the plugin will enforce.

## Usage

- **Scopes**: When creating a commit with `/commit`, choose from the defined `scopes`.
- **Branching**: When creating a new branch via the `git` skill, use the defined `branch_prefixes`.
- **Gitignore**: When running `/gitignore` without arguments, the technologies listed above will be used as defaults.

## Additional Guidelines

- Always run tests before committing.
- Ensure linting passes before pushing.
- Reference issue numbers in commit footers (e.g., `Closes #123`).
- Use `BREAKING CHANGE:` prefix in the body for breaking changes.