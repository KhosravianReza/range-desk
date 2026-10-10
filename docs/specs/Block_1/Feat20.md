# Feat20 · Officials on the club page (Profile-2)

**Block:** B1 · **Backlog ID:** Profile-2 · **Labels:** `block-1`, `profile`, `stretch`

## Goal

The public club page lists the club's officials (board, range officers, trainers), taken from the membership roles. Only people who opted in are shown.

## Scope

- New role `Board` in `ClubRoles` ([Feat2](Feat2.md)). It is for display only: no policy grants anything for it. This is an additive flag value.
- Official roles: `Board`, `RangeOfficer`, `Trainer`. `Admin` is app administration, not a club office, and isn't shown.
- `Membership` gets `ShowAsOfficial`: per club, default `false`. Additive column.
- `PUT /api/clubs/{clubId}/me/official-visibility` `{ visible }` (`ClubMember`): the person sets it for themselves.
- Public `GET /api/clubs/{id}` (B0 [Feat2](../Block_0/Feat2.md)) adds `officials: [{ displayName, roles }]`.
  - Only opted-in persons who hold an official role; only the official roles are listed.
  - Display name only: no email, no person ID.
- Seed: board members per club; a few officials per club have opted in.
- Angular:
  - An "Officials" section on the club page.
  - An opt-in toggle per club under "My clubs" (`/me`).

## Acceptance criteria

- [ ] A visitor who isn't signed in sees the opted-in officials, with their roles, on the club page.
- [ ] Officials who haven't opted in don't appear. Opting out removes them on the next load.
- [ ] Members with no official role never appear, even when opted in. An admin with no other official role doesn't appear.
- [ ] The `Board` role grants no access: a board member without `Admin` gets `403` on admin endpoints.
- [ ] The response contains no email or person ID.
- [ ] A person can change only their own visibility, and only in clubs where they are a member.

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the smoke tests passed.
- [ ] Tests: integration tests for the officials list (opt-in, role filter, no personal data) and the toggle.
- [ ] Learning-log entry written.

## Sub-issues

1. Domain + Data: `Board` role; `ShowAsOfficial` column; seed.
2. API: officials on the club profile; visibility toggle.
3. Angular: officials section; opt-in toggle.

## Depends on

- [Feat2](Feat2.md).

## Non-goals

- Photos of officials (Profile-3, optional).
- Contact details of officials.
- Board permissions (the role is display-only).
