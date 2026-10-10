# Feat8 · No overlapping bookings per shooter (Booking-4)

**Block:** B1 · **Backlog ID:** Booking-4 · **Labels:** `block-1`, `booking`

## Goal

A shooter can't hold overlapping bookings on any lane in any club. A second exclusion constraint, keyed on the shooter rather than the booker. This is the block's main concept built once without AI (Roadmap §2).

## Scope

- On the bookings table, as raw SQL in a new migration: `EXCLUDE USING gist (shooter_id WITH =, period WITH &&) WHERE (status = 'Active')`.
  - It spans clubs: the constraint has no club column, so it works across the tenants that the query filter keeps apart.
  - Existing overlaps would make the migration fail. The staging seed has none; this is checked before deploy.
- `23P01` on this constraint → `409` with problem type `shooter-overlap` ("You already have a booking at this time"). The response says nothing about the other booking's club or lane.
- Its GiST index also serves "my bookings" in [Feat11](Feat11.md).

## Acceptance criteria

- [ ] A shooter booked 10:00–11:00 on lane 1 books 10:30–11:00 on lane 2 → `409 shooter-overlap`.
- [ ] The same with a lane in club B → `409`. The response reveals nothing about the club A booking.
- [ ] Back-to-back at 11:00 on another lane → `201`.
- [ ] Two concurrent overlapping requests by the same shooter on two lanes: exactly one succeeds.
- [ ] Cancelled bookings don't block.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Constraint and tests built without AI; noted in the learning log.
- [ ] Tests: integration tests across lanes, across clubs, back-to-back, cancelled, and the race.
- [ ] Learning-log entry written.

## Sub-issues

1. Data (core, without AI): the shooter exclusion constraint.
2. API: map the constraint to `409 shooter-overlap`.
3. Tests (core, without AI): the cross-lane, cross-club and race tests.

## Depends on

- [Feat6](Feat6.md).

## Non-goals

- Booking for another shooter, such as a guest (RangeOps-4, optional).
