---
name: draft-pull-request
description: Draft the pull request title and description for the current branch against main, in this repo's format (Summary, Notes, "Closes #<issue>"), and flag problems in the branch's changes. Never pushes or creates the pull request. Use when the user asks for a PR title, PR description or pull request text (e.g. "draft the PR", "/draft-pull-request 26").
argument-hint: "[issue number]"
allowed-tools: Bash(git fetch:*), Bash(git status:*), Bash(git branch:*), Bash(git log:*), Bash(git diff:*), Bash(gh issue view:*), Bash(gh pr view:*), Bash(gh pr list:*)
---

# Draft pull request

Branch changes → a title and a description the user pastes into the pull request. Never push, create or edit the pull request.

Merges are squash only, with `PR_TITLE` and `PR_BODY` ([Set-RepoSettings.ps1](../../../scripts/github/Set-RepoSettings.ps1)): the title becomes the commit subject on `main` and the description its body. Write both as a commit on `main` that stays in the history.

## 1. Read the changes

1. `git fetch origin main`, then `git log --oneline origin/main..HEAD` and `git diff --stat origin/main...HEAD`.
2. `git diff origin/main...HEAD -- . ':!*package-lock.json' ':!*.lock'` for the content. Read it file by file if it is large; skip generated boilerplate.
3. `git status --short`: if there are uncommitted or unpushed changes, say that they aren't in the pull request yet.

Branch commit messages are background only; describe the final diff, not the history.

## 2. Read the issue and its spec

- Issue number: from the argument, else from the branch name (`chore/26-solution-boilerplate` → `26`). If neither has one, ask; with no issue, leave out the `Closes` line.
- `gh issue view <n> --json title,body,labels`. Its body links the Feat spec (`docs/specs/Block_<x>/Feat<y>.md`); read the local file: the sub-issue, scope and acceptance criteria.
- If `gh pr list --head <branch>` shows an open pull request, say so: the draft replaces its text.

## 3. Write the title

`<type>: <outcome>`

- Type of the main change: `feat`, `fix`, `refactor`, `test`, `docs`, `ci`, `build`, `chore`. Scaffolding and setup are `chore`; `docs` only when only docs changed.
- Imperative, lowercase after the colon, no period, no issue number: GitHub appends ` (#<pr>)` on merge.
- At most 65 characters, so the subject stays within 72 after the merge.
- Name the outcome, not the files.

## 4. Write the description

```
## Summary

- `<path>`: <what it is or does>; <key detail>.
- ...

## Notes

- ...

Closes #<issue>
```

**Summary:**

- One bullet per deliverable, ordered from foundation to top layer (solution and config → projects → containers → docs).
- Lead with the path in backticks, or a short name for docs (`ADR 0001: ...`, `README: ...`). Nested bullets only for parts of one deliverable.
- Key details in parentheses: versions, notable settings, safety defaults ("dry run by default", "ports bound to localhost").
- Changes under `docs/specs/`: say what moved or changed and why, naming the Feat and any changed acceptance criteria (CLAUDE.md spec-change rule). A Feat that is done is frozen; flag any change to one.

**Notes** (leave out if empty):

- What isn't in this pull request yet, and where it comes: "No CI yet (sub-issue 4)".
- Manual steps taken or needed: settings applied, CLI scopes, prerequisites.
- Verification: list only what you saw run in this session. Otherwise add `Verified locally: <fill in>` and point it out.

**Style:** short fragments, one fact per bullet, no filler, English only (CLAUDE.md). No attribution line.

## 5. Check the changes

Flag, don't fix. Report only what you found:

- `.editorconfig` violations: trailing whitespace, missing final newline, a BOM, wrong indentation.
- Secrets or local-only files: `.env`, connection strings, keys, `*.user`.
- Debug leftovers, commented-out code, TODOs without an issue.
- Scope: work outside the issue's sub-issue, or new scope not in the specs or backlog. New scope goes to the backlog (CLAUDE.md).
- Unrelated concerns that would read better as separate pull requests.

## 6. Output

````
**Title**
```
<title>
```

**Description**
```markdown
<description>
```

**Labels:** <the issue's labels>
````

Then, only where they apply: the findings, the source of the issue number, placeholders left to fill. End with "Nothing pushed or created."
