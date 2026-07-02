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
- **Use EDS URLs for screenshots** in the variants sprinkle (commit .png files to deliverables/)
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
4. Replace `{{INITIAL_STATE_JSON}}` with the initial state (extract=active, rest pending):
   ```json
   {"steps":[
     {"id":"extract","status":"active","summary":"Crawling homepage...","link":null},
     {"id":"audit","status":"pending","summary":"Identify design tensions","link":null},
     {"id":"brand-review","status":"pending","summary":"Extract palette, type, motifs","link":null},
     {"id":"direction","status":"pending","summary":"Define 3 variant directions","link":null},
     {"id":"prototypes","status":"pending","summary":"Generate 3 variant prototypes","link":null},
     {"id":"deploy","status":"pending","summary":"Convert to EDS site","link":null}
   ]}
   ```
5. Write to `/shared/sprinkles/{{SLUG}}-pipeline/{{SLUG}}-pipeline.shtml`
6. Run: `sprinkle open {{SLUG}}-pipeline`
7. Push initial status:
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

**When scoop completes, the cone IMMEDIATELY:**

1. Pushes pipeline updates:
   ```
   sprinkle send {{SLUG}}-pipeline '{"step":"extract","status":"done","summary":"Homepage crawled"}'
   sprinkle send {{SLUG}}-pipeline '{"step":"audit","status":"done","summary":"5 tensions identified"}'
   sprinkle send {{SLUG}}-pipeline '{"step":"brand-review","status":"done","summary":"Palette + type extracted"}'
   ```

2. Commits audit + brand-review deliverables to EDS (so sprinkles can reference them):
   - Build `audit.html` from template (see Step 4 for details)
   - Copy `brand-review.html` from workspace
   - `git add deliverables/ && git commit && git push`
   - Trigger EDS preview for both pages

