---
title: "Tax Calculator"
parent: "Operations"
nav_order: 8
render_with_liquid: false
---

# Tax Calculator

This document covers The Pool's current tax-calculation model, including provider selection, fork-facing configuration, browser behavior, Worker endpoints, and the checks operators should run before shipping tax-related changes.

The short version: tax is now a first-class Worker concern rather than one fixed configured rate everywhere. A deployment can still stay on a flat tax rate, but it can also switch to provider-backed or vendored location-aware calculation without forking checkout math in multiple places.

## What The Tax Layer Owns

The tax layer exists to keep one consistent answer across:

- cart previews
- custom checkout UI
- final checkout canonicalization
- Manage Pledge recalculation
- stored pledge totals
- supporter emails
- reports and exports

In the current model, the Worker remains the source of truth. The browser can ask for previews, but the final persisted totals still come from Worker-side calculation.

## Current Provider Modes

The Pool currently supports four tax-provider modes:

| Provider | What it does | Best fit |
|----------|--------------|----------|
| `flat` | Uses the legacy configured `pricing.sales_tax_rate` | simple deployments that want one configured rate |
| `offline_rules` | Uses vendored VAT/GST and state-level fallback rules | forks that want location-aware behavior without depending on one live local-jurisdiction API for every quote |
| `nm_grt` | Starts from the vendored New Mexico dataset and can refine with the EDAC GRT API | New Mexico-focused deployments that need stronger local GRT accuracy |
| `zip_tax` | Uses ZIP.TAX for local US jurisdiction lookups and falls back to `offline_rules` outside US/CA | US-focused deployments that want provider-backed local tax precision |

## Config Surface

Fork-facing tax config lives in [`Customization Guide`](/docs/development/customization-guide/) under `tax`.

Current keys:

- `tax.provider`
- `tax.origin_country`
- `tax.use_regional_origin`
- `tax.nm_grt_api_base`
- `tax.zip_tax_api_base`

Example:

```yml
tax:
  provider: nm_grt
  origin_country: US
  use_regional_origin: false
  nm_grt_api_base: https://grt.edacnm.org
  zip_tax_api_base: https://api.zip-tax.com
```

The compatibility baseline still exists:

- `pricing.sales_tax_rate` is still used by `flat`
- `SALES_TAX_RATE` is still mirrored into the Worker for that legacy mode

## Worker Mirror And Secrets

The non-secret tax settings are mirrored from site config into the Worker environment:

- `TAX_PROVIDER`
- `TAX_ORIGIN_COUNTRY`
- `TAX_USE_REGIONAL_ORIGIN`
- `NM_GRT_API_BASE`
- `ZIP_TAX_API_BASE`
- `SALES_TAX_RATE` for `flat`

If you enable `zip_tax`, also set:

- `ZIP_TAX_API_KEY`

Keep that key out of `_config.yml`. Set it as a Worker secret or in `worker/.dev.vars` for local work.

If you use the New Mexico starter dataset path, refresh the vendored file with:

```bash
node ./scripts/update-nm-grt-starter.mjs
```

## Browser And Checkout Behavior

The browser is intentionally allowed to show a provisional state before it has enough destination detail.

Current behavior:

- cart and checkout can show tax as `--`
- the browser can request a preview through `POST /tax/quote`
- final canonical checkout still happens through `POST /checkout-intent/start`
- if the configured provider needs more location detail, the Worker can return a provisional result instead of guessing
- New Mexico GRT is the most exact built-in path right now and usually needs full street-level destination data rather than only ZIP/state

This is why a tax preview may look incomplete early in checkout but still resolve correctly once billing or shipping details are present.

## Main Endpoints

### `POST /tax/quote`

This endpoint returns a Worker-calculated tax preview for first-party cart and checkout UI.

Use it for:

- provisional cart display
- custom checkout summaries
- updating tax after destination changes

Operational notes:

- it is same-origin protected
- it is rate limited
- it is intended for first-party UI previews, not third-party public use
- it can intentionally return a provisional/no-tax result when the payload is missing required destination detail

### `POST /checkout-intent/start`

This is still the authoritative checkout bootstrap.

It is the endpoint that:

- canonicalizes the cart
- validates campaign and inventory state
- computes the final checkout totals
- persists the signed checkout snapshot that Stripe and the Worker later rely on

If tax behavior looks wrong in the browser, always confirm whether the problem is only in preview mode or also in the canonical `checkout-intent/start` result.

## Local Development Notes

For day-to-day local work, prefer the Podman path:

```bash
npm run podman:doctor
./scripts/dev.sh --podman
```

Important current local behavior:

- changing tax settings in `_config.yml` is not enough by itself; restart the local stack so the Worker mirror updates too
- the mutable-pledge smoke path is now compatible with provider-driven tax setups such as `tax.provider: nm_grt`
- if a local test fixture does not seed enough billing or shipping detail, a provisional tax result may be expected rather than a bug

See [`Podman Local Dev`](/docs/operations/podman-local-dev/), [`Testing Guide`](/docs/operations/testing/), and [`Pledge Worker`](/docs/operations/worker/) for the surrounding runtime details.

## What To Verify Before Shipping

When you change tax config, tax-provider code, checkout destination handling, or pricing display, verify all of these:

- cart preview updates when destination detail changes
- provisional `--` behavior appears only when expected
- `POST /tax/quote` returns the expected preview shape for the configured provider
- `POST /checkout-intent/start` returns final tax totals that match the deployment rules
- Manage Pledge recalculation still keeps subtotal, tax, shipping, tip, and total coherent
- stored pledge totals, emails, and reports still use the same tax answer
- localized tax helper copy still reads correctly if the change touched checkout UI wording

## Troubleshooting

### Tax always looks flat

Check:

- `tax.provider` in `_config.yml`
- mirrored Worker env in `worker/wrangler.toml`
- whether the local stack was restarted after config changes

### Tax stays `--`

Check:

- whether the selected provider needs more destination detail
- whether the browser is sending billing or shipping address fields the provider actually uses
- whether the issue appears only in preview mode or also in `checkout-intent/start`

### ZIP.TAX path is not working

Check:

- `tax.provider: zip_tax`
- `tax.zip_tax_api_base`
- `ZIP_TAX_API_KEY`

### New Mexico results look too broad

Check:

- whether only ZIP/state is being provided instead of a full street-level destination
- whether the starter dataset needs a refresh
- whether the deployment should stay on `nm_grt` or use a different provider mode for that fork

## Related Docs

- [`Pledge Worker`](/docs/operations/worker/)
- [`Testing Guide`](/docs/operations/testing/)
- [`Podman Local Dev`](/docs/operations/podman-local-dev/)
- [`Customization Guide`](/docs/development/customization-guide/)
- [`Project Overview`](/docs/development/project-overview/)
