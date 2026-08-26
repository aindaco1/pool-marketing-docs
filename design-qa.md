# Dust Wave Support design QA

Date: 2026-08-25

## Visual target

- Existing production design system: `https://thepool.fund/support/`
- Conceptual interaction reference: the supplied DCP-o-matic support screenshot
- Implementation: local `/support/` build using the shared `dust_wave_support_v1` contract

The production page and implementation were captured in the in-app browser at the same 1024 × 900 viewport and reviewed together in one side-by-side comparison. The DCP-o-matic screenshot informed the clear creator/maintainer introduction and the explicit one-time versus regular-support choice; its typography, color, and component styling were intentionally not copied.

## Checks

- The Pool typography, square borders, monochrome palette, header, footer, and button language remain consistent with the existing site.
- The Dust Wave logo is a real existing brand asset and retains its intrinsic aspect ratio.
- The introduction, payment choices, funding details, and non-payment alternatives have clear hierarchy without iframe clipping or nested checkout chrome.
- Desktop layout was checked at 1024 × 900; mobile layout and both stacked payment cards were checked at 390 × 844.
- The responsive navigation, checkout CTAs, external links, language control, heading order, landmarks, and focus treatment remain functional.
- No horizontal overflow, cropped content, placeholder art, unreadable contrast, or accidental border-radius drift was observed.

final result: passed
