# Feat2 · Memberships and per-club roles (CL-2)

**Block:** B1 · **Backlog ID:** CL-2 · **Labels:** `block-1`, `clubs`

## Goal

Roles are per club and live in the app's membership table, not in the token. Policy-based authorization checks them for the club named in the route. One person can hold different roles in different clubs.

## Scope

- `Membership` entity: club, person, roles. Unique per (club, person).
  - Roles: a set of `Member`, `RangeOfficer`, `Trainer` and `Admin`, stored as a flags value on the membership row (isolation rule 1).
  - Membership is the source of club authority. It carries no tenant query filter ([Feat4](Feat4.md)) and is always read by person or by club explicitly.
- Seed memberships for the synthetic persons across both seeded clubs, including:
  - one person who is a member in club A and an admin in club B (needed by [Feat5](Feat5.md));
  - the bootstrap admin from [Feat1](Feat1.md).
- Policy-based authorization: the policies `ClubMember`, `RangeOfficer` (range officer or admin) and `ClubAdmin`.
  - One requirement type, `ClubRoleRequirement(anyOf)`, with one handler. The handler takes `{clubId}` from the route, loads the current person's membership for that club once per request, and succeeds if one of the roles matches.
  - Unknown club or no membership → `403`.
- `GET /api/me` adds `memberships: [{ clubId, clubName, roles }]`.
- An admin adds a member: `POST /api/clubs/{clubId}/members` `{ email, displayName }` (`ClubAdmin`).
  - If a person with that email exists, it is reused (one person, several clubs). Otherwise an unlinked person is created, and [Feat1](Feat1.md) links it on first sign-in.
  - Grants `Member` only. Other roles come from the seed (no role admin screens: out of the MVP).
- Angular:
  - "My clubs" on `/me`, read from `/api/me`.
  - Admin-only "Add member" form at `/clubs/:id/members/new`.
  - The navigation shows admin links to admins only. This is a convenience; the API decides.

## Acceptance criteria

- [ ] `GET /api/me` lists every membership of the signed-in person, with its roles per club.
- [ ] A person who is a member in club A and an admin in club B passes `ClubAdmin` in B and gets `403` in A.
- [ ] An admin of club A adds a new email → `201`. That person's first sign-in links the account, and they are a member of A.
- [ ] Adding the email of an existing person from club B creates a membership in A; no second person is created.
- [ ] Adding an existing member → `409`. An invalid email → `400`.
- [ ] A non-admin calling the add-member endpoint gets `403`; no membership is created.
- [ ] A role change in the database takes effect on the next request, without a new sign-in.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: unit tests for the requirement handler (role × policy matrix); integration tests for add-member (new person, existing person, duplicate, non-admin).
- [ ] Learning-log entry written.

## Sub-issues

1. Domain: `Membership` and `ClubRoles`.
2. Data: membership table, migration, seed.
3. API (core): `ClubRoleRequirement`, its handler and the three policies.
4. API: memberships in `GET /api/me`; `POST /api/clubs/{clubId}/members`.
5. Angular: my clubs, the add-member form, role-aware navigation.

## Depends on

- [Feat1](Feat1.md).

## Non-goals

- Tenant query filters ([Feat4](Feat4.md)) and the isolation tests ([Feat5](Feat5.md)).
- Resource-based authorization ([Feat10](Feat10.md)).
- Role management screens and removing members (out of the MVP; the seed replaces them).
- Officials on the club page ([Feat20](Feat20.md), CP-2).
