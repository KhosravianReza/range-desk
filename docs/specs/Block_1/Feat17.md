# Feat17 · Prices and booking total (Inventory-6)

**Block:** B1 · **Backlog ID:** Inventory-6 · **Labels:** `block-1`, `equipment`, `stretch`

## Goal

Each club has member and guest prices for lane slots and items. A booking shows its total, which is paid on site. The Feat teaches the Strategy pattern and a `Money` value object, both covered by unit tests.

## Scope

- `Money` value object (Domain):
  - An amount and a currency (EUR only for now). Immutable.
  - Addition, multiplication by a quantity, and rounding to 2 decimals (away from zero).
  - Mixing currencies throws.
  - Mapped onto the existing `numeric` columns. [Feat12](Feat12.md)'s cost price moves to `Money` without a schema change.
- Club price list (club-scoped, seeded), each entry with a member price and a guest price:
  - lane slot price per lane type;
  - rental price per club-firearm category, per booking;
  - ammunition price per unit.
- Strategy: `IPricingStrategy` with `MemberPricing` and `GuestPricing`.
  - A resolver picks the strategy by whether the shooter is a member of the booking's club.
  - Bookings always use member pricing in the MVP, since guests book only through RangeOps-3 or RangeOps-4 (optional). The guest strategy is unit-tested and used at the counter.
- Booking total = slots × slot price + rentals ([Feat16](Feat16.md)).
  - Stored on the booking at creation, as a price snapshot; later price changes don't alter it.
  - Additive nullable column; older bookings show no total.
- Counter sale ([Feat13](Feat13.md)): the request takes `customer: member | guest` and returns the line total.
- The total appears in the booking response, on `/home` ([Feat11](Feat11.md)) and in the booking dialog after success.

## Acceptance criteria

- [ ] A 2-slot booking with one rented firearm shows 2 × the slot price + the rental price, at member prices.
- [ ] Changing a price afterwards doesn't change existing booking totals.
- [ ] A counter sale for a guest uses the guest unit price.
- [ ] Adding EUR to another currency throws (unit test).
- [ ] Bookings made before this Feat still load, with no total.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: unit tests for `Money` (arithmetic, rounding, currency mismatch) and both strategies; integration tests for the booking total and the counter-sale total.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: the `Money` value object.
2. Domain: `IPricingStrategy`, the two strategies, the resolver.
3. Data: price list, seed, total on booking (additive); `Money` mapping.
4. API: total on booking; line total on counter sale.
5. Angular: totals in the booking dialog, on `/home` and at the counter.

## Depends on

- [Feat11](Feat11.md), [Feat13](Feat13.md), [Feat16](Feat16.md).

## Non-goals

- Payments (out of the MVP; paid on site).
- Guest bookings (RangeOps-3, RangeOps-4, optional).
- Discounts, VAT, other currencies.
