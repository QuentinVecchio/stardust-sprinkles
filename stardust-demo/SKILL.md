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

Orchestrates `stardust:uplift` (split across multiple scoops) → deliverables to EDS → sprinkle opening → user variant selection → `stardust:deploy` inside SLICC.

## Prerequisites

- `stardust` skill installed (`upskill adobe/skills --skill stardust`)
- `stardust:uplift` sub-skill installed (`upskill adobe/skills --skill uplift`)
- `stardust:deploy` sub-skill installed (`upskill adobe/skills --skill deploy`)
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

## Key Rules

- **Never reference `/workspace/` or `file://` in anything a follower sees** — use EDS URLs
- **Cone owns ALL `sprinkle send` calls** — never delegate pipeline updates to scoops
- **Always mint fresh sprinkle names** per demo — never reuse/overwrite
- **Commit deliverables to EDS BEFORE opening sprinkles** that reference them
- **Screenshots via live EDS URLs** — never `file://` paths, never `/workspace/` paths
- **Embed screenshots as base64 data URIs** in the variants sprinkle (max-width 480, keep total .shtml under 350KB)
- **Lick payloads use `{action, data: {}}`** — extra sibling keys get stripped by the bridge
- **Cherry followers can't open URLs from sprinkles** — use chat-based fallback (cone posts clickable URL)

## CRITICAL — Pipeline Sprinkle Updates

The cone owns ALL pipeline updates. NEVER delegate `sprinkle send` to a working scoop — scoops are too busy with their main work and will skip or forget updates.

The cone pushes status updates between scoops:
- After spawning a scoop: push `active` for the current phase
- After a scoop completes: push `done` for completed phases, then `active` for the next

Format: `sprinkle send {{SLUG}}-pipeline '{"step":"<id>","status":"active|done","summary":"...","link":"..."}'`

Step IDs in order: `extract`, `audit`, `brand-review`, `direction`, `prototypes`, `deploy`

## Procedure

### Step 1 — Setup & open pipeline sprinkle

1. Derive slug from the URL
2. Read `/workspace/skills/stardust-demo/templates/pipeline.shtml.tpl`
3. Replace `{{URL}}` and `{{SLUG}}`
4. Write to `/shared/sprinkles/{{SLUG}}-pipeline/{{SLUG}}-pipeline.shtml`
5. Run: `sprinkle open {{SLUG}}-pipeline`
6. Push initial status:
   ```
   sprinkle send {{SLUG}}-pipeline '{"step":"extract","status":"active","summary":"Crawling homepage..."}'
   ```

### Step 2 — Uplift Phase 1: Extract + Audit + Brand Review (scoop)

Spawn the first uplift scoop:

```
scoop_scoop({
  name: "{{SLUG}}-uplift-1",
  writablePaths: ["/scoops/{{SLUG}}-uplift-1/", "/shared/", "/workspace/stardust/"]
})
```

Feed the scoop:

```
## STEP 1 — MANDATORY

Run: read_file /workspace/skills/stardust/skills/uplift/SKILL.md
Then follow those instructions for URL: {{URL}}

## IMPORTANT — SCOPE LIMIT

You are responsible for the FIRST 3 PHASES ONLY:
1. Extract (crawl + capture)
2. Audit (identify design tensions)
3. Brand Review (extract palette, type, motifs)

STOP after brand-review completes. Do NOT proceed to direction or prototypes.
Write a completion marker when done:
  echo '{"phase":"brand-review","status":"done"}' > /shared/stardust-demo/uplift-1-done.json

## Context

- URL: {{URL}}
- Slug: {{SLUG}}
- State dir: /workspace/stardust/

## DA Auth

- Get IMS token: DA_TOKEN=$(oauth-token adobe)
```

**When scoop completes, the cone pushes updates:**
```
sprinkle send {{SLUG}}-pipeline '{"step":"extract","status":"done","summary":"Homepage crawled"}'
sprinkle send {{SLUG}}-pipeline '{"step":"audit","status":"done","summary":"5 tensions identified"}'
sprinkle send {{SLUG}}-pipeline '{"step":"brand-review","status":"done","summary":"Palette + type extracted"}'
sprinkle send {{SLUG}}-pipeline '{"step":"direction","status":"active","summary":"Defining variant directions..."}'
```

### Step 3 — Uplift Phase 2: Direction + Prototypes (scoop)

Spawn the second uplift scoop:

```
scoop_scoop({
  name: "{{SLUG}}-uplift-2",
  writablePaths: ["/scoops/{{SLUG}}-uplift-2/", "/shared/", "/workspace/stardust/"]
})
```

Feed the scoop:

