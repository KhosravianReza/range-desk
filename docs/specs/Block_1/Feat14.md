# Feat14 · Own firearms on a booking (OP-1)

**Block:** B1 · **Backlog ID:** OP-1 · **Labels:** `block-1`, `range-ops`

## Goal

A person registers their own firearms once and declares them on a booking. The booking keeps a snapshot as the club's record. The Feat teaches person-scoped vs club-scoped data, and snapshots vs references.

## Scope

- `PersonFirearm` (person-scoped, not club-scoped): description, category, calibers (at least one).
  - `GET`, `POST`, `PUT` and `DELETE` on `/api/me/firearms`. Only the owner can see or change them; another person's firearm ID → `404`.
- The booking request ([Feat6](Feat6.md)) takes optional `declaredFirearms: [{ personFirearmId, caliberId }]`. The caliber must be one of the firearm's calibers.
- `BookingFirearm` (club-scoped, part of the `Booking` aggregate) is a snapshot.
  - It copies the description, category, caliber name, the caliber's muzzle energy and the source (`Own`).
  - It keeps a nullable reference to the original firearm (`ON DELETE SET NULL`).
  - Editing or deleting the own firearm later never changes the snapshot.
- `GET /api/clubs/{clubId}/bookings/{id}` returns the booking with its declared firearms. Allowed for the shooter, the booker, and the club's range officers and admins, through [Feat10](Feat10.md)'s handler with a `Read` operation.
- Additive migration: existing bookings have no declared firearms.
- Angular:
  - "My firearms" page at `/me/firearms`.
  - A firearm and caliber picker in the booking dialog.

## Acceptance criteria

- [ ] A person adds, edits and deletes their own firearms. Another person's firearm ID → `404`.
- [ ] A booking with declared firearms stores one snapshot per firearm.
- [ ] Editing or deleting the own firearm afterwards leaves the booking's snapshot unchanged.
- [ ] A caliber that the firearm doesn't have → `400`. Another person's firearm ID in the request → `404`, and no booking is created.
- [ ] A range officer of the club sees the declared firearms on the booking; another member gets `403`.
- [ ] Bookings without declared firearms still work.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: unit tests for the snapshot creation; integration tests for ownership, snapshot stability and booking read access.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: `PersonFirearm`; `BookingFirearm` snapshot in the `Booking` aggregate.
2. Data: tables and migration (additive).
3. API: `/api/me/firearms`; declared firearms on booking; booking detail.
4. Angular: the my-firearms page and the picker in the booking dialog.

## Depends on

- [Feat3](Feat3.md), [Feat6](Feat6.md), [Feat10](Feat10.md).

## Non-goals

- Checking firearms against the lane's spectrum ([Feat15](Feat15.md)).
- Rented club firearms ([Feat16](Feat16.md)).
- RO check-in and the range register (OP-2, optional).
- Ownership or permit documents.
