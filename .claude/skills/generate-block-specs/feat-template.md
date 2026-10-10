# Feat<y> · <Feature title> (<backlog ID>)

**Block:** B<x> · **Backlog ID:** <ID> · **Labels:** `block-<x>`, `<area>`[, `stretch`]

<!-- <area> = the backlog ID prefix in kebab case (Booking-3 → `booking`, RangeOps-1 → `range-ops`). `stretch` only for product-only Feats that may move to the next block. -->

## Goal

<1–3 sentences: what the feature delivers and why it matters in this block.>

## Scope

- <What is built: endpoints, entities, UI routes, infrastructure, pipeline steps.>
  - <Details, constraints and decisions that act here.>

## Acceptance criteria

- [ ] <Observable, testable outcome: status code, visible UI, pipeline pass or fail.>

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed through the pipeline; <the feature's smoke check> passed.
- [ ] Tests: <which unit and integration tests>.
- [ ] Learning-log entry written.

## Sub-issues

1. <Area>: <pull-request-sized task>.

## Depends on

- <Earlier Feats (linked), setup tasks, or "None".>

## Non-goals

- <What is deferred, and where it comes (block, backlog ID).>

<!-- Optional sections, only when needed:
## Decisions made
- <Decision that fits no section above.>

## Open questions
- <Only what the user explicitly left open.>
-->
