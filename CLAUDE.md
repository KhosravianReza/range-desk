# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Guidelines

- **Design patterns:** When a design pattern is a good fit, say so and name it.
- **Architecture:** Always keep the architecture clean and correct: clear separation of concerns, sensible layering, no shortcuts that cause coupling.
- **Language:** Do not use German words or terminology in code, comments, docs, or commit messages. Use English only. Content the app processes (e.g. rule books) may be in any language.
- **Spec changes** (`docs/specs/`), by the Feat's state:
  - Not started: refine through a pull request that states the reason, only if needed.
  - In progress: only to close a gap found while implementing; make it visible in the pull request and call out changed acceptance criteria.
  - Done: frozen. New behaviour → a new Feat or a backlog item; a changed decision → a new ADR that supersedes the old one.
  - Never add work silently: new scope goes to the backlog.
