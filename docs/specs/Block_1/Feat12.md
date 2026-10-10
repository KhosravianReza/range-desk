# Feat12 · Equipment catalogue (Inventory-1)

**Block:** B1 · **Backlog ID:** Inventory-1 · **Labels:** `block-1`, `equipment`

## Goal

Model the club's firearms and ammunition, and seed them. This is the base for stock handling ([Feat13](Feat13.md)) and rentals ([Feat16](Feat16.md)). It teaches EF Core many-to-many.

## Scope

- `ClubFirearm` (club-scoped) has:
  - model name and serial number (synthetic);
  - category ([Feat3](Feat3.md));
  - calibers: many-to-many with `Caliber`, mapped with skip navigations.
- `Ammunition` (club-scoped) has:
  - product name and caliber;
  - stock in sale units (≥ 0);
  - cost price per unit (`numeric(10,2)`, EUR).
- Seed with fixed IDs for both clubs. At least one firearm has several calibers.
- Read endpoints:
  - `GET /api/clubs/{clubId}/firearms` (`ClubMember`).
  - `GET /api/clubs/{clubId}/ammunition` (`RangeOfficer`).

## Acceptance criteria

- [ ] A member of a club gets its firearms with their calibers; a member of another club gets `403`.
- [ ] A member who isn't a range officer or admin gets `403` from the ammunition list.
- [ ] A firearm with several calibers returns all of them.
- [ ] The migration is additive, and the seed runs again without creating duplicates.
- [ ] The catalogue survives teardown → redeploy → restore.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: integration tests for both lists (many-to-many loading, roles); entries in the isolation suite.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: `ClubFirearm`, `Ammunition`.
2. Data: many-to-many configuration, migration.
3. Seed: firearms and ammunition, idempotent.
4. API: the two read endpoints.

## Depends on

- [Feat3](Feat3.md) (`Caliber`, `FirearmCategory`), [Feat5](Feat5.md).

## Non-goals

- Catalogue admin screens (out of the MVP; the seed replaces them).
- Stock changes ([Feat13](Feat13.md)), rentals ([Feat16](Feat16.md)), the inventory overview ([Feat18](Feat18.md)).
- The `Money` value object ([Feat17](Feat17.md)).
