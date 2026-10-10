# Feat15 · Firearm must fit the lane (Booking-9)

**Block:** B1 · **Backlog ID:** Booking-9 · **Labels:** `block-1`, `booking`

## Goal

Every firearm declared on a booking must fit the lane's spectrum: category, caliber and maximum muzzle energy. The rule is built with the Specification pattern in the domain layer and covered by unit tests.

## Scope

- Domain: `ISpecification<T>` with `And`.
  - Rules: `CategoryAllowed`, `CaliberAllowed` and `MuzzleEnergyWithinLimit` (the caliber's nominal energy ≤ the lane's maximum).
  - The three are composed into `FirearmFitsLane`.
  - Pure domain code with no EF Core. A check returns the rules that failed.
- Booking creation ([Feat6](Feat6.md), [Feat14](Feat14.md)) applies `FirearmFitsLane` to every declared firearm.
  - Any failure → `422` with problem type `firearm-not-allowed`, listing each failing firearm and its failed rules. No booking is created.
- Angular: the booking dialog shows the reasons.

## Acceptance criteria

- [ ] A firearm whose category, caliber and energy all fit → booking `201`.
- [ ] A wrong category, a caliber not allowed, or energy over the lane's limit each → `422`, naming the failed rule.
- [ ] A firearm failing two rules lists both.
- [ ] With two declared firearms, one failing, no booking is created.
- [ ] The booking dialog shows which firearm failed and why.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: unit tests (written by the owner) for each rule and their composition; an integration test for the `422`.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: `ISpecification<T>`, the three rules, `FirearmFitsLane`.
2. Application: apply the specification on booking; `422`.
3. Angular: show the reasons in the booking dialog.

## Depends on

- [Feat3](Feat3.md), [Feat14](Feat14.md).

## Non-goals

- Ammunition must fit the firearm (Inventory-3, optional).
- Guest eligibility checks (RangeOps-3, optional).
- Rented club firearms: [Feat16](Feat16.md) applies the same specification.
