# Feat6 · Book a lane (Booking-3)

**Block:** B1 · **Backlog ID:** Booking-3 · **Labels:** `block-1`, `bookings`

## Goal

A member books 1 or 2 consecutive 30-min slots of a lane (D3). PostgreSQL rejects overlapping bookings with an exclusion constraint, so a double booking is impossible, even under concurrency.

## Scope

- `Booking` (club-scoped) has: lane, shooter, booker, period, status (`Active`, `Cancelled`) and creation time.
  - The booking references its lane directly. Club-firearm rentals get their own table and constraint later ([Feat16](Feat16.md)); there is no shared bookable-resource table.
  - Period: `tstzrange`, half-open `[)`, stored in UTC.
  - Shooter and booker are separate columns. Both are the signed-in person until RangeOps-4 (optional) lets a member book for a guest. [Feat8](Feat8.md) keys on the shooter.
- Domain: `Booking.Create` checks the 30-min grid, a length of 1–2 slots, the lane's opening hours (club time zone, [Feat3](Feat3.md)), and that the start isn't in the past.
- Database, as raw SQL in the migration:
  - `btree_gist` extension, allow-listed in Bicep (`azure.extensions`).
  - `EXCLUDE USING gist (lane_id WITH =, period WITH &&) WHERE (status = 'Active')`.
  - `CHECK`s:
    - start on the grid: `extract(epoch from lower(period))::bigint % 1800 = 0`;
    - length 30 or 60 min;
    - bounds `[)`.
- `POST /api/clubs/{clubId}/bookings` `{ laneId, start, slots }` (`ClubMember`) → `201` with the booking.
  - `23P01` on the lane constraint → `409` with problem type `lane-slot-taken`. Infrastructure translates the database error, and the API maps it to ProblemDetails.
  - Grid, length, opening-hours or past-start violations → `400`.
  - A lane from another club → `404` ([Feat5](Feat5.md)).
- The booking UI comes with [Feat7](Feat7.md).

## Acceptance criteria

- [ ] Booking a free slot → `201`; the booking is `Active`.
- [ ] On a lane booked 10:00–11:00: booking 10:30–11:00 → `409`; the adjacent 11:00–11:30 → `201` (half-open range).
- [ ] Two concurrent requests for overlapping periods on one lane: exactly one `201` and one `409` (Testcontainers race test).
- [ ] A `Cancelled` booking doesn't block its slot. The integration test sets the status directly; cancelling arrives in [Feat10](Feat10.md).
- [ ] Inserting an off-grid or 90-min period directly in SQL fails on a `CHECK`: the database is the final guard.
- [ ] Outside the lane's opening hours or in the past → `400`; no row is written.
- [ ] Booking another club's lane → `404`; covered in the isolation suite.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the migration bundle applied the constraint; the smoke tests passed.
- [ ] Tests: unit tests for the `Booking.Create` rules; integration tests for overlap, adjacency, cancelled rows, the `CHECK`s and the race.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: `Booking`, the period and the slot rules.
2. Data (core): bookings table; exclusion constraint and `CHECK`s as raw SQL; `btree_gist`.
3. Bicep: allow-list `btree_gist`.
4. API: `POST` bookings; `23P01` → `409`.
5. Tests (core): overlap, adjacency and the race test.

## Depends on

- [Feat3](Feat3.md), [Feat5](Feat5.md).

## Non-goals

- Day view and booking UI ([Feat7](Feat7.md)).
- Overlaps per shooter ([Feat8](Feat8.md)); the daily limit ([Feat9](Feat9.md)); cancelling ([Feat10](Feat10.md)).
- Firearms on the booking ([Feat14](Feat14.md)); rentals ([Feat16](Feat16.md)); prices ([Feat17](Feat17.md)).
- Slot holds (Booking-7, B3); booking events and the outbox (B4).
