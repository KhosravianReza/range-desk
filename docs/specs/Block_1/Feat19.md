# Feat19 · Join a waitlist (LN-6, part 1)

**Block:** B1 · **Backlog ID:** LN-6 · **Labels:** `block-1`, `bookings`, `stretch`

## Goal

A member joins the waitlist for booked slots. This Feat builds the waitlist model that the roadmap places in B1. Promotion on cancel follows in B4.

## Scope

- `WaitlistEntry` (club-scoped) has: lane, person, period, creation time, status (`Waiting`, `Left`).
  - The period follows the booking rules: 1–2 slots on the 30-min grid, `[)`, with the same `CHECK`s as [Feat6](Feat6.md).
  - A partial unique index allows one `Waiting` entry per person, lane and period.
- `POST /api/clubs/{clubId}/waitlist` `{ laneId, start, slots }` (`ClubMember`) → `201`.
  - Allowed only if an active booking overlaps the period. If the period is free → `409` with problem type `slot-free` ("book it instead").
- `DELETE /api/clubs/{clubId}/waitlist/{id}` → `204`, own entries only (sets `Left`).
- Line order: by creation time (first come, first served).
- `GET /api/me/waitlist` lists my `Waiting` entries across clubs. It's a person-scoped query on the allow-list ([Feat4](Feat4.md)).
- Angular:
  - The day view ([Feat7](Feat7.md)) offers "Join waitlist" on booked slots that aren't the member's own.
  - `/home` ([Feat11](Feat11.md)) lists the member's waitlist entries, each with a "Leave" action.

## Acceptance criteria

- [ ] Joining for a booked slot → `201`; joining again for the same period → `409`.
- [ ] Joining for a free slot → `409 slot-free`.
- [ ] Leaving → `204`. Leaving another person's entry → `403`.
- [ ] `/home` shows my entries from all clubs and no one else's.
- [ ] An entry for another club's lane → `404`.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: unit tests for the join rules; integration tests for join, duplicate, free slot, leave and isolation.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: `WaitlistEntry` and the join rules.
2. Data: table, `CHECK`s, partial unique index.
3. API: join, leave, my entries.
4. Angular: join from the day view; entries on `/home`.

## Depends on

- [Feat7](Feat7.md), [Feat11](Feat11.md).

## Non-goals

- Promotion on cancel, the LN-9 limit check during promotion, and the Event Grid custom event (LN-6, B4).
- Waitlist notifications (NT-1, B4).