3. Opens audit + brand-review sprinkles (don't wait for Phase 2):
   - Read `audit.shtml.tpl`, replace `{{URL}}`, `{{AUDIT_URL}}` → write & `sprinkle open`
   - Read `brand-review.shtml.tpl`, replace `{{URL}}`, `{{BRAND_REVIEW_URL}}` → write & `sprinkle open`

4. Then pushes direction as active and spawns Phase 2:
   ```
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

### Step 4 — Commit prototype deliverables, take screenshots, open variants sprinkle

Audit + brand-review are already committed and their sprinkles open (from Step 2).
Now handle prototypes + variants sprinkle.

**EDS_BASE** = `https://{branch}--{repo}--{owner}.aem.page/deliverables`

#### 4a. Commit prototypes to EDS

```bash
cd {repo}
cp /workspace/stardust/prototypes/home-A-proposed.html deliverables/variant-A.html
cp /workspace/stardust/prototypes/home-B-proposed.html deliverables/variant-B.html
cp /workspace/stardust/prototypes/home-C-cinematic.html deliverables/variant-C.html
git add deliverables/variant-A.html deliverables/variant-B.html deliverables/variant-C.html
git commit -m "Add variant prototypes"
git push origin {branch}
```

Trigger EDS preview:
```bash
DA_TOKEN=$(oauth-token adobe)
for page in variant-A variant-B variant-C; do
  curl -X POST -H "Authorization: Bearer $DA_TOKEN" \
    https://admin.hlx.page/preview/{owner}/{repo}/{branch}/deliverables/$page
done
```

#### 4b. Take screenshots from live EDS URLs

Screenshots MUST be from live EDS URLs (NEVER `file://` paths):

```bash
playwright-cli open "$EDS_BASE/variant-A.html"
sleep 4
playwright-cli screenshot --fullPage --max-width 1280 /shared/{{SLUG}}-variant-A.png
playwright-cli tab-close

playwright-cli open "$EDS_BASE/variant-B.html"
sleep 4
playwright-cli screenshot --fullPage --max-width 1280 /shared/{{SLUG}}-variant-B.png
playwright-cli tab-close

playwright-cli open "$EDS_BASE/variant-C.html"
sleep 4
playwright-cli screenshot --fullPage --max-width 1280 /shared/{{SLUG}}-variant-C.png
playwright-cli tab-close
```

Then commit screenshots to EDS too:
```bash
cp /shared/{{SLUG}}-variant-A.png {repo}/deliverables/variant-A.png
cp /shared/{{SLUG}}-variant-B.png {repo}/deliverables/variant-B.png
cp /shared/{{SLUG}}-variant-C.png {repo}/deliverables/variant-C.png
cd {repo}
git add deliverables/variant-A.png deliverables/variant-B.png deliverables/variant-C.png
git commit -m "Add variant screenshots"
git push origin {branch}
```

Trigger preview for images:
```bash
for page in variant-A.png variant-B.png variant-C.png; do
  curl -X POST -H "Authorization: Bearer $DA_TOKEN" \
    https://admin.hlx.page/preview/{owner}/{repo}/{branch}/deliverables/$page
done
```

#### 4c. Open variants sprinkle

1. Read `/workspace/stardust/direction.md` — extract:
   - Per variant: key (A/B/C), title, pitch, what-if question, moves array, role
   - Which variant is recommended
   - Shared fixes across all variants
2. Read `/workspace/skills/stardust-demo/templates/variants.shtml.tpl`
3. Replace `{{URL}}` and `{{SLUG}}`
4. Replace `{{VARIANTS_JSON}}` with a single JSON object in the data island.
   Use EDS URLs for screenshots and variant links (NOT base64, NOT file://):
   ```json
   {
     "variants": [
       {
         "key": "A",
         "url": "{EDS_BASE}/variant-A.html",
         "screenshot": "{EDS_BASE}/variant-A.png",
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
5. Write to `/shared/sprinkles/{{SLUG}}-variants/{{SLUG}}-variants.shtml`
6. Run: `sprinkle open {{SLUG}}-variants`

### Step 5 — Wait for variant selection (lick)

The variants sprinkle fires a lick when the user clicks "Deploy":
```json
{"action": "select-variant", "data": {"variant": "B"}}
```

**Note:** The lick uses `data: {variant: "B"}` — NOT a sibling `variant` key. The sprinkle bridge strips sibling keys; only `action` and `data` are preserved.

When the cone receives this lick:
1. Confirm with the user: "Deploy variant {{VARIANT}}? This will convert it to an EDS site."
2. If confirmed, proceed to Step 6
3. If the user wants a different variant, wait for another lick

**Cherry follower limitation:** Cherry followers cannot open URLs from within sprinkles (iframe sandbox blocks navigation). When a user wants to preview a variant, post the EDS URL as a clickable link in chat instead.

### Step 6 — Deploy

The deploy scoop handles everything: code conversion, git push, DA upload, and preview.

#### 6a. Push pipeline status

```
sprinkle send {{SLUG}}-pipeline '{"step":"deploy","status":"active","summary":"Deploying variant {{VARIANT}} to EDS..."}'
```

#### 6b. Spawn deploy scoop

```
scoop_scoop({
  name: "{{SLUG}}-deploy",
  writablePaths: ["/scoops/{{SLUG}}-deploy/", "/shared/", "/workspace/{REPO}/", "/mnt/"]
})
```

Feed the scoop:

```
## STEP 1 — MANDATORY

Run: read_file /workspace/skills/stardust/skills/deploy/SKILL.md
Then follow those instructions EXACTLY.

## Context

- Prototype to deploy: /workspace/stardust/prototypes/home-{{VARIANT}}-proposed.html
  (if variant C: /workspace/stardust/prototypes/home-C-cinematic.html)
- EDS repo: /workspace/{REPO}
- Org: {org}
- Repo: {repo}
- Branch: {branch}
- State dir: /shared/stardust-demo/

## DA Auth — IMPORTANT

The `oauth-token adobe` command returns an opaque token. This token works
for `admin.hlx.page` but NOT for `admin.da.live` (returns 401).

To write content to DA, use the mount command instead:

1. Mount DA:
   mount --source da://{org}/{repo} /mnt/da

2. Write content files:
   cp content/index.html /mnt/da/index.html
   cp content/nav.html /mnt/da/nav.html
   cp content/footer.html /mnt/da/footer.html

3. Trigger preview (hlx admin accepts the opaque token):
   DA_TOKEN=$(oauth-token adobe)
   curl -X POST -H "Authorization: Bearer $DA_TOKEN" \
     "https://admin.hlx.page/preview/{org}/{repo}/{branch}/index"
   curl -X POST -H "Authorization: Bearer $DA_TOKEN" \
     "https://admin.hlx.page/preview/{org}/{repo}/{branch}/nav"
   curl -X POST -H "Authorization: Bearer $DA_TOKEN" \
     "https://admin.hlx.page/preview/{org}/{repo}/{branch}/footer"

DO NOT use curl against admin.da.live — it will fail with 401.
Always use mount for DA writes.

## Git rules

- NEVER use `git add .` or `git add -A` — only add specific paths
- One commit + one push at the end

## Naming questions

If this is a multi-page deploy, you MUST ask naming questions.
Write them to /shared/stardust-demo/deploy-questions.json:
{"questions": ["question 1", "question 2", ...]}
Then STOP and wait for answers via feed_scoop.

## Output contract

Write to /shared/stardust-demo/deploy-status.json:
{"status":"done","preview_url":"https://{branch}--{repo}--{org}.aem.page/","summary":"..."}
```

**If deploy asks naming questions:**
- Read `/shared/stardust-demo/deploy-questions.json`
- Present questions to the user in chat
- Feed answers back: `feed_scoop("{{SLUG}}-deploy", "Answers: ...")`

#### 6c. On completion

When the deploy scoop finishes (status file written):

```
sprinkle send {{SLUG}}-pipeline '{"step":"deploy","status":"done","summary":"Live at {{PREVIEW_URL}}","link":"{{PREVIEW_URL}}"}'
```

**PREVIEW_URL** = `https://{branch}--{repo}--{org}.aem.page/`

### Step 7 — Report

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
- If reuse: skip Steps 2-3, go straight to Step 4 (prototypes + variants)
- If re-run: clear `/workspace/stardust/` and start fresh

## Lick Events

| Lick | Source | Cone action |
|------|--------|-------------|
| `{action: "select-variant", data: {variant: "A\|B\|C"}}` | variants sprinkle | Confirm with user, spawn deploy |

## Known Limitations

- **Cherry followers can't open URLs from sprinkles** — iframe sandbox blocks navigation. Workaround: cone posts clickable URLs in chat.
- **Sprinkle file size limit** — keep under ~350KB total. Use EDS URLs for images rather than base64 embedding.
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
