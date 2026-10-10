# Feat18 · Inventory overview (EQ-5)

**Block:** B1 · **Backlog ID:** EQ-5 · **Labels:** `block-1`, `equipment`, `stretch`

## Goal

Range officers see the ammunition stock, its value at cost, and which items are running low.

## Scope

- `GET /api/clubs/{clubId}/inventory` (`RangeOfficer`). Per ammunition item:
  - product, caliber, stock;
  - cost price and value at cost, as `Money` ([Feat17](Feat17.md));
  - a low-stock flag.
  - The response also has the total value.
- Low-stock threshold per item: an additive column, seeded. An item is low when stock ≤ threshold.
- One no-tracking projection query.
- Angular `/clubs/:id/inventory` (range officers and admins).

## Acceptance criteria

- [ ] Each item shows stock, cost price and value at cost = stock × cost price.
- [ ] Items at or below their threshold are flagged.
- [ ] The total value equals the sum of the item values.
- [ ] After a sale ([Feat13](Feat13.md)), the overview shows the new stock.
- [ ] A member who isn't a range officer or admin → `403`. Another club → `403`.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: an integration test for the values, the flag and the total; an entry in the isolation suite.
- [ ] Learning-log entry written.

## Sub-issues

1. Data: low-stock threshold column and seed.
2. API: the inventory projection.
3. Angular: the inventory page.

## Depends on

- [Feat13](Feat13.md), [Feat17](Feat17.md).

## Non-goals

- Alerts or notifications for low stock.
- Inventory of club firearms.
