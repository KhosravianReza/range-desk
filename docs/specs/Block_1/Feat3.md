# Feat3 · Lanes (Booking-1)

**Block:** B1 · **Backlog ID:** Booking-1 · **Labels:** `block-1`, `booking`

## Goal

Model each lane with its firearm spectrum and opening hours, and seed them. Lanes are the first club-scoped entity: [Feat4](Feat4.md) builds and tests the tenant filter on them.

## Scope

- `Caliber`: global reference data, not club-scoped. Fields: name and nominal maximum muzzle energy (J). Seeded.
- `FirearmCategory`: `Handgun`, `LongGun`.
- `Lane` (club-scoped, `ClubId`) has:
  - name and type (e.g. 25 m pistol, 50 m rifle);
  - allowed categories and allowed calibers (many-to-many with `Caliber`);
  - maximum muzzle energy (J);
  - weekly opening hours, reusing B0's opening-hours model.
- `Club` gets `TimeZone` (IANA; seed value `Europe/Berlin`).
  - Opening hours are in club-local time; bookings ([Feat6](Feat6.md)) are stored in UTC.
  - Additive migration with a default value (expand only).
- Seed: 3–4 lanes per club with different spectra, fixed IDs.
- No API or UI here. Lanes are read through [Feat4](Feat4.md) (list, detail) and [Feat7](Feat7.md) (day view).

## Acceptance criteria

- [ ] The migration adds lanes, calibers and the club time zone to a database with B0 data, without losing data. The previous revision still runs against the migrated schema.
- [ ] The seed fills lanes for both clubs; running it again creates no duplicates.
- [ ] Lanes, spectra and opening hours survive teardown → redeploy → restore.
- [ ] A lane without at least one allowed category and caliber is rejected (domain invariant).

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: unit tests for the `Lane` invariants; an integration test (Testcontainers) applies all migrations and the seed to an empty database.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: `Caliber`, `FirearmCategory`, `Lane`.
2. Data: configuration, migration, `Club.TimeZone`.
3. Seed: calibers and lanes, idempotent.

## Depends on

- B0 [Feat2](../Block_0/Feat2.md): `Club`, the opening-hours model, the migration bundle.
- Setup task: Testcontainers PostgreSQL fixture.

## Non-goals

- Lane admin screens (out of the MVP).
- Lane prices ([Feat17](Feat17.md)).
- Checking firearms against the spectrum ([Feat15](Feat15.md)).
- Holiday or exception hours.
