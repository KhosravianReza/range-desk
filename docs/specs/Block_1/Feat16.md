# Feat16 · Rent a club firearm with a booking (EQ-2a)

**Block:** B1 · **Backlog ID:** EQ-2a · **Labels:** `block-1`, `equipment`, `stretch`

## Goal

A member rents specific club firearms together with a lane booking, all or nothing. A firearm can't be rented twice for overlapping periods. This repeats [Feat6](Feat6.md)'s exclusion constraint for a second resource.

## Scope

- Rentals live in their own table, not in a shared bookable-resource table, so [Feat6](Feat6.md)'s bookings table stays unchanged:
  - `FirearmRental` (club-scoped, part of the `Booking` aggregate): booking, club firearm, plus the period and status copied from the booking. An exclusion constraint can't read another table, so they are copied.
  - `EXCLUDE USING gist (club_firearm_id WITH =, period WITH &&) WHERE (status = 'Active')`, as raw SQL.
  - Cancelling ([Feat10](Feat10.md)) sets the rentals' status in the same transaction as the booking's.
- The booking request takes optional `rentals: [{ clubFirearmId, caliberId }]`.
  - The booking and its rentals are saved in one transaction. Any constraint violation → `409` with problem type `firearm-taken`, and nothing is saved.
  - Rented firearms are checked by [Feat15](Feat15.md)'s specification and stored as `BookingFirearm` snapshots with source `Club` ([Feat14](Feat14.md)).
- `GET /api/clubs/{clubId}/firearms?from=&to=` adds a `free` flag per firearm for that period.
- Angular: a rental picker in the booking dialog, offering the firearms free for the chosen slots.

## Acceptance criteria

- [ ] A booking with a free club firearm → `201`, with the rental and its snapshot.
- [ ] Renting a firearm already rented for an overlapping period → `409 firearm-taken`. Neither the booking nor any rental is saved.
- [ ] Two concurrent bookings renting the same firearm for overlapping periods: exactly one succeeds.
- [ ] A rented firearm that doesn't fit the lane → `422` ([Feat15](Feat15.md)).
- [ ] After cancelling the booking, the firearm can be rented for that period again.
- [ ] A firearm from another club → `404`.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: integration tests for the overlap, all-or-nothing, the race, cancel and isolation.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: rentals in the `Booking` aggregate.
2. Data: rentals table and exclusion constraint (raw SQL).
3. API: rentals on booking; `409 firearm-taken`; the `free` flag.
4. Angular: rental picker.

## Depends on

- [Feat10](Feat10.md), [Feat12](Feat12.md), [Feat14](Feat14.md), [Feat15](Feat15.md).

## Non-goals

- Renting "any free unit" of a model (EQ-2b, optional).
- Rental prices ([Feat17](Feat17.md)).
- A shared bookable-resource table. Revisit only if EQ-2b or another resource type arrives.
