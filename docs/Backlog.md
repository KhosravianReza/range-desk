# Backlog 1 · MVP feature candidates

As of 6 Oct 2026. Candidates for the specs in `docs/specs/`. Product scope: Roadmap §4 + owner's ideas. Learning scope: Roadmap §5–§6.
Tenant-isolation rules (§4) apply to every feature. RO = range officer. Decisions D1–D4: see the end.

**Legend**

- **Learning:** ●●● main concept of a block · ●● adds depth · ● repeats a concept, or product value only
- **≡ X:** teaches the same as X; keep it only for product value or practice. ✔/○ is the suggested pick.
- **MVP:** ✔ in (product or roadmap needs it) · ○ optional or alternative
- Rows with ● and ✔ are product-only: cheap, but per Rule 2 they come after the block's concept.

## 1. Club profile (public)

| ID | Feature | Teaches (block) | Learning | MVP |
|---|---|---|---|---|
| Profile-1 | Club directory and club page: description, history, opening hours, contact | B0 vertical slice (entity → migration → seed → API → Angular); proves restore; smoke-test journey without sign-in | ● | ✔ |
| Profile-2 | Officials (board, ROs, trainers) on the club page, taken from the roles; opt-in | Reuses Tenancy-2 | ● | ✔ |
| Profile-3 | Photos of the club and officials | Blob upload | ● ≡ Rules-1 | ○ |
| Profile-4 | Readable club URL `/clubs/{id}/{slug}`; a wrong or old slug redirects to the current URL | Slug from the name; the ID decides, so renames are safe | ● | ○ |

## 2. Clubs, people, roles

| ID | Feature | Teaches (block) | Learning | MVP |
|---|---|---|---|---|
| Tenancy-1 | Clubs as tenants (seeded; no self-service onboarding) | Shared schema + club ID; EF Core global query filters (B1) | ●●● | ✔ |
| Tenancy-2 | Roles per club (member, RO, trainer, admin); one person in several clubs | Membership table, not token claims; policy-based authorization (B1) | ●●● | ✔ |
| Tenancy-3 | Sign-in; admin adds a member by email; first sign-in links the account (verified emails only) | External ID, OIDC + PKCE; token identity → person (B1) | ●●● | ✔ |
| Tenancy-4 | Club ID in the route, checked against the membership; writes take the club from the membership | Isolation rules 1–3; the four isolation tests (B1) | ●●● | ✔ |
| Tenancy-5 | Home: my bookings and announcements from all my clubs | Deliberate cross-club read, own data only, tested (B1) | ●● | ✔ |

## 3. Lanes and bookings

| ID | Feature | Teaches (block) | Learning | MVP |
|---|---|---|---|---|
| Booking-1 | Lanes (seeded): type, allowed firearm spectrum (category, calibers, max muzzle energy), opening hours | Modelling only | ● | ✔ |
| Booking-2 | Availability day view: lanes × 30-min slots (free, held, booked) | No-tracking projection, GiST index, `EXPLAIN ANALYZE` (B1); Redis Cache-Aside + invalidation (B3) | ●● | ✔ |
| Booking-3 | Book 1 or 2 consecutive slots of a lane (D3); overlaps rejected by the database | Exclusion constraint on a half-open range (`[)`), ignoring cancelled bookings; grid and length `CHECK`s; raw SQL in the migration, `btree_gist` allow-listed in Bicep; `23P01` → 409; Testcontainers race test (B1) | ●●● | ✔ |
| Booking-4 | A shooter can't hold overlapping bookings (any lane, any club); key = shooter, not booker (RangeOps-4) | Second exclusion constraint on another key; build it without AI (Roadmap §2: once per block) | ● ≡ Booking-3 | ✔ |
| Booking-5 | Limit: max 2 slots per person, lane and day (D3) | Cross-row rule the exclusion constraint can't express: concurrent bookings race (write skew) → `SERIALIZABLE` + retry, or a lock per person/lane/day; ADR (B1) | ●● | ✔ |
| Booking-6 | Cancel: members their own bookings, RO/admin any in their club | Resource-based authorization (B1) | ●● | ✔ |
| Booking-7 | Slot held for 5 min while a booking is completed | Redis TTL; the DB constraint stays the final guard (B3) | ●● | ✔ |
| Booking-8 | Waitlist: a cancellation books the first in line who is under the Booking-5 limit, and notifies them | Event Grid custom event; tolerates duplicates and any order (B1 model, B4) | ●●● | ✔ |
| Booking-9 | Each declared firearm (own or rented) must fit the lane's spectrum | Specification pattern in the domain layer; unit tests (B1) | ●● | ✔ |
| Booking-10 | *Stretch:* RO duty roster; bookings only while an RO is on duty | Same race as Booking-5 (write skew) | ● ≡ Booking-5 | ○ |

