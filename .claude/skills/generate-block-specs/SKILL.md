---
name: generate-block-specs
description: Turn one block's features from a free-form backlog into concise, ordered Feat specs under docs/specs/Block_<x>/, ready to become GitHub issues and sub-issues, then resolve their open questions with the user. Use when the user asks to spec, specify or write specs for a block (e.g. "spec block 1", "/generate-block-specs 2").
argument-hint: "[block number] [backlog path]"
---

# Generate block specs

Backlog (any format) → `docs/specs/Block_<x>/Feat<y>.md`, one file per feature, then a decision round on open questions.

Each Feat file maps to one GitHub issue: H1 = issue title, `Labels` line = labels, "Sub-issues" = GitHub sub-issues.

## 1. Inputs

Take the block number and the backlog path from the arguments. Ask for whatever is missing, both in one question.

Then read:

- **The backlog.** It has no fixed format: scattered notes, tables or prose. Read all of it.
- **The roadmap, if one exists** (e.g. `Resources (Local)/Roadmap-*.md`): the block's goal, steps, "done when" criteria and rules (scope, AI-assist policy, stack).
- **The CI/CD guidelines, if they exist** (e.g. `Resources (Local)/CI-CD Guidelines.md`): branching and merge policy, environments and their names, smoke tests, artifact promotion, secrets, database changes, and project-specific adaptations.
- **`CLAUDE.md`** and the existing specs in `docs/specs/`: for naming, conventions and dependencies on earlier blocks.
- **[feat-template.md](feat-template.md):** the structure every Feat file follows.

If `docs/specs/Block_<x>/` already contains files, ask whether to overwrite, extend or stop.

## 2. Select and order the features

1. **Collect** every backlog item that belongs to the block: items tagged with it, items whose concept the roadmap assigns to it, and decisions or constraints that touch them. Take only items marked as in scope or MVP. Leave optional items and alternatives out unless the user names them.
2. **Separate** features from setup tasks such as repo, pipeline or infrastructure scaffolding. Setup tasks go under "Depends on", not into Feat files.
3. **Order** them: anything another feature needs comes first (pipeline checks, shared models, the first migration). Otherwise, riskiest first. If order doesn't matter, say so.
4. **Confirm before writing:** show the feature list (number, title, backlog ID, one-line reason for its position) and ask the user to confirm or adjust it.

## 3. Write the Feat files

Write one `Feat<y>.md` per feature, following the template.

- **Concise:** short bullets, one fact each. No prose, no restating the goal, no filler.
- **Testable acceptance criteria:** observable outcomes (status codes, visible UI, pipeline pass or fail), not implementation steps.
- **Sub-issues:** one per pull-request-sized task, prefixed by area (`Domain:`, `Data:`, `API:`, `Angular:`, `Bicep:`, `CI/CD:`). Each becomes one short-lived branch and one squash-merged pull request. If the project has an AI-assist policy, mark the sub-issue that holds the block's main concept with `(core)`.
- **Definition of Done:** follows the project's rule and the CI/CD guidelines, e.g. merged by PR with CI green, deployed through the pipeline, smoke check passed, tests named, learning-log entry written.
- **Pipeline work follows the CI/CD guidelines:**
  - Use the guidelines' environment names.
  - Smoke checks cover health, essential dependencies and one user journey.
  - The artifact is built once and promoted.
  - Cloud access uses OIDC; no stored secrets.
  - Database changes stay backward compatible (expand/contract).
  - Where the guidelines and the roadmap differ, follow the project-specific adaptation and note it.
- **Non-goals:** name what comes later and where (block and backlog ID).
- **Design patterns:** name them where they fit (CLAUDE.md).
- **Language:** English only in the specs.
- **No invented features:** add nothing that isn't in the backlog or roadmap.
- **New services, libraries or tools:** never decide these silently. Raise each as an open question.

## 4. Check consistency

Before you present the files, check:

- **Hidden ordering problems:** an earlier Feat must not need something a later Feat creates. Example: a health check needs a `DbContext` that a later feature introduces. Resolve it with a scope note in the earlier Feat.
- Cross-references between Feats are correct (`[Feat2](Feat2.md)`), and shared names are the same in every file.
- Names match the CI/CD guidelines and the roadmap (e.g. environment names). Raise any conflict between them as an open question.
- Nothing is specced twice, and nothing the backlog assigns to the block is missing.

## 5. Resolve open questions

Gather the real open questions across all Feat files. Skip anything a sensible default answers; state that default in the spec instead.

For each question:

1. List the logical options, including any the user didn't think of.
2. For each option, briefly give: how it works · pros · cons · cost · limitations · effects on other parts of the project. Use a table if there are more than two options.
3. Give a recommendation.

Then ask for the decisions, recommended option first (AskUserQuestion, up to 4 questions per call).

Integrate each decision where it acts:

- **Scope:** what is built and how.
- **Acceptance criteria:** what must be observable.
- **Sub-issues:** new tasks, such as an ADR.
- **Non-goals:** what was deferred.

Use a `## Decisions made` section only when no section fits. Keep `## Open questions` only for items the user explicitly leaves open; otherwise remove the section.

## 6. Report

End with one line per Feat file (path · title · depends on), and any items still open.
