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
- `impeccable` skill installed (`upskill pbakaus/impeccable`)
- DA token available via `oauth-token adobe`
- GitHub access configured by the Stardust Lab
- EDS repo + DA org pre-created by the Stardust Lab

## Model

Do NOT set a `model` on scoops — all scoops inherit the cone's model. This avoids failures when a specific model isn't available in the environment.

## Slug Derivation

Derive from URL hostname + 4 random hex chars:
- `https://wknd.site` → `wknd-a3f1`
- `https://www.knack.com` → `knack-9c2e`

Strip `www.`, take first segment before `.`, lowercase, append `-$(openssl rand -hex 2)`.

## CRITICAL — Pipeline Sprinkle Updates

The pipeline sprinkle is the user's only window into what's happening. It MUST be updated in real time.

**During uplift:** the uplift scoop itself pushes status updates and opens sprinkles progressively as artifacts land. The cone does NOT need to wake up for this — the scoop handles it directly via `sprinkle send` and `sprinkle open`.

**During deploy:** the cone pushes `active` before spawning the deploy scoop, and `done` when it completes.

Format: `sprinkle send {{SLUG}}-pipeline '{"step":"<id>","status":"active|done","summary":"...","link":"..."}'`

Step IDs in order: `extract`, `audit`, `brand-review`, `direction`, `prototypes`, `deploy`

## Procedure

### Step 1 — Setup & open pipeline sprinkle

1. Derive slug from the URL
2. Read `/workspace/skills/stardust-demo/templates/pipeline.shtml.tpl`
3. Replace `{{URL}}` and `{{SLUG}}`
4. Write to `/shared/sprinkles/{{SLUG}}-pipeline/{{SLUG}}-pipeline.shtml`
5. Run: `sprinkle open {{SLUG}}-pipeline`
6. Push initial status IMMEDIATELY — the user must see activity from the first second:
   ```
   sprinkle send {{SLUG}}-pipeline '{"step":"extract","status":"active","summary":"Crawling homepage..."}'
   ```

### Step 2 — Run uplift (scoop)

Spawn the uplift scoop:

