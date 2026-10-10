# Feat13 · Stock in and out (Inventory-4)

**Block:** B1 · **Backlog ID:** Inventory-4 · **Labels:** `block-1`, `inventory`

## Goal

Range officers record ammunition deliveries and counter sales. Concurrent sales never oversell. This Feat teaches optimistic concurrency with PostgreSQL's `xmin` and retries (the Optimistic Offline Lock pattern).

## Scope

- Endpoints (`RangeOfficer`), both returning the new stock:
  - `POST /api/clubs/{clubId}/ammunition/{id}/deliveries` `{ quantity }`
  - `POST /api/clubs/{clubId}/ammunition/{id}/sales` `{ quantity }`
- Domain: `Ammunition.Receive(quantity)` and `Ammunition.Sell(quantity)`.
  - The quantity must be > 0.
  - Insufficient stock → `409` with problem type `insufficient-stock`.
- Concurrency:
  - `xmin` is mapped as the concurrency token.
  - On `DbUpdateConcurrencyException`: reload, check the rule again, retry up to 3 times. After that → `409 concurrency-conflict`.
  - `CHECK (stock >= 0)` is the database backstop.
- ADR: optimistic concurrency (`xmin`) + retry, compared with an atomic `UPDATE … SET stock = stock - @q WHERE stock >= @q` + `CHECK`.
- Angular `/clubs/:id/counter` (range officers and admins): the ammunition list, with delivery and sale actions.

## Acceptance criteria

- [ ] A sale lowers the stock and a delivery raises it, by the given quantity.
- [ ] A sale larger than the stock → `409 insufficient-stock`; the stock is unchanged.
- [ ] 10 parallel 1-unit sales against a stock of 5: exactly 5 succeed, and the stock ends at 0, never below (Testcontainers).
- [ ] A stale update without the retry raises a concurrency conflict, which shows that the `xmin` token works.
- [ ] A member who isn't a range officer or admin → `403`.
- [ ] Ammunition from another club → `404`.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: unit tests for `Receive` and `Sell`; integration tests for the parallel sales, the stale update and the retry limit; an entry in the isolation suite.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: `Receive` and `Sell`.
2. Data (core): the `xmin` concurrency token and the `CHECK`.
3. API (core): the endpoints with the retry.
4. Tests (core): parallel sales, stale update, retry limit.
5. Angular: the counter page.
6. ADR: optimistic concurrency vs an atomic update.

## Depends on

- [Feat12](Feat12.md).

## Non-goals

- Sale prices and totals ([Feat17](Feat17.md)).
- Low-stock flag and inventory value ([Feat18](Feat18.md)).
- Stock movement history, purchase orders, stock for firearms.
