# Feat11 · Home: my bookings across clubs (CL-5)

**Block:** B1 · **Backlog ID:** CL-5 · **Labels:** `block-1`, `clubs`

## Goal

After signing in, a person sees their upcoming bookings from all of their clubs. This is a deliberate cross-club read: it bypasses the tenant filter and limits the result to the person's own data, with a test to prove it.

## Scope

- `GET /api/me/bookings` returns upcoming active bookings in which the caller is the shooter or the booker, across all clubs.
  - Fields: `{ id, clubId, clubName, laneName, start, end }`, sorted by start.
  - Person-scoped query: `IgnoreQueryFilters()` plus a person predicate, on the tenancy ADR's allow-list ([Feat4](Feat4.md)).
  - No-tracking projection. The plan is checked with `EXPLAIN ANALYZE`. [Feat8](Feat8.md)'s shooter GiST index serves the shooter side; add a booker index only if the plan needs it.
- Angular `/home`: the landing page after sign-in.
  - Bookings grouped by club.
  - Each booking can be cancelled through [Feat10](Feat10.md).

## Acceptance criteria

- [ ] A person with bookings in clubs A and B sees both on `/home`.
- [ ] Another person's bookings never appear, including bookings of other members of the same clubs.
- [ ] Past and cancelled bookings don't appear.
- [ ] The isolation test fails when the person predicate is removed (checked once by hand).
- [ ] The query plan uses an index (`EXPLAIN ANALYZE` in the learning log).
- [ ] Without sign-in, `/api/me/bookings` → `401`.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: integration tests for own data across two clubs and for no foreign data; an entry in the isolation suite.
- [ ] Learning-log entry written.

## Sub-issues

1. API: `GET /api/me/bookings` (person-scoped projection).
2. Angular: `/home`.
3. Tests: cross-club own-data and foreign-data tests.

## Depends on

- [Feat8](Feat8.md), [Feat10](Feat10.md).

## Non-goals

- Announcements on the home page: they arrive with NT-3, which has no block yet.
- Waitlist entries on the home page ([Feat19](Feat19.md)).
- In-app notifications (NT-1, B4).
