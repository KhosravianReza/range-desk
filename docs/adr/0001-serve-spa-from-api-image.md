# 0001 · Serve the Angular shell from the API image

**Status:** Accepted · **Date:** 2026-10-30 · **Spec:** [Block_0/Feat0](../specs/Block_0/Feat0.md)

## Context

- `staging` serves the Angular shell and the API at one public URL ([Feat0](../specs/Block_0/Feat0.md)).
- Nothing runs permanently in Azure: every resource is recreated from Bicep each session, so each extra resource costs setup time.
- [Feat1](../specs/Block_0/Feat1.md)'s smoke test checks the deployed commit SHA. UI and API should share it.
- After `ng build`, the Angular app is static files (no server-side rendering).

## Options

| Option | Pros | Cons |
|---|---|---|
| A: Angular in the API image (multi-stage Dockerfile → `wwwroot`) | One image, one SHA, one deploy. Same origin: no CORS. No extra Azure resource. | UI and API deploy and scale together. The API serves static files. |
| B: Separate web container (nginx) | Independent deploys and scaling. nginx excels at static files. | A second image and container app. Two SHAs to keep in step. CORS or a reverse proxy. |
| C: Azure Static Web Apps | CDN, free tier, pull request previews. | A service outside the stack. A separate deploy and SHA. CORS or a linked backend. |

## Decision

Option A. The Dockerfile builds Angular and copies the output into the API's `wwwroot`. The API serves it with `UseDefaultFiles` and `UseStaticFiles`.

## Consequences

- One artifact per commit: Feat1's version footer and smoke test cover UI and API with one SHA.
- The SPA calls `/api/...` on its own origin; no CORS configuration.
- The API needs a fallback to `index.html` for Angular routes, while unknown `/api/*` and `/health/*` paths return `404` (Feat1).
- `UseStaticFiles`, not `MapStaticAssets`: the Angular files are copied in after `dotnet publish`, so they're missing from the static assets manifest. Angular hashes its file names itself.
- Locally, `ng serve` runs the UI on its own port; a dev proxy to the API comes with Feat1.
- Revisit if the frontend needs its own release cadence, a CDN or independent scaling.
