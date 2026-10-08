# Feat1 · Health endpoint and deployed version (PL-1)

**Block:** B0 · **Backlog ID:** PL-1 · **Labels:** `block-0`, `platform`

## Goal

Make every deployment checkable. The API reports whether it is healthy, and the UI shows which commit and revision are running. The pipeline's smoke test uses both to confirm that the build it just deployed is live.

## Scope

- Health endpoints:
  - `GET /health/live`: the process is up. No dependency checks.
  - `GET /health/ready`: the API can serve requests, including a PostgreSQL connectivity check.
  - An empty `DbContext` (or a plain connection check) is enough here; [Feat2](Feat2.md) adds the `Club` entity and the first migration.
- Version endpoint: `GET /api/version` returns `{ commitSha, revision }`.
  - `commitSha` is baked into the image at build time (build arg → env var).
  - `revision` comes from the `CONTAINER_APP_REVISION` env var that Container Apps sets.
  - Locally, both fall back to `local`.
- Angular footer on every page: the short SHA (7 characters) and the revision, fetched from `/api/version`.
  - The SPA is served from the API image (multi-stage Dockerfile → `wwwroot`, fallback to `index.html`), so one SHA covers UI and API. Record this in an ADR.
- Container Apps liveness and readiness probes point at the two health endpoints (Bicep).
- A smoke-test step in the CD workflow, run after each deploy to `staging`.

## Acceptance criteria

- [ ] `/health/live` returns `200` while the process runs, even if PostgreSQL is down.
- [ ] `/health/ready` returns `200` when PostgreSQL is reachable and `503` when it is not.
- [ ] Health responses never contain connection strings, hostnames or exception details.
- [ ] `/api/version` returns the commit SHA the image was built from and the active revision name.
- [ ] Locally (Docker Compose), `/api/version` returns `local` for both fields.
- [ ] The footer shows `<short SHA> · <revision>` on every page, or `unknown` if the call fails. A failed call never breaks the page.
- [ ] No endpoint in this feature requires sign-in.
- [ ] Unknown `/api/*` and `/health/*` paths return `404`, never the SPA's `index.html`.
- [ ] Smoke test: after deploy, the pipeline polls `/health/ready` until it returns `200`, with a timeout. It then fails the run unless `/api/version`'s `commitSha` equals `GITHUB_SHA`.
- [ ] Container Apps probes use `/health/live` (liveness) and `/health/ready` (readiness).

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke test passed against the deployed SHA.
- [ ] Tests: an integration test checks `/health/ready` with PostgreSQL up and down, and a unit or integration test checks the version fallback.
- [ ] Learning-log entry written.

## Sub-issues

1. API: health checks (`live`, `ready` with a PostgreSQL check).
2. API: `/api/version`, with the SHA injected at image build.
3. Angular: version footer.
4. Bicep: liveness and readiness probes on the API container app.
5. CD: smoke-test step (health poll + SHA match).

## Depends on

The B0 walking skeleton (API, Angular shell, PostgreSQL in Docker Compose), CI, Bicep and the OIDC CD workflow. These are setup tasks, not backlog features.

## Non-goals

- Traffic split or multiple active revisions (B2).
- Health checks for Redis, Cosmos DB or Service Bus (added with those services).
- Alerts and dashboards on health (B5).