```
## STEP 1 — MANDATORY

Run: read_file /workspace/skills/stardust/skills/uplift/SKILL.md
Then follow those instructions for URL: {{URL}}

## IMPORTANT — SCOPE LIMIT

The first 3 phases (extract, audit, brand-review) are ALREADY DONE.
Their outputs are in /workspace/stardust/. Do NOT re-run them.

You are responsible for the LAST 2 PHASES ONLY:
4. Direction (define 3 variant directions from the audit + brand review)
5. Prototypes (generate 3 HTML variant prototypes)

Write a completion marker when done:
  echo '{"phase":"prototypes","status":"done"}' > /shared/stardust-demo/uplift-2-done.json

## Context

- URL: {{URL}}
- Slug: {{SLUG}}
- State dir: /workspace/stardust/
- Prior outputs already available:
  - /workspace/stardust/uplift-improvements.md (5 tensions)
  - /workspace/stardust/current/brand-review.html
  - /workspace/stardust/current/_brand-extraction.json
  - /workspace/stardust/current/PRODUCT.md
  - /workspace/stardust/current/DESIGN.md
  - /workspace/stardust/current/DESIGN.json

## DA Auth

- Get IMS token: DA_TOKEN=$(oauth-token adobe)
```

**When scoop completes, the cone pushes:**
```
sprinkle send {{SLUG}}-pipeline '{"step":"direction","status":"done","summary":"3 variant directions resolved"}'
sprinkle send {{SLUG}}-pipeline '{"step":"prototypes","status":"done","summary":"3 variants ready for review"}'
```

**Uplift outputs when both scoops are done:**
- `/workspace/stardust/uplift-improvements.md` — 5 tensions
- `/workspace/stardust/current/brand-review.html` — brand review page
- `/workspace/stardust/current/_brand-extraction.json` — palette + type
- `/workspace/stardust/prototypes/home-A-proposed.html`
- `/workspace/stardust/prototypes/home-B-proposed.html`
- `/workspace/stardust/prototypes/home-C-cinematic.html`
- `/workspace/stardust/direction.md` — variant directions + recommendation

### Step 4 — Build deliverables & commit to EDS

The cone builds standalone deliverables and commits them to the EDS repo.

**Deliverable structure:**
```
{repo}/deliverables/
├── audit.html            ← standalone self-contained audit page
├── brand-review.html     ← standalone brand review page
├── variant-A.html        ← prototype A
├── variant-B.html        ← prototype B
├── variant-C.html        ← prototype C (cinematic)
```

**Steps:**

1. **Build audit.html:**
   - Read `/workspace/stardust/uplift-improvements.md`
   - Parse 5 tensions into JSON array: `[{"category":"...","title":"...","body":"..."},...]`
     Valid categories: `dated-pattern`, `ia-clutter`, `density`, `cliche`, `missed-opportunity`
   - Read `/workspace/skills/stardust-demo/templates/audit.html.tpl`
   - Replace `{{URL}}` and `{{TENSIONS_JSON}}` (data island — paste raw JSON, no escaping)
   - Write to `{repo}/deliverables/audit.html`

2. **Copy brand-review.html:**
   - `cp /workspace/stardust/current/brand-review.html {repo}/deliverables/brand-review.html`

3. **Copy prototypes:**
   - `cp /workspace/stardust/prototypes/home-A-proposed.html {repo}/deliverables/variant-A.html`
   - `cp /workspace/stardust/prototypes/home-B-proposed.html {repo}/deliverables/variant-B.html`
   - `cp /workspace/stardust/prototypes/home-C-cinematic.html {repo}/deliverables/variant-C.html`

4. **Commit & push:**
   ```bash
   cd {repo}
   git add deliverables/
   git commit -m "Add stardust deliverables — audit, brand review, 3 prototypes"
   git push origin {branch}
   ```

5. **Trigger EDS preview** so URLs are live:
   ```bash
   DA_TOKEN=$(oauth-token adobe)
   for page in audit brand-review variant-A variant-B variant-C; do
     curl -X POST -H "Authorization: Bearer $DA_TOKEN" \
       https://admin.hlx.page/preview/{owner}/{repo}/{branch}/deliverables/$page
   done
   ```

**EDS base URL:** `https://{branch}--{repo}--{owner}.aem.page/deliverables`

### Step 5 — Take screenshots from live EDS URLs