```
scoop_scoop({
  name: "{{SLUG}}-uplift",
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
- Pipeline sprinkle: {{SLUG}}-pipeline

## DA Auth

- Get IMS token: DA_TOKEN=$(oauth-token adobe)

## CRITICAL — Progressive sprinkle updates

You are responsible for keeping the user informed IN REAL TIME. After each uplift phase
completes, you MUST immediately:
1. Push the completed phase as `done` to the pipeline sprinkle
2. Push the next phase as `active`
3. If the phase produced a reviewable artifact (audit, brand-review, prototypes), populate
   and open its dedicated sprinkle

DO NOT batch updates. DO NOT wait until the end. Push after EVERY phase.

### After EXTRACT completes:
sprinkle send {{SLUG}}-pipeline '{"step":"extract","status":"done","summary":"Homepage crawled"}'
sprinkle send {{SLUG}}-pipeline '{"step":"audit","status":"active","summary":"Analyzing design tensions..."}'

### After AUDIT completes:
sprinkle send {{SLUG}}-pipeline '{"step":"audit","status":"done","summary":"5 tensions identified"}'
sprinkle send {{SLUG}}-pipeline '{"step":"brand-review","status":"active","summary":"Extracting brand surface..."}'

Then OPEN the audit sprinkle:
1. Read /workspace/stardust/uplift-improvements.md
2. Parse 5 tensions into JSON array: [{"category":"...","title":"...","body":"..."},...]
   Valid categories: dated-pattern, ia-clutter, density, cliche, missed-opportunity
3. Read /workspace/skills/stardust-demo/templates/audit.shtml.tpl
4. Replace {{URL}} and {{SLUG}} with their values
5. Replace {{TENSIONS_JSON}} with the raw JSON array (it sits inside a
   <script type="application/json"> data island — no escaping needed, just paste the JSON)
6. mkdir -p /shared/sprinkles/{{SLUG}}-audit
7. Write populated template to /shared/sprinkles/{{SLUG}}-audit/{{SLUG}}-audit.shtml
8. Run: sprinkle open {{SLUG}}-audit

### After BRAND-REVIEW completes:
sprinkle send {{SLUG}}-pipeline '{"step":"brand-review","status":"done","summary":"Palette + type extracted"}'
sprinkle send {{SLUG}}-pipeline '{"step":"direction","status":"active","summary":"Defining variant directions..."}'

Then OPEN the brand review sprinkle:
1. Copy brand review to /shared/ (followers can't access /workspace/):
   cp /workspace/stardust/current/brand-review.html /shared/{{SLUG}}-brand-review.html
2. Serve from /shared/: open /shared/{{SLUG}}-brand-review.html → capture the preview URL
3. Read /workspace/skills/stardust-demo/templates/brand-review.shtml.tpl
4. Replace {{URL}} and {{BRAND_REVIEW_URL}} with their values
5. mkdir -p /shared/sprinkles/{{SLUG}}-brand-review
6. Write to /shared/sprinkles/{{SLUG}}-brand-review/{{SLUG}}-brand-review.shtml
7. Run: sprinkle open {{SLUG}}-brand-review

### After DIRECTION completes:
sprinkle send {{SLUG}}-pipeline '{"step":"direction","status":"done","summary":"3 variant directions resolved"}'
sprinkle send {{SLUG}}-pipeline '{"step":"prototypes","status":"active","summary":"Generating 3 HTML prototypes..."}'

### After PROTOTYPES complete:
sprinkle send {{SLUG}}-pipeline '{"step":"prototypes","status":"done","summary":"3 variants ready for review"}'

Then OPEN the variants sprinkle:
1. Copy prototypes to /shared/ (followers can't access /workspace/):
   cp /workspace/stardust/prototypes/home-A-proposed.html /shared/{{SLUG}}-variant-A.html
   cp /workspace/stardust/prototypes/home-B-proposed.html /shared/{{SLUG}}-variant-B.html
   cp /workspace/stardust/prototypes/home-C-cinematic.html /shared/{{SLUG}}-variant-C.html
2. Serve all 3 from /shared/:
   open /shared/{{SLUG}}-variant-A.html → capture URL as VARIANT_A_URL
   open /shared/{{SLUG}}-variant-B.html → capture URL as VARIANT_B_URL
   open /shared/{{SLUG}}-variant-C.html → capture URL as VARIANT_C_URL
3. Take screenshots via playwright-cli screenshot of each
4. Serve screenshots: open /shared/{{SLUG}}-variant-A.png etc. → capture URLs
5. Read /workspace/stardust/direction.md — extract:
   - Per variant: key (A/B/C), title, pitch, what-if question, moves array, role
   - Which variant is recommended
   - Shared fixes across all variants
6. Read /workspace/skills/stardust-demo/templates/variants.shtml.tpl
7. Replace {{URL}} and {{SLUG}} with their values
8. Replace {{VARIANTS_JSON}} with a single JSON object inside the data island
   (no escaping needed — it's inside <script type="application/json">):
   ```json
   {
     "variants": [
       {
         "key": "A",
         "url": "<VARIANT_A_URL>",
         "screenshot": "<SCREENSHOT_A_URL>",
         "title": "...",
         "pitch": "...",
         "whatif": "...",
         "moves": ["move 1", "move 2"],
         "role": "..."
       },
       { "key": "B", ... },
       { "key": "C", ... }
     ],
     "fixes": ["fix 1", "fix 2", ...],
     "recommended": "B"
   }
   ```
9. mkdir -p /shared/sprinkles/{{SLUG}}-variants
10. Write to /shared/sprinkles/{{SLUG}}-variants/{{SLUG}}-variants.shtml
9. Run: sprinkle open {{SLUG}}-variants
```

**If uplift asks about existing state** (prior `state.json` for same URL):
- The scoop surfaces the question. The cone relays it to the user.
- Feed the user's answer back: `feed_scoop("{{SLUG}}-uplift", "User answered: <answer>. Continue.")`

**Uplift outputs when complete:**
- `/workspace/stardust/uplift-improvements.md` — 5 tensions
- `/workspace/stardust/current/brand-review.html` — brand review page
- `/workspace/stardust/current/_brand-extraction.json` — palette + type
- `/workspace/stardust/prototypes/home-A-proposed.html`
- `/workspace/stardust/prototypes/home-B-proposed.html`
- `/workspace/stardust/prototypes/home-C-cinematic.html`
- `/workspace/stardust/direction.md` — variant directions + recommendation

### Step 3 — Verify sprinkles are open

When the uplift scoop completes (scoop-ready lick), verify all 4 sprinkles are open.
The scoop should have opened audit, brand-review, and variants progressively.
If any are missing, open them now inline using the same template population steps above.

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

1. Push pipeline status FIRST — before spawning the scoop:
   ```
   sprinkle send {{SLUG}}-pipeline '{"step":"deploy","status":"active","summary":"Deploying variant {{VARIANT}} to EDS..."}'
   ```

2. Spawn deploy scoop:
   ```
   scoop_scoop({
     name: "{{SLUG}}-deploy",
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
