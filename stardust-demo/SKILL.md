---
name: stardust-demo
description: |
  Use this when the user wants to run a stardust presales demo for a website — uplift a URL
  and automatically open three sprinkles (audit report, brand review, and variants review) 
  populated with the results. Covers the full stardust:uplift pipeline plus auto-generating
  and opening the three demo sprinkles. Use this instead of running stardust:uplift manually
  when the goal is a complete, ready-to-present demo package.
allowed-tools: bash, read_file, write_file, edit_file
---

# stardust-demo

One command. One URL. Three demo sprinkles ready to present.

`stardust-demo` runs `stardust:uplift` on a URL and then automatically generates and opens
three sprinkles in the stardust design system style:

| Sprinkle | Icon | Content |
|---|---|---|
| `<slug>-audit` | triangle-alert | 5 tensions found by the uplift audit |
| `<slug>-brand-review` | palette | Brand review HTML from the extraction |
| `<slug>-variants` | layout-panel-left | 3 variant cards with recommendation |

## Setup

1. Verify `stardust` skill is installed (`skill list | grep stardust`). If not: `upskill adobe/skills --skill stardust`.
2. Verify `impeccable` skill files are at `/workspace/skills/impeccable/`. If not, fetch from `pbakaus/impeccable`.
3. Check `/workspace/stardust/state.json` — if a previous uplift ran for the same URL, ask the user whether to re-run or use existing artifacts.

## Procedure

### Step 1 — Run the uplift

Delegate to the `stardust:uplift` pipeline (via a scoop) for the given URL. Wait for it to complete.

Outputs expected at:
- `/workspace/stardust/uplift-improvements.md` — 5 tensions
- `/workspace/stardust/current/brand-review.html` — brand review
- `/workspace/stardust/current/_brand-extraction.json` — palette + type
- `/workspace/stardust/prototypes/home-A-proposed.html`
- `/workspace/stardust/prototypes/home-B-proposed.html`
- `/workspace/stardust/prototypes/home-C-cinematic.html`
- `/workspace/stardust/direction.md` — variant directions + recommendation

### Step 2 — Serve prototype screenshots

For each prototype, take a Playwright screenshot and serve via `open`:
```bash
playwright-cli screenshot --tab <id> /shared/<slug>-variant-A.png
open /shared/<slug>-variant-A.png  # → https://www.sliccy.ai/preview/shared/...
```
Repeat for B and C.

### Step 3 — Generate the three sprinkles

Use the template system in `/workspace/skills/stardust-demo/templates/` to generate
populated `.shtml` files for each sprinkle. The templates use `{{PLACEHOLDER}}` tokens
that you replace with the actual content from the uplift artifacts.

Write each sprinkle to `/shared/sprinkles/<slug>-<type>/<slug>-<type>.shtml`.

### Step 4 — Open all three sprinkles

```bash
sprinkle open <slug>-audit
sprinkle open <slug>-brand-review
sprinkle open <slug>-variants
```

### Step 5 — Report

Print a summary:
```
demo ready — <URL>

sprinkles open:
  <slug>-audit          — 5 tensions
  <slug>-brand-review   — brand extraction
  <slug>-variants       — 3 variants, B recommended

files saved to github.com/QuentinVecchio/stardust-sprinkles (if push requested)
```

## Template system

Templates live in `/workspace/skills/stardust-demo/templates/`:
- `audit.shtml` — audit sprinkle template with `{{TENSIONS}}`, `{{SLUG}}`, `{{URL}}` tokens
- `brand-review.shtml` — brand review template with `{{BRAND_REVIEW_URL}}`, `{{URL}}` tokens
- `variants.shtml` — variants template with `{{VARIANT_A_URL}}`, `{{VARIANT_B_URL}}`, `{{VARIANT_C_URL}}`, `{{SCREENSHOT_A}}`, `{{SCREENSHOT_B}}`, `{{SCREENSHOT_C}}`, `{{FIXES}}`, `{{URL}}` tokens

Read the template, replace the tokens with content from the uplift artifacts, write the populated file.

## Slug derivation

Derive a short slug from the URL hostname:
- `https://wknd.site` → `wknd`
- `https://www.knack.com` → `knack`
- `https://adobe.com` → `adobe`

Strip `www.`, take the first hostname segment before `.`, lowercase.

## Re-run behavior

If `/workspace/stardust/state.json` exists and was written for the same URL:
- Ask: "I have an existing uplift for `<URL>` from `<date>`. Re-run the extraction or use the existing artifacts?"
- If reuse: skip Step 1, go straight to Steps 2–5.
- If re-run: clear `/workspace/stardust/` and start fresh.

## Step 6 — Deploy the chosen variant

Once the user has picked a variant (A, B, or C), invoke `stardust:deploy` to convert the
prototype HTML into a live Edge Delivery Services (AEM) site.

```
stardust:deploy stardust/prototypes/home-<X>-proposed.html
```

`stardust:deploy` owns:
- Converting each prototype `<section>` into an EDS block (`blocks/<name>/<name>.js` + `.css`)
- Authoring EDS content pages under `content/`
- Static header/footer fragments at `fragments/header.html` + `fragments/footer.html`
- Updating `styles/styles.css` with brand tokens
- Self-hosting fonts with metric-matched fallbacks (zero CLS)
- Deploying via DA Source API (`PUT admin.da.live/source/…`) + AEM preview/publish
- Visual + structural diff validation against the original prototype

Trigger phrase for the user: "deploy variant B" or "let's go with B".

## Saving to git

After generating sprinkles, offer to push to the templates repo:
```bash
cp /shared/sprinkles/<slug>-variants/<slug>-variants.shtml /workspace/stardust-sprinkles/sprinkles/<slug>-variants-review.shtml
# repeat for audit and brand-review
cd /workspace/stardust-sprinkles && git add sprinkles/ && git commit -m "Add <slug> demo sprinkles" && git push
```

## Design system

All three sprinkles share the same stardust design token system. The canonical token set:

```css
:root {
  --ink: #0a1024;
  --bg: #f5f0e6;
  --surface: #fffdf8;
  --sunken: #ece4d2;
  --amber: #e8b95e;
  --amber-deep: #c9822d;
  --amber-light: #ffd98a;
  --fg: rgba(26,31,56,0.95);
  --fg-muted: rgba(26,31,56,0.72);
  --fg-dim: rgba(26,31,56,0.52);
  --fg-faint: rgba(26,31,56,0.30);
  --hairline: rgba(26,31,56,0.14);
  --hairline-soft: rgba(26,31,56,0.08);
  --success: #5f9669;
  --danger: #c0453f;
  --display: "SF Pro Display", Inter, system-ui, sans-serif;
  --text: "SF Pro Text", Inter, system-ui, sans-serif;
  --mono: "SF Mono", "JetBrains Mono", ui-monospace, monospace;
  --ease: cubic-bezier(0.16, 1, 0.3, 1);
}
```

Never use S2 tokens in these sprinkles. The stardust design system is self-contained.

## References

- `/workspace/skills/stardust/SKILL.md` — master stardust skill
- `/workspace/skills/stardust/skills/uplift/SKILL.md` — uplift pipeline
- `/workspace/skills/stardust-demo/templates/` — sprinkle templates
- `/workspace/stardust-sprinkles/` — git repo for storing demo sprinkles
- `github.com/QuentinVecchio/stardust-sprinkles` — remote repo