Screenshots MUST be taken from the live EDS URLs (not file:// paths):

```bash
EDS_BASE="https://{branch}--{repo}--{owner}.aem.page/deliverables"

# Open each variant in the browser
playwright-cli open "$EDS_BASE/variant-A.html"
sleep 4
playwright-cli screenshot --fullPage --max-width 480 /shared/{{SLUG}}-variant-A.png
playwright-cli tab-close

playwright-cli open "$EDS_BASE/variant-B.html"
sleep 4
playwright-cli screenshot --fullPage --max-width 480 /shared/{{SLUG}}-variant-B.png
playwright-cli tab-close

playwright-cli open "$EDS_BASE/variant-C.html"
sleep 4
playwright-cli screenshot --fullPage --max-width 480 /shared/{{SLUG}}-variant-C.png
playwright-cli tab-close
```

Keep screenshots under ~100KB each (use `--max-width 480`).

### Step 6 — Open sprinkles

Now that deliverables are live on EDS and screenshots are taken, open the 3 remaining sprinkles.

**EDS_BASE** = `https://{branch}--{repo}--{owner}.aem.page/deliverables`

#### 6a. Audit sprinkle (iframe)

1. Read `/workspace/skills/stardust-demo/templates/audit.shtml.tpl`
2. Replace `{{URL}}`, `{{AUDIT_URL}}` with `{EDS_BASE}/audit.html`
3. Write to `/shared/sprinkles/{{SLUG}}-audit/{{SLUG}}-audit.shtml`
4. Run: `sprinkle open {{SLUG}}-audit`

#### 6b. Brand review sprinkle (iframe)

1. Read `/workspace/skills/stardust-demo/templates/brand-review.shtml.tpl`
2. Replace `{{URL}}`, `{{BRAND_REVIEW_URL}}` with `{EDS_BASE}/brand-review.html`
3. Write to `/shared/sprinkles/{{SLUG}}-brand-review/{{SLUG}}-brand-review.shtml`
4. Run: `sprinkle open {{SLUG}}-brand-review`

#### 6c. Variants sprinkle (interactive)

1. Read `/workspace/stardust/direction.md` — extract:
   - Per variant: key (A/B/C), title, pitch, what-if question, moves array, role
   - Which variant is recommended
   - Shared fixes across all variants
2. Convert screenshots to base64 data URIs:
   ```bash
   SCREENSHOT_A=$(base64 < /shared/{{SLUG}}-variant-A.png)
   SCREENSHOT_B=$(base64 < /shared/{{SLUG}}-variant-B.png)
   SCREENSHOT_C=$(base64 < /shared/{{SLUG}}-variant-C.png)
   ```
3. Read `/workspace/skills/stardust-demo/templates/variants.shtml.tpl`
4. Replace `{{URL}}` and `{{SLUG}}`
5. Replace `{{VARIANTS_JSON}}` with a single JSON object in the data island:
   ```json
   {
     "variants": [
       {
         "key": "A",
         "url": "{EDS_BASE}/variant-A.html",
         "screenshot": "data:image/png;base64,{SCREENSHOT_A}",
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
6. Write to `/shared/sprinkles/{{SLUG}}-variants/{{SLUG}}-variants.shtml`
   - **Check file size** — must be under 350KB total. If over, reduce screenshot quality.
7. Run: `sprinkle open {{SLUG}}-variants`

### Step 7 — Wait for variant selection (lick)

The variants sprinkle fires a lick when the user clicks "Deploy":
```json
{"action": "select-variant", "data": {"variant": "B"}}
```

**Note:** The lick uses `data: {variant: "B"}` — NOT a sibling `variant` key. The sprinkle bridge strips sibling keys; only `action` and `data` are preserved.

When the cone receives this lick:
1. Confirm with the user: "Deploy variant {{VARIANT}}? This will convert it to an EDS site."
2. If confirmed, proceed to Step 8
3. If the user wants a different variant, wait for another lick

**Cherry follower limitation:** Cherry followers cannot open URLs from within sprinkles (iframe sandbox blocks navigation). When a user wants to preview a variant, post the EDS URL as a clickable link in chat instead.

### Step 8 — Deploy (scoop)

1. Push pipeline status FIRST:
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
   - NOTE: If admin.da.live is domain-restricted, use slicc.fetch or
     playwright-cli fetch as a proxied alternative.

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

### Step 9 — Report

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
- If reuse: skip Steps 2-3, go straight to Step 4 (deliverables)
- If re-run: clear `/workspace/stardust/` and start fresh

## Lick Events

| Lick | Source | Cone action |
|------|--------|-------------|
| `{action: "select-variant", data: {variant: "A\|B\|C"}}` | variants sprinkle | Confirm with user, spawn deploy |

## Known Limitations

- **Cherry followers can't open URLs from sprinkles** — iframe sandbox blocks navigation. Workaround: cone posts clickable URLs in chat.
- **DA API domain restriction** — `admin.da.live` may not be in the domain allowlist. Workaround: use `slicc.fetch` or `playwright-cli fetch` for DA operations.
- **Sprinkle file size limit** — keep under ~350KB total. Screenshots must use `--max-width 480` to stay small enough for base64 embedding.
- **Sprinkle overwrite doesn't push to followers** — always mint fresh names, never reuse.

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
