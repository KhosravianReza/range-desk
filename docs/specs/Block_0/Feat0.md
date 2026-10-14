# Feat0 · Walking skeleton and pipeline (setup)

**Block:** B0 · **Backlog ID:** none (Roadmap B0 steps 1–7) · **Labels:** `block-0`, `platform`

## Goal

Everything [Feat1](Feat1.md) and [Feat2](Feat2.md) build on: the solution, tests, CI, infrastructure as code, the OIDC deploy to `staging`, and the seed, dump and restore scripts.

## Scope

- Repo: `docs/log/`, `docs/adr/`, `docs/arc42/`; `main` ruleset (pull request required, no force pushes, squash merge, merged branches deleted).
- Solution: ASP.NET Core API, Angular shell, PostgreSQL in Docker Compose.
  - EF Core and the first migration come with [Feat2](Feat2.md); health checks with [Feat1](Feat1.md).
- Test project with a first unit test.
- CI (`ci.yml`): build and test on every pull request to `main` and after each merge.
  - `permissions: contents: read`; outdated runs of the same pull request are cancelled.
  - Once it has run, the ruleset requires it (status checks pass, branch up to date).
- Bicep, one resource group per session: Container Registry, Container Apps environment, API container app, PostgreSQL Flexible Server, Blob Storage, Log Analytics.
- CD (`deploy-staging.yml`), started manually at the beginning of a session:
  - Azure sign-in through a GitHub OIDC federated credential; no stored secrets.
  - Bicep → image tagged with the commit SHA → Container Registry → Container Apps (`staging`).
  - Merges to `main` don't deploy outside a session (CI/CD guide adaptation: nothing runs permanently in Azure).
- Scripts:
  - Seed: synthetic data, idempotent. [Feat2](Feat2.md) adds the clubs.
  - Teardown: dump PostgreSQL to a local, git-ignored file, then delete the session's resource group.
  - Restore: on the next deploy, restore the last dump, or seed if there is none.

## Acceptance criteria

- [ ] A pull request to `main` can't be merged until CI passes. Direct pushes and force pushes to `main` are rejected.
- [ ] A failing unit test fails CI.
- [ ] `docker compose up` starts the API, the Angular shell and PostgreSQL locally.
- [ ] The deploy workflow, started with no resource group present, creates it and serves the Angular shell and the API at a public `staging` URL.
- [ ] The running image's tag is the commit SHA it was built from.
- [ ] No secret in the repo, the workflows or the image.
- [ ] Teardown leaves a dump file locally and no resource group in Azure.
- [ ] Deploy + restore after a teardown restores the database from the dump. Verified with real data in [Feat2](Feat2.md).

## Definition of Done

- [ ] Merged to `main` by pull requests with CI green.
- [ ] Deployed to `staging` through the pipeline; the Angular shell and the API answer at the public URL.
- [ ] One teardown → deploy → restore cycle done; noted in the learning log.
- [ ] Learning-log entry written.

## Sub-issues

1. Repo: `docs/log`, `docs/adr`, `docs/arc42`; `main` ruleset.
2. Solution: ASP.NET Core API, Angular shell, PostgreSQL in Docker Compose.
3. Tests: test project and first unit test.
4. CI: `ci.yml` (build + test on pull requests); then require the check in the ruleset.
5. Bicep: Container Registry, Container Apps environment, API app, PostgreSQL, Blob Storage, Log Analytics.
6. CD: OIDC federated credential; image → Container Registry → Container Apps (`staging`).
7. Scripts: seed, teardown (dump), restore.

## Depends on

- None.

## Non-goals

- Health checks, the version endpoint and the smoke test ([Feat1](Feat1.md)).
- The `Club` entity, the first migration, the migration bundle and Playwright ([Feat2](Feat2.md)).
- `production` and promotion to it (later; CI/CD guide §6).
- Container Registry Tasks, revisions and traffic split (B2).
- Key Vault and App Configuration (B5).
- Scheduled maintenance jobs (CI/CD guide adaptation: nothing to check outside a session).
