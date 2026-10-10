# Feat1 · Sign-in and account linking (Tenancy-3)

**Block:** B1 · **Backlog ID:** Tenancy-3 · **Labels:** `block-1`, `clubs`

## Goal

Members sign in with Entra External ID (OIDC + PKCE). The API maps the token's identity to a `Person`. A person added by an admin is linked on first sign-in by verified email. Every later Feat authorizes against that person.

## Scope

- External tenant (Entra External ID) with two app registrations: SPA (public client, PKCE) and API (exposes one scope).
  - Created once by hand and documented in a runbook (`docs/runbooks/external-id.md`). The tenant is permanent and free (≤ 50,000 MAU); it lives outside the session resource group.
  - Sign-up: email with password or email one-time passcode. Social identity providers stay off, so External ID has verified every email.
  - Tenant ID, client IDs and authority are configuration, not secrets: GitHub environment variables → Bicep parameters → container app env vars.
- `Person` entity (global, not club-scoped): display name, email, external object ID (`oid`, empty until linked). UUIDv7 key; unique email; unique `oid`.
- API: JWT bearer validation with the built-in ASP.NET Core `JwtBearer` handler, configured explicitly: issuer, audience, lifetime, signing keys from the External ID metadata. No Microsoft.Identity.Web.
  - `ICurrentPerson` (Application port) resolves the token to a `Person`: first by `oid`; if none is linked, by the token's email, then stores the `oid` (linking). Linking happens once; later email changes in External ID are ignored.
  - No matching person → `403` with problem type `account-not-linked`. Signing in never creates a person.
  - `GET /api/me` → `{ id, displayName, email }`.
  - `GET /api/config` → the SPA's auth settings (authority, client ID, API scope). Public.
- Angular, with MSAL Angular (`@azure/msal-angular`, `@azure/msal-browser`): sign-in and sign-out (redirect flow, PKCE), route guard, and an interceptor that attaches the access token to `/api/*` only.
  - Auth settings are loaded from `/api/config` at startup, not from build-time environment files: one image serves every environment (build once, promote).
  - Unlinked account → page "Ask your club admin to add you".
- Redirect URI per session: each new Container Apps environment gets a new URL, so the CD workflow updates the SPA registration through Microsoft Graph after each deploy.
  - A deploy identity in the External tenant: an app registration with a GitHub federated credential (OIDC, no secret), the `Application.ReadWrite.OwnedBy` permission, and ownership of the SPA registration only.
  - The step replaces the staging redirect URI and keeps the localhost URI. Old staging URIs don't pile up.
- Seed: synthetic persons with `@example.com` emails, unlinked. A bootstrap admin's email comes from a git-ignored local setting (no real address in the repo); its membership comes in [Feat2](Feat2.md).
- Integration tests use tokens signed by a test key (test-only issuer in `WebApplicationFactory`); CI never calls External ID.
- ADR: identity. Covers:
  - External ID, and roles in the app's membership table rather than in the token (isolation rule 1);
  - linking by verified email;
  - MSAL Angular + `JwtBearer`, compared with Microsoft.Identity.Web, angular-oauth2-oidc and a backend-for-frontend;
  - the Graph-based redirect-URI update.

## Acceptance criteria

- [ ] A visitor signs in through External ID and returns to the SPA signed in. Sign-out ends the session.
- [ ] Without a token, every endpoint returns `401`, except health, version, config and the public club endpoints.
- [ ] A token with a wrong audience or issuer, or an expired token, gets `401`.
- [ ] First sign-in with an unlinked person's email links the account; `GET /api/me` returns that person.
- [ ] Later sign-ins with the same account return the same person, even after the email changed in External ID.
- [ ] A sign-in whose email matches no person gets `403 account-not-linked`. The SPA shows the "ask your club admin" page. No person is created.
- [ ] A person already linked to another `oid` is never relinked (`403`).
- [ ] The access token is sent only to the API's origin.
- [ ] No secret in the repo or the image; the SPA registration has no client secret.
- [ ] After a deploy to a new environment, the SPA registration's redirect URIs are exactly the localhost URI and the current staging URI. Sign-in works without manual steps.
- [ ] The deploy identity can change only applications it owns: changing another registration fails.
- [ ] Smoke: the pipeline fails unless `GET /api/me` without a token returns `401` and the authority from `/api/config` serves its OIDC metadata (`200`).

## Definition of Done

- [ ] Merged to `main` by pull request with CI green.
- [ ] Deployed to `staging` through the pipeline; the B0 smoke tests and this Feat's checks passed; one manual sign-in on `staging` succeeded (noted in the learning log).
- [ ] Tests: unit tests for the linking rules; integration tests for linking (by email, by `oid`, no match, already linked) and token rejection (audience, issuer, expiry).
- [ ] Learning-log entry written.

## Sub-issues

1. Setup: External tenant, SPA and API registrations, user flow, deploy identity with a federated credential; runbook.
2. Domain: `Person` and the linking rules.
3. Data: `Person` table, migration, seed (bootstrap admin from a local setting).
4. API (core): JWT validation, `ICurrentPerson` (token identity → person), `GET /api/me`, `GET /api/config`.
5. Angular: sign-in and sign-out, guard, interceptor, runtime config, not-linked page.
6. Bicep + CD: External ID settings as env vars; Graph step that updates the redirect URI; smoke checks.
7. Tests: test token issuer for integration tests.
8. ADR: identity and sign-in.

## Depends on

- Block 0 ([Feat1](../Block_0/Feat1.md), [Feat2](../Block_0/Feat2.md)), CI, Bicep and the OIDC CD workflow.
- Setup tasks (Roadmap B1 steps 7–8): a Testcontainers PostgreSQL fixture for integration tests; the arc42 skeleton in `docs/arc42/`; the database ADR.

## Non-goals

- Memberships and roles ([Feat2](Feat2.md)).
- Self-service club onboarding (out of the MVP).
- Sign-in without a membership (guest self-booking, RangeOps-3, optional).
- A signed-in smoke journey: it needs a stored test-user password. Revisit with Key Vault (B5).
- Social identity providers and MFA policies.
- A custom domain for `staging`.
