# Feat5 · Club route checks and isolation tests (Tenancy-4)

**Block:** B1 · **Backlog ID:** Tenancy-4 · **Labels:** `block-1`, `tenancy`

## Goal

Enforce tenant-isolation rules 1–3 at the API boundary and on writes. Prove them with the roadmap's four isolation tests.

## Scope

- Every club-scoped endpoint sits in one route group, `/api/clubs/{clubId}/…`, which requires `ClubMember` by default.
  - An endpoint can require a stricter policy, never a looser one. The public club endpoints from B0 stay outside the group.
- Status codes:
  - No membership in the route's club → `403`.
  - An ID from another club inside your own club's route → `404`. The filter hides the row, and its existence isn't revealed.
- Writes take the club from the tenant context (the verified membership), never from the request body. Request DTOs have no `clubId`.
- Save guard (EF Core `SaveChangesInterceptor`):
  - sets `ClubId` on new `IClubScoped` entities from the tenant context;
  - throws if a tracked entity's `ClubId` differs from the tenant or was changed.
- The four isolation tests: integration tests on Testcontainers with two seeded clubs, written by the owner.
  1. **Cross-club read:** a member of A reads B's lanes → `403`.
  2. **Changed ID:** a member of A requests B's lane through A's route → `404`.
  3. **Cross-club write:** an admin of A adds a member to B → `403`. An admin of A posts to A with B's ID in the body → the body is ignored, and the membership lands in A.
  4. **Member in one club, admin in another:** admin actions succeed in B and get `403` in A.
- Every later Feat adds its club-scoped endpoints to this suite, one test per resource.

## Acceptance criteria

- [ ] All four tests pass. Each one fails when its protection is removed (checked once by hand, noted in the learning log).
- [ ] A new endpoint in the club route group with no explicit policy still requires membership.
- [ ] Saving a club-scoped entity for a club other than the tenant throws, and nothing is written.
- [ ] Error bodies never contain another club's data.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: the four isolation tests; integration tests for the save guard and the route-group default.
- [ ] Learning-log entry written.

## Sub-issues

1. API: club route group with the `ClubMember` default.
2. Data (core): the save guard.
3. Tests (core): the four isolation tests.

## Depends on

- [Feat2](Feat2.md), [Feat4](Feat4.md).

## Non-goals

- Isolation rule 4 (B3, B4).
- Rules inside a club that depend on the resource, e.g. "own booking" ([Feat10](Feat10.md)).