## 4. Equipment and inventory

| ID | Feature | Teaches (block) | Learning | MVP |
|---|---|---|---|---|
| Inventory-1 | Catalogue (seeded): club firearms (serial no., category, calibers) and ammunition (caliber, stock, cost price) | EF Core many-to-many (B1) | ● | ✔ |
| Inventory-2a | Rent a specific club firearm with a lane booking, all or nothing | Booking-3's constraint; near free if lanes and firearms share one bookable-resource table | ● ≡ Booking-3 | ✔ |
| Inventory-2b | Rent "any free unit" of a model (e.g. 3 × .22 rifle) | Assign a free unit; retry on constraint violation | ●● | ○ |
| Inventory-3 | Ammunition must fit the firearm (caliber) | Booking-9's Specification | ● ≡ Booking-9 | ○ |
| Inventory-4 | Stock in (delivery) and out (sale at the counter); concurrent sales never oversell | Optimistic concurrency (`xmin`) + retry (B1); ADR: vs atomic `UPDATE` + `CHECK` | ●●● | ✔ |
| Inventory-5 | Inventory overview: stock, value at cost, low-stock flag | Projection query | ● ≡ Booking-2 | ✔ |
| Inventory-6 | Prices per lane slot and item, member vs guest; booking shows the total; paid on site | Strategy pattern, Money value object; unit tests | ● | ✔ |

## 5. Range operations and guests

