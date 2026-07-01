---
name: stardust-demo
description: |
  Orchestrate a full stardust presales demo for a website — uplift a URL,
  open 4 sprinkles (pipeline, audit, brand review, variants), and deploy
  the user's chosen variant to EDS. Use inside SLICC with DA token and
  GitHub access pre-configured by the Stardust Lab.
user-invocable: true
---

# stardust-demo

One URL in. Four sprinkles open. A deployed EDS site out.

Orchestrates `stardust:uplift` → sprinkle generation → user variant selection → `stardust:deploy` inside SLICC.

## Prerequisites

- `stardust` skill installed (`upskill adobe/skills --skill stardust`)
- `impeccable` skill available at `/workspace/skills/impeccable/`
- DA token available via `oauth-token adobe`
- GitHub access configured by the Stardust Lab
- EDS repo + DA org pre-created by the Stardust Lab

## Slug Derivation

Derive from URL hostname + 4 random hex chars:
- `https://wknd.site` → `wknd-a3f1`
- `https://www.knack.com` → `knack-9c2e`

Strip `www.`, take first segment before `.`, lowercase, append `-$(openssl rand -hex 2)`.

## Procedure

### Step 1 — Setup & open pipeline sprinkle

1. Derive slug from the URL
2. Read `/workspace/skills/stardust-demo/templates/pipeline.shtml.tpl`
3. Replace `{{URL}}` and `{{SLUG}}`
4. Write to `/shared/sprinkles/{{SLUG}}-pipeline/{{SLUG}}-pipeline.shtml`
5. Run: `sprinkle open {{SLUG}}-pipeline`
6. Push initial status:
   ```
   sprinkle send {{SLUG}}-pipeline '{"step":"extract","status":"active","summary":"Starting extraction..."}'
   ```

### Step 2 — Run uplift (scoop)

Spawn the uplift scoop:

```
scoop_scoop({
  name: "{{SLUG}}-uplift",
  model: "claude-opus-4-6",
  writablePaths: ["/scoops/{{SLUG}}-uplift/", "/shared/", "/workspace/stardust/"]
})
```

Feed the scoop:

```
## STEP 1 — MANDATORY

Run: read_file /workspace/skills/stardust/skills/uplift/SKILL.md
Then follow those instructions EXACTLY for URL: {{URL}}

## Context

- URL: {{URL}}
- Slug: {{SLUG}}
- State dir: /workspace/stardust/
- Output contract: write status updates to /shared/stardust-demo/uplift-status.json

## DA Auth

- Get IMS token: DA_TOKEN=$(oauth-token adobe)

## Progress updates

After each major phase completes, write a status file:
/shared/stardust-demo/uplift-status.json

Format: {"phase":"extract|audit|brand-review|direction|prototypes","status":"done","summary":"..."}

Phases in order: extract → audit → brand-review → direction → prototypes
```

**While uplift runs:**
- Yield after spawning. Do NOT poll.
- When the scoop-ready lick arrives, read `/shared/stardust-demo/uplift-status.json`
- Push status to pipeline sprinkle immediately:
  ```
  sprinkle send {{SLUG}}-pipeline "$(cat /shared/stardust-demo/uplift-status.json)"
  ```

**If uplift asks about existing state** (prior `state.json` for same URL):
- Relay the question to the user in chat
- Feed the user's answer back: `feed_scoop("{{SLUG}}-uplift", "User answered: <answer>. Continue.")`

**Uplift outputs when complete:**
- `/workspace/stardust/uplift-improvements.md` — 5 tensions
- `/workspace/stardust/current/brand-review.html` — brand review page
- `/workspace/stardust/current/_brand-extraction.json` — palette + type
- `/workspace/stardust/prototypes/home-A-proposed.html`
- `/workspace/stardust/prototypes/home-B-proposed.html`
- `/workspace/stardust/prototypes/home-C-cinematic.html`
- `/workspace/stardust/direction.md` — variant directions + recommendation

### Step 3 — Open remaining sprinkles (inline)

Once the uplift scoop completes, the cone does all of this inline (no scoops):

#### 3a. Audit sprinkle

1. Read `/workspace/stardust/uplift-improvements.md`
2. Parse the 5 tensions into a JSON array:
   ```json
   [
     {"category":"dated-pattern","title":"...","body":"..."},
     {"category":"ia-clutter","title":"...","body":"..."},
     ...
   ]
   ```
   Valid categories: `dated-pattern`, `ia-clutter`, `density`, `cliche`, `missed-opportunity`
3. Read `/workspace/skills/stardust-demo/templates/audit.shtml.tpl`
4. Replace `{{URL}}`, `{{SLUG}}`, `{{TENSIONS_JSON}}` (JSON-escaped into the template)
5. Write to `/shared/sprinkles/{{SLUG}}-audit/{{SLUG}}-audit.shtml`
6. Run: `sprinkle open {{SLUG}}-audit`

#### 3b. Brand review sprinkle

1. Serve the brand review: `open /workspace/stardust/current/brand-review.html`
2. Get the preview URL from the `open` command output
3. Read `/workspace/skills/stardust-demo/templates/brand-review.shtml.tpl`
4. Replace `{{URL}}`, `{{BRAND_REVIEW_URL}}`
5. Write to `/shared/sprinkles/{{SLUG}}-brand-review/{{SLUG}}-brand-review.shtml`
6. Run: `sprinkle open {{SLUG}}-brand-review`

#### 3c. Variants sprinkle

1. Serve all 3 prototypes:
   ```
   open /workspace/stardust/prototypes/home-A-proposed.html
   open /workspace/stardust/prototypes/home-B-proposed.html
   open /workspace/stardust/prototypes/home-C-cinematic.html
   ```
