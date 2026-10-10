# Feat4 · Clubs as tenants (Tenancy-1)

**Block:** B1 · **Backlog ID:** Tenancy-1 · **Labels:** `block-1`, `clubs`

## Goal

`Club` becomes the tenant root. Club-scoped data carries the club ID, and EF Core global query filters keep every query inside the current club. A forgotten `where` can't leak another club's data.

## Scope

- One database with a shared schema. Every club-scoped entity implements `IClubScoped` (`ClubId`).
  - Not filtered: `Club` (public), `Person` and `Caliber` (global), `Membership` (the source of authority, [Feat2](Feat2.md)).
- `ITenantContext` (Application port) holds the current club ID, or none.
  - Api adapter: set from the route's `{clubId}`, only after the `ClubMember` policy has succeeded for that club.
  - With no tenant set, filtered queries return no rows. They fail closed and never return every club's data.
- `DbContext`: a global query filter on every `IClubScoped` entity, applied by convention in `OnModelCreating` (no per-entity copies).
- `IgnoreQueryFilters()` is allowed only in the person-scoped read queries listed in the tenancy ADR. A CI check fails the build if it appears anywhere else.
- No `AddDbContextPool`: the filter reads per-request state. The ADR records why.
- First filtered reads, both `ClubMember`:
  - `GET /api/clubs/{clubId}/lanes`
  - `GET /api/clubs/{clubId}/lanes/{laneId}`, returning a DTO with spectrum and opening hours.
- Angular: a lane list on the club page, for members only.
- ADR: tenancy. Compares shared schema + club ID with schema-per-tenant and database-per-tenant; covers filters and fail-closed behaviour.

## Acceptance criteria

- [ ] A member of club A gets only club A's lanes from `/api/clubs/A/lanes`.
- [ ] `/api/clubs/A/lanes/{laneOfClubB}` → `404`.
- [ ] A query with no tenant context returns no club-scoped rows.
- [ ] A model test fails if any `IClubScoped` entity lacks the tenant filter.
- [ ] CI fails when `IgnoreQueryFilters()` appears outside the allow-listed files.
- [ ] Members see the lane list on the club page; visitors don't.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: integration tests (Testcontainers, two clubs) for filtered reads, cross-club IDs and the missing tenant; the model test for filter coverage.
- [ ] Learning-log entry written.

## Sub-issues

1. Application: `ITenantContext`; Api adapter from the route after the policy.
2. Data (core): `IClubScoped` convention and global query filter, fail-closed.
3. CI/CD: check for `IgnoreQueryFilters()` outside the allow-list.
4. API: lane list and detail.
5. Angular: lanes on the club page.
6. ADR: tenancy.

## Depends on

- [Feat2](Feat2.md) (`ClubMember` policy), [Feat3](Feat3.md) (lanes).

## Non-goals

- Club-scoped writes, the route-group default and the four isolation tests ([Feat5](Feat5.md)).
- Self-service club onboarding (out of the MVP).
- Isolation rule 4: club ID in cache keys, messages and retrieval (B3, B4).
