# Feat9 · Daily slot limit (Booking-5)

**Block:** B1 · **Backlog ID:** Booking-5 · **Labels:** `block-1`, `booking`

## Goal

A shooter books at most 2 slots per lane per club-local day (D3). This rule spans rows, so an exclusion constraint can't express it. Concurrent bookings would race past it (write skew) unless the database serializes them.

## Scope

- Rule: the shooter's active slots on that lane on that club-local day, plus the new slots, must not exceed 2.
  - Another lane on the same day is allowed.
  - The day runs from midnight to midnight in the club's time zone ([Feat3](Feat3.md)), not in UTC.
- Concurrency: the booking transaction runs at `SERIALIZABLE`. PostgreSQL's serializable isolation detects the write skew.
  - On `40001` (serialization failure), the whole transaction is retried: read the count, check the rule, insert. The retry runs through EF Core's execution strategy, up to 3 times; after that → `409` with problem type `concurrency-conflict`.
  - Every booking write path uses this transaction scope. Feat16's rentals inherit it.
- Over the limit → `409` with problem type `daily-limit-reached`.
- ADR: the write-skew race and `SERIALIZABLE` + retry. Alternatives: a per-key advisory lock, locking the person row, and a counter row with a `CHECK`.

## Acceptance criteria

- [ ] With 1 slot booked on lane 1, booking 2 more slots there on the same day → `409`; booking 1 more → `201`.
- [ ] With 2 slots on lane 1, booking 2 slots on lane 2 the same day → `201`.
- [ ] Bookings on either side of club-local midnight count for different days.
- [ ] A shooter holds 1 slot; two parallel 1-slot requests for non-overlapping slots on the same lane and day: exactly one succeeds. Without the mechanism both succeed (shown once, noted in the learning log).
- [ ] Cancelled bookings don't count.
- [ ] A serialization failure is retried; the losing request gets `daily-limit-reached` when its retry finds the limit reached. Retries are logged with their count.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: unit tests for the limit rule; integration tests (Testcontainers) for the sequential cases, the day boundary and the race.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: the daily limit rule.
2. Data + API (core): the `SERIALIZABLE` booking transaction with retry.
3. Tests (core): sequential cases, day boundary, race.
4. ADR: write skew, `SERIALIZABLE` + retry vs the alternatives.

## Depends on

- [Feat6](Feat6.md).

## Non-goals

- RO duty roster (Booking-10, optional).
- A configurable limit per club.
