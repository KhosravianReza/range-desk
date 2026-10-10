# Feat10 · Cancel a booking (Booking-6)

**Block:** B1 · **Backlog ID:** Booking-6 · **Labels:** `block-1`, `bookings`

## Goal

Members cancel their own bookings; range officers and admins cancel any booking in their club. The decision needs the booking itself, which makes this resource-based authorization.

## Scope

- `POST /api/clubs/{clubId}/bookings/{id}/cancel` → `204`.
  - Resource-based authorization: `IAuthorizationService.AuthorizeAsync(user, booking, BookingOperations.Cancel)`.
  - The handler allows the booking's shooter or booker, or anyone with `RangeOfficer` or `Admin` in the booking's club.
  - Already cancelled → `204` (idempotent). Booking already started → `409` with problem type `booking-started`.
  - Another member's booking → `403`. A booking from another club → `404`.
- Cancelling sets the status to `Cancelled` and keeps the row. The slot is free again ([Feat6](Feat6.md)), and the slots no longer count toward the daily limit ([Feat9](Feat9.md)).
- Day view ([Feat7](Feat7.md)):
  - A cancel action on own bookings.
  - Range officers and admins see the shooter's display name on booked slots and can cancel any booking. The API includes the name only for them.

## Acceptance criteria

- [ ] A member cancels their own booking → `204`; the same slot can be booked again.
- [ ] A member cancelling another member's booking → `403`; the booking is unchanged.
- [ ] A range officer or admin of the club cancels any of its bookings → `204`.
- [ ] A range officer of club A cancelling a club B booking → `403` through B's route and `404` through A's route.
- [ ] Cancelling twice → `204` both times. Cancelling a booking that has started → `409`.
- [ ] After a cancel, the shooter can book up to the daily limit again.
- [ ] Members never see other shooters' names in the day view.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: unit tests for `Booking.Cancel` and the authorization handler; integration tests for the role and ownership matrix; an entry in the isolation suite.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: `Booking.Cancel`.
2. API: the resource-based authorization handler and the cancel endpoint; shooter names for RO/admin in the availability response.
3. Angular: cancel in the day view; shooter names for RO/admin.

## Depends on

- [Feat6](Feat6.md), [Feat7](Feat7.md), [Feat9](Feat9.md).

## Non-goals

- Waitlist promotion on cancel (Booking-8, B4).
- Cancellation notifications (Notify-1, B4).
- Cancellation reasons or deadlines.