| ID | Feature | Teaches (block) | Learning | MVP |
|---|---|---|---|---|
| RangeOps-1 | Own firearms: registered once per person; declared on a booking and kept there as a snapshot (the club's record) | Person-scoped vs club-scoped data; snapshot vs reference (B1) | ●● | ✔ |
| RangeOps-2 | RO check-in: attendance, firearms used, guest documents → append-only range register | Booking state machine; append-only enforced by the DB | ● ≡ Booking-3 | ○ |
| RangeOps-3 | Guest self-booking: a signed-in non-member declares eligibility (firearms permit, hunting licence, police/armed forces) and books at guest prices; RO checks the document | Authorization without membership; eligibility as Specification (≡ Booking-9); on/off per club via Platform-2 | ●● | ○ |
| RangeOps-4 | Member books for an accompanying guest at guest prices | Pricing only | ● ≡ Inventory-6 | ○ |

## 6. Shooting logbook

| ID | Feature | Teaches (block) | Learning | MVP |
|---|---|---|---|---|
| Logbook-1 | Log a session: date, club, discipline, firearm category, result (fields vary by discipline), notes | Cosmos DB: partition key = member, club ID on every entry, indexing policy, RU, consistency (B3) | ●●● | ✔ |
| Logbook-2 | RO confirms entries of their club, never their own; confirmed entries are locked | Resource-based authorization; ETag (`If-Match`) concurrency (B1, B3) | ●● | ✔ |
| Logbook-3 | RO queue: pending entries of the club | Access pattern ≠ partition key: cross-partition query vs change-feed view (Materialized View); compare RU (B3) | ●●● | ✔ |
| Logbook-4 | Confirmed sessions in the last 12 months, per category (handgun, long gun) | Change-feed Function → monthly counts; 12-month sum at read time (B3) | ●●● | ✔ |
| Logbook-5 | Search my notes by meaning | Cosmos DB vector index; re-embedding on edit via change feed (B3) | ●● | ✔ |
| Logbook-6 | A completed booking pre-fills a draft entry | PostgreSQL → Cosmos DB via an outbox event | ● ≡ Notify-1 | ○ |
| Logbook-7 | Member shares the logbook with a club trainer, who can comment | Grant-based resource authorization; gives the trainer role a purpose | ● ≡ Logbook-2 | ○ |

## 7. Rules assistant (RAG)

| ID | Feature | Teaches (block) | Learning | MVP |
|---|---|---|---|---|
| Rules-1 | Admin uploads a new version of the club rule book (D2); ingestion runs automatically | Blob → Event Grid → Python worker: chunk per rule number, embed → pgvector (HNSW; metadata: club, version, part, rule no.) (B3, B4) | ●●● | ✔ |
| Rules-2 | Ask in English → answer in English citing version and rule number; abstains if not covered (D4) | Cross-lingual retrieval; metadata + club filter (isolation rule 4), tested with a second club's rule book (B3) | ●●● | ✔ |
| Rules-3 | Evaluation set: 20 English questions (~5 unanswerable, ambiguous or conflicting), scored; latency and tokens logged | RAG evaluation incl. cross-lingual quality; expected answers stored as rule numbers (B3) | ●●● | ✔ |
| Rules-4 | Semantic cache keyed by club + rule-book version | Redis vector index; only after Rules-3 has a baseline (B3) | ●● | ✔ |
| Rules-5 | Second, global source (fictional federation rules, no club ID) | Club-or-global filter; conflicts between sources for Rules-3 | ●● | ○ |

## 8. Notifications and announcements

| ID | Feature | Teaches (block) | Learning | MVP |
|---|---|---|---|---|
| Notify-1 | In-app notifications: booking confirmed, cancelled, promoted from the waitlist | Transactional Outbox → Service Bus topic → Idempotent Consumer; DLQ; KEDA (Competing Consumers); four failure tests (B4); channel behind a port (D1) | ●●● | ✔ |
| Notify-2 | Reminder 24 h before a booking | Timer Function (B4) | ●● | ✔ |
| Notify-3 | Announcement board per club: text, valid from/to, for members or public | Tenant-scoped CRUD | ● | ✔ |
| Notify-4 | Pin an announcement as a home-page banner | Notify-3 + a cache (≡ Booking-2) | ● ≡ Notify-3 | ○ |
| Notify-5 | Email subscription to a club's announcements; signed unsubscribe link; needs Notify-6 | Topic fan-out (Publish-Subscribe); per-recipient idempotency (B4) | ●● | ○ |
| Notify-6 | Email channel: a second adapter on its own topic subscription | Ports and Adapters pays off; per-channel subscription isolates failures (B4); new service → ADR | ●● | ○ |

## 9. Platform

| ID | Feature | Teaches (block) | Learning | MVP |
|---|---|---|---|---|
| Platform-1 | Health endpoint; version (commit SHA, revision) in the UI footer | Smoke test checks the deployed SHA (B0); makes revisions and traffic split visible (B2) | ●● | ✔ |
| Platform-2 | Feature flag per club (e.g. RangeOps-3 or Rules-2) | App Configuration + targeting filter (B5) | ●● | ✔ |
| Platform-3a | iCal feed of my bookings | HTTP-triggered Function (B4); signed feed token = the secret to rotate (B5) | ●● | ✔ |
| Platform-3b | Public club feed (opening hours, announcements) for the club's website | HTTP-triggered Function (B4); no secret | ●● ≡ Platform-3a | ○ |

## Roadmap coverage

| Block | Concept | Feature(s) |
|---|---|---|
| B0 | Vertical slice, first migration (bundle, moved from B1), seed → teardown → restore | Profile-1 |
| B0 | Browser and API smoke tests (Playwright) | Profile-1 |
| B0 | Smoke test: health, deployed version, one user journey (CI/CD guide §6) | Platform-1, Profile-1 |
| B1 | Tenancy, global query filters, isolation tests | Tenancy-1, Tenancy-4 |
| B1 | External ID sign-in, per-club roles | Tenancy-2, Tenancy-3 |
| B1 | Policy- and resource-based authorization | Tenancy-2, Booking-6 |
| B1 | Exclusion constraint | Booking-3, Booking-4 (without AI), Inventory-2a |
| B1 | Cross-row rule, isolation levels (beyond the roadmap) | Booking-5 |
| B1 | Optimistic concurrency | Inventory-4 |
| B1 | No-tracking, projections, indexes, `EXPLAIN ANALYZE`, pooling | Booking-2, Tenancy-5 |
| B1 | Testcontainers | Booking-3, Booking-4, Booking-5, Inventory-4 |
| B1 | Person-scoped vs club-scoped data; snapshots | RangeOps-1 |
| B1+ | Unit tests on domain rules | Booking-9, Inventory-6 |
| B2 | Revisions, traffic split; worker as second container app | Platform-1; Notify-1 |
| B3 | Cosmos DB: partitioning, indexing, RU, consistency | Logbook-1, Logbook-3 |
| B3 | Resource-based authorization; ETag (`If-Match`) concurrency | Logbook-2 |
| B3 | Change feed; vector search in Cosmos DB | Logbook-4, Logbook-5 |
| B3 | pgvector, RAG with metadata filter, citations, cross-lingual evaluation | Rules-1, Rules-2, Rules-3 |
| B3 | Isolation rule 4 in retrieval | Rules-2 (Rules-5) |
| B3 | Redis: cache + invalidation, TTL holds, vector index | Booking-2, Booking-7, Rules-4 |
| B4 | Outbox, Service Bus topic, idempotent consumer, DLQ, KEDA, failure tests | Notify-1 |
| B4 | Event Grid: blob event; custom event | Rules-1; Booking-8 |
| B4 | Functions: timer; HTTP | Notify-2; Platform-3a |
| B5 | Key Vault + rotation | Platform-3a (or Notify-5) |
| B5 | App Configuration + feature flag | Platform-2 |
| B5 | One trace per booking; KQL; alerts | Booking-3 → Notify-1 |
| B2–B6 | Python | Rules-1 worker; the rest are exercises |
| B1+ | ADRs | Inventory-4, Logbook-3, Booking-5, D1 |

No feature needed: CI/CD, Bicep, ACR Tasks, AKS and App Service labs, operations drill.

## Decisions

- **D1 Notification channel:** in-app inbox. Channels sit behind a port (`INotificationChannel`, Application layer) with adapters in Infrastructure (Ports and Adapters). Email comes later as a second adapter (Notify-6) on its own topic subscription, so an email outage never blocks in-app.
- **D2 Rule book:** fictional club rule book in German, written by the owner, in the most convenient format; one versioned source per club. Write two versions (v1, v2) to exercise versioned citations and the Rules-4 cache key. Embeddings survive teardown in the dump: no re-embedding cost per session.
- **D3 Slots:** fixed 30-min grid; a booking covers 1 or 2 consecutive slots, stored as one range; max 2 slots per person, lane and day (Booking-5); another lane on the same day is allowed. Mixed lengths (30 and 60 min) are what make the exclusion constraint necessary: 10:00–11:00 and 10:30–11:00 start differently, so a `UNIQUE` key can't catch the overlap.
- **D4 Language:** English questions and answers over the German rule book; cross-lingual quality is measured in Rules-3. The eval set stores rule numbers, no German text.

## Open questions

- **Q6 German text in the repo:** CLAUDE.md allows English only. Keep the rule book out of the repo (uploaded per session, like `Resources (Local)/`), or add an explicit CLAUDE.md exception for this one test-data file? Suggest: the exception, so a fresh clone can run ingestion.

## Out of the MVP

Payments (prices shown, paid on site) · admin screens for clubs, lanes and the catalogue (seed script instead) · self-service club onboarding · mobile app, polished UI, real data (§4).
