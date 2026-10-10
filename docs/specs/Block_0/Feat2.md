# Feat2 · Club directory and club page (Profile-1)

**Block:** B0 · **Backlog ID:** Profile-1 · **Labels:** `block-0`, `club-profile`

## Goal

The first vertical slice, from entity through migration, seed and API to Angular: a public directory of clubs and a page for each club. It also proves that club data survives a teardown and restore, and it gives the smoke test a user journey that needs no sign-in.

## Scope

- `Club` entity with these fields: name, city, description, history, contact details (address, email, phone, website) and weekly opening hours.
  - Opening hours: day of week, open time and close time. A day can have several time ranges; a day with no ranges is closed.
  - Primary key: a UUIDv7 GUID (`Guid.CreateVersion7()`; time-ordered, so the index doesn't fragment). URLs use it as is (readable URLs: Profile-4, later).
- The first EF Core migration, which creates the club tables.
  - In `staging`: a migration bundle (`dotnet ef migrations bundle`), built once in CI and run by the CD workflow before the new revision goes live. The workflow signs in to PostgreSQL with Entra authentication (OIDC) and opens a temporary firewall rule for the runner's IP. A failed bundle stops the deploy.
  - Locally (Docker Compose only): `Migrate()` at startup, for convenience.
- Seed data: at least 2 fictional clubs with every field filled, and fixed IDs (stable across restores and for the smoke tests).
- Read-only public API:
  - `GET /api/clubs`: a list of `{ id, name, city }`, sorted by name.
  - `GET /api/clubs/{id}`: the full club profile.
- Angular routes:
  - `/clubs`: the directory. Each entry links to its club page.
  - `/clubs/:id`: the club page with description, history, opening hours and contact details.
- A smoke-test journey that extends the smoke step from [Feat1](Feat1.md), written with Playwright (`@playwright/test`, TypeScript, Chromium only). It runs after Feat1's readiness poll and holds both:
  - API checks with Playwright's HTTP client: they show whether the API is at fault.
  - A browser journey: shows whether the UI is at fault.
  - Record the choice of Playwright (a new tool) in an ADR.

## Acceptance criteria

- [ ] Applying the migration to an empty database creates the schema without errors.
- [ ] In `staging`, the CD workflow applies the migration bundle before the new revision is deployed; running it again changes nothing.
- [ ] The API's database user can read and write data but not change the schema.
- [ ] The seed script fills an empty database with the synthetic clubs. Running it again creates no duplicates.
- [ ] `GET /api/clubs` returns every seeded club, sorted by name.
- [ ] `GET /api/clubs/{id}` returns the full profile, or `404` for an unknown ID.
- [ ] The API returns DTOs only. EF entities are never serialized.
- [ ] Without signing in, a visitor can open `/clubs`, select a club and see all of its profile fields. Opening hours appear in order from Monday to Sunday, with closed days marked.
- [ ] An unknown club ID in the UI shows a "club not found" message, not an error page.
- [ ] Opening `/clubs/:id` by direct link or browser reload loads the club page (SPA fallback, [Feat1](Feat1.md)).
- [ ] **Restore:** after a teardown (dump), a redeploy and a restore, the API returns the same clubs with identical data.
- [ ] **Smoke journey (Playwright):** after deploy, the pipeline fails unless:
  - API: `GET /api/clubs` returns at least 1 club, `GET /api/clubs/{id}` returns `200` for a seeded club and `404` for an unknown ID.
  - Browser: Chromium opens `/clubs`, clicks a seeded club and sees its name and opening hours.
  - On failure, the Playwright trace is kept as a workflow artifact.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke journey passed.
- [ ] Tests: unit tests for the opening-hours model (ordering, closed days, several ranges per day), and integration tests for both endpoints, including the `404`.
- [ ] Teardown → redeploy → restore done once by hand, with the result noted in the learning log.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: the `Club` entity and the opening-hours model.
2. Data: the EF Core `DbContext`, configuration and first migration.
3. CI/CD: build the migration bundle; run it in the CD workflow (Entra sign-in, temporary firewall rule).
4. Seed script: synthetic clubs with fixed IDs, idempotent.
5. API: the two read endpoints and their DTOs.
6. Angular: the directory page and the club page.
7. CD: the Playwright smoke journey (API checks + browser journey); ADR for Playwright.
8. Verify teardown → redeploy → restore with club data.

## Depends on

- The B0 walking skeleton, CI, Bicep and the OIDC CD workflow.
- The seed and teardown scripts (PostgreSQL dump and restore), which are B0 setup tasks.
- [Feat1](Feat1.md) for the smoke-test step.

## Non-goals

- Tenancy, query filters and club-scoped authorization. These arrive in B1 (Tenancy-1, Tenancy-4), where `Club` becomes the tenant root.
- Officials on the club page (Profile-2) and photos (Profile-3).
- Admin screens or write endpoints for clubs (out of the MVP; the seed script replaces them).
- Holiday or exception opening hours, and lane opening hours (Booking-1).
- Search, filtering and paging in the directory.
- Readable club URLs with a slug (Profile-4).
- Playwright on pull requests against Docker Compose (later).