2. Take screenshots of each (via `playwright-cli screenshot`)
3. Serve screenshots: `open /shared/{{SLUG}}-variant-A.png` etc.
4. Read `/workspace/stardust/direction.md` — extract:
   - Variant titles, pitches, what-if questions, moves, roles
   - Which variant is recommended
   - Shared fixes across all variants
5. Read `/workspace/skills/stardust-demo/templates/variants.shtml.tpl`
6. Replace all placeholders:
   - `{{URL}}`, `{{SLUG}}`
   - `{{SCREENSHOT_A}}`, `{{SCREENSHOT_B}}`, `{{SCREENSHOT_C}}`
   - `{{VARIANT_A_URL}}`, `{{VARIANT_B_URL}}`, `{{VARIANT_C_URL}}`
   - `{{VARIANT_A_TITLE}}`, `{{VARIANT_A_PITCH}}`, `{{VARIANT_A_WHATIF}}`, `{{VARIANT_A_MOVES_JSON}}`, `{{VARIANT_A_ROLE}}`
   - Same pattern for B and C
   - `{{FIXES_JSON}}` — JSON array of shared fix strings
   - `{{RECOMMENDED}}` — letter of recommended variant (A, B, or C)
7. Write to `/shared/sprinkles/{{SLUG}}-variants/{{SLUG}}-variants.shtml`
8. Run: `sprinkle open {{SLUG}}-variants`

#### 3d. Update pipeline

Push final uplift status:
```
sprinkle send {{SLUG}}-pipeline '{"step":"prototypes","status":"done","summary":"3 variants ready for review"}'
```

### Step 4 — Wait for variant selection (lick)

The variants sprinkle fires a lick when the user clicks "Deploy":
```json
{"action": "select-variant", "variant": "B"}
```

When the cone receives this lick:
1. Confirm with the user: "Deploy variant {{VARIANT}}? This will convert it to an EDS site."
2. If confirmed, proceed to Step 5
3. If the user wants a different variant, wait for another lick

### Step 5 — Deploy (scoop)

1. Push pipeline status:
   ```
   sprinkle send {{SLUG}}-pipeline '{"step":"deploy","status":"active","summary":"Deploying variant {{VARIANT}}..."}'
   ```

2. Spawn deploy scoop:
   ```
   scoop_scoop({
     name: "{{SLUG}}-deploy",
     model: "claude-opus-4-6",
     writablePaths: ["/scoops/{{SLUG}}-deploy/", "/shared/", "/workspace/{REPO}/"]
   })
   ```

3. Feed the scoop:
   ```
   ## STEP 1 — MANDATORY

   Run: read_file /workspace/skills/stardust/skills/deploy/SKILL.md
   Then follow those instructions EXACTLY.

   ## Context

   - Prototype to deploy: /workspace/stardust/prototypes/home-{{VARIANT}}-proposed.html
     (if variant C: /workspace/stardust/prototypes/home-C-cinematic.html)
   - EDS repo: /workspace/{REPO}
   - State dir: /shared/stardust-demo/
   - Output contract: write status to /shared/stardust-demo/deploy-status.json

   ## DA Auth

   - Get IMS token: DA_TOKEN=$(oauth-token adobe)
   - Upload content via DA API (PUT admin.da.live/source/...)
   - Trigger preview: POST admin.hlx.page/preview/{owner}/{repo}/{branch}/{page}

   ## Git rules

   - NEVER use `git add .` or `git add -A`
   - One commit + one push at the end

   ## Naming questions

   If this is a multi-page deploy, you MUST ask naming questions.
   Write them to /shared/stardust-demo/deploy-questions.json:
   {"questions": ["question 1", "question 2", ...]}
   Then STOP and wait for answers via feed_scoop.

   ## Output contract

   Write to /shared/stardust-demo/deploy-status.json:
   {"status":"done","preview_url":"https://...","summary":"..."}
   ```

4. **If deploy asks naming questions:**
   - Read `/shared/stardust-demo/deploy-questions.json`
   - Present questions to the user in chat
   - Feed answers back: `feed_scoop("{{SLUG}}-deploy", "Answers: ...")`

5. On completion:
   ```
   sprinkle send {{SLUG}}-pipeline '{"step":"deploy","status":"done","summary":"Live at {{PREVIEW_URL}}","link":"{{PREVIEW_URL}}"}'
   ```

### Step 6 — Report

```
✓ Demo ready — {{URL}}

Sprinkles open:
  {{SLUG}}-pipeline       — live pipeline status
  {{SLUG}}-audit          — 5 tensions found
  {{SLUG}}-brand-review   — brand extraction
  {{SLUG}}-variants       — 3 variants

Deployed: {{PREVIEW_URL}}
```

## Re-run Behavior

If `/workspace/stardust/state.json` exists for the same URL:
- Ask: "I have an existing uplift for `{{URL}}`. Re-run or reuse?"
- If reuse: skip Step 2, go straight to Step 3 (sprinkle generation)
- If re-run: clear `/workspace/stardust/` and start fresh

## Lick Events

| Lick | Source | Cone action |
|------|--------|-------------|
| `{action: "select-variant", variant: "A\|B\|C"}` | variants sprinkle | Confirm with user, spawn deploy |

## Status Update Contract (cone → pipeline sprinkle)

```json
{"step": "<step-id>", "status": "active|done", "summary": "...", "link": "..."}
```

Step IDs: `extract`, `audit`, `brand-review`, `direction`, `prototypes`, `deploy`

## Design System

All sprinkles use the stardust token set:

```css
:root {
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
