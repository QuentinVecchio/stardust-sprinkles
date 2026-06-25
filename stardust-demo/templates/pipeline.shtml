<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <link rel="icon" href="workflow" />
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>wknd · pipeline</title>
  <style>
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
      --success-bg: rgba(95,150,105,0.10);
      --danger: #c0453f;
      --in-progress-bg: rgba(232,185,94,0.12);
      --display: "SF Pro Display", Inter, system-ui, sans-serif;
      --text: "SF Pro Text", Inter, system-ui, sans-serif;
      --mono: "SF Mono", "JetBrains Mono", ui-monospace, monospace;
      --ease: cubic-bezier(0.16, 1, 0.3, 1);
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    html, body {
      height: 100%;
      background: var(--bg);
      color: var(--fg);
      font-family: var(--text);
      font-size: 14px;
      -webkit-font-smoothing: antialiased;
    }

    .wrap {
      display: flex;
      flex-direction: column;
      height: 100%;
      overflow: hidden;
    }

    /* ── Subheader ── */
    .subheader {
      display: flex;
      align-items: center;
      justify-content: space-between;
      height: 46px;
      flex: none;
      padding: 0 14px;
      background: var(--surface);
      border-bottom: 1px solid var(--hairline-soft);
      position: sticky;
      top: 0;
      z-index: 10;
    }
    .sub-left { display: flex; align-items: center; gap: 8px; }
    .sub-right { display: flex; align-items: center; gap: 10px; }
    .eyebrow {
      font: 500 11px/1 var(--mono);
      letter-spacing: 0.16em;
      text-transform: uppercase;
      color: var(--amber-deep);
    }
    .sub-site { font-size: 13px; color: var(--fg-dim); }
    .last-checked { font: 400 10px/1 var(--mono); color: var(--fg-faint); }
    .refresh-btn {
      font: 500 11px/1 var(--mono);
      color: var(--amber-deep);
      background: none;
      border: 1px solid var(--hairline);
      border-radius: 6px;
      padding: 4px 8px;
      cursor: pointer;
      transition: background .15s;
    }
    .refresh-btn:hover { background: var(--sunken); }
    .refresh-btn.spinning { opacity: 0.6; pointer-events: none; }

    /* ── Scrollable steps area ── */
    .steps-scroll {
      flex: 1;
      overflow-y: auto;
    }

    /* ── Steps list ── */
    .steps {
      padding: 16px 14px;
      display: flex;
      flex-direction: column;
      gap: 0;
    }

    .step {
      display: flex;
      flex-direction: column;
      position: relative;
    }

    /* connector line */
    .step::before {
      content: '';
      position: absolute;
      left: 11px;
      top: 34px;
      bottom: -4px;
      width: 1px;
      background: var(--hairline-soft);
    }
    .step:last-child::before { display: none; }

    .step-row {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      padding: 10px 12px 10px 0;
      border-radius: 10px;
      transition: background .15s;
    }
    .step[data-status="in-progress"] .step-row {
      background: var(--in-progress-bg);
      border-left: 3px solid var(--amber);
      padding-left: 10px;
      border-radius: 0 10px 10px 0;
    }
    .step[data-status="done"] .step-row {
      background: var(--surface);
      border: 1px solid var(--hairline-soft);
      border-radius: 10px;
      margin-bottom: 4px;
      padding-left: 12px;
    }
    .step[data-status="pending"] .step-row {
      opacity: 0.5;
      padding-left: 0;
    }

    .step-icon {
      width: 24px;
      height: 24px;
      border-radius: 50%;
      flex: none;
      display: grid;
      place-items: center;
      font-size: 11px;
      margin-top: 1px;
    }
    .step-icon.done { background: var(--success); color: #fff; font-weight: 700; }
    .step-icon.in-progress { background: var(--amber); color: #0a1024; }
    .step-icon.pending { background: transparent; border: 1.5px solid var(--fg-faint); }

    .step-content {
      flex: 1;
      min-width: 0;
      display: flex;
      flex-direction: column;
      gap: 2px;
    }
    .step-label {
      font: 600 13.5px/1.2 var(--display);
      color: var(--fg);
      letter-spacing: -0.01em;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .step-meta { font: 500 11.5px/1.4 var(--mono); color: var(--fg-dim); }
    .step-link {
      font: 500 11px/1 var(--mono);
      color: var(--amber-deep);
      text-decoration: none;
      letter-spacing: 0.04em;
    }
    .step-link:hover { text-decoration: underline; }

    /* ── Sub-steps ── */
    .substeps {
      display: flex;
      flex-direction: column;
      gap: 2px;
      margin: 4px 0 8px 34px;
    }
    .substep {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 5px 10px;
      border-radius: 7px;
      background: var(--surface);
      border: 1px solid var(--hairline-soft);
    }
    .substep[data-status="pending"] {
      opacity: 0.45;
      background: transparent;
      border-color: transparent;
    }
    .substep-icon {
      width: 16px;
      height: 16px;
      border-radius: 50%;
      flex: none;
      display: grid;
      place-items: center;
      font-size: 9px;
      font-weight: 700;
    }
    .substep-icon.done { background: var(--success); color: #fff; }
    .substep-icon.in-progress { background: var(--amber); color: #0a1024; }
    .substep-icon.pending { background: transparent; border: 1.5px solid var(--fg-faint); }

    .substep-label { font: 500 12px/1 var(--text); color: var(--fg-muted); flex: 1; }
    .substep-meta { font: 400 10.5px/1 var(--mono); color: var(--fg-faint); }
    .substep-link {
      font: 500 10px/1 var(--mono);
      color: var(--amber-deep);
      text-decoration: none;
    }
    .substep-link:hover { text-decoration: underline; }

    /* ── Detail list ── */
    .detail-list {
      margin: 3px 0 8px 34px;
      display: flex;
      flex-direction: column;
      gap: 3px;
    }
    .detail-item {
      font: 400 11.5px/1.4 var(--mono);
      color: var(--fg-dim);
      display: flex;
      gap: 6px;
    }
    .detail-item::before { content: '→'; color: var(--amber-deep); flex: none; }

    /* ── Animations ── */
    @keyframes riseIn {
      from { opacity: 0; transform: translateY(6px); }
      to   { opacity: 1; transform: none; }
    }
    @keyframes pulse {
      0%, 100% { opacity: 1; transform: scale(1); }
      50%       { opacity: 0.6; transform: scale(0.85); }
    }
    @keyframes spin {
      from { transform: rotate(0deg); }
      to   { transform: rotate(360deg); }
    }

    .stagger > * {
      opacity: 0;
      animation: riseIn .4s var(--ease) forwards;
      animation-play-state: paused;
    }
    body.ready .stagger > * { animation-play-state: running; }

    .stagger > *:nth-child(1) { animation-delay: .03s; }
    .stagger > *:nth-child(2) { animation-delay: .07s; }
    .stagger > *:nth-child(3) { animation-delay: .11s; }
    .stagger > *:nth-child(4) { animation-delay: .15s; }
    .stagger > *:nth-child(5) { animation-delay: .19s; }
    .stagger > *:nth-child(6) { animation-delay: .23s; }
    .stagger > *:nth-child(7) { animation-delay: .27s; }

    .in-progress-dot { animation: pulse 1.4s ease-in-out infinite; }

    .refresh-btn.spinning .btn-icon {
      display: inline-block;
      animation: spin .7s linear infinite;
    }

    /* ── Progress summary bar ── */
    .summary-bar {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 10px 14px;
      background: var(--surface);
      border-bottom: 1px solid var(--hairline-soft);
    }
    .progress-track {
      flex: 1;
      height: 4px;
      background: var(--hairline-soft);
      border-radius: 2px;
      overflow: hidden;
    }
    .progress-fill {
      height: 100%;
      background: var(--amber);
      border-radius: 2px;
      transition: width .6s var(--ease);
    }
    .progress-label {
      font: 500 10.5px/1 var(--mono);
      color: var(--fg-faint);
      white-space: nowrap;
    }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="subheader">
      <div class="sub-left">
        <span class="eyebrow">pipeline</span>
        <span class="sub-site">{{URL}}</span>
      </div>
      <div class="sub-right">
        <span id="last-checked" class="last-checked"></span>
        <button class="refresh-btn" id="refresh-btn" onclick="refreshStatus()">
          <span class="btn-icon">↺</span> refresh
        </button>
      </div>
    </div>

    <div class="summary-bar">
      <div class="progress-track">
        <div class="progress-fill" id="progress-fill" style="width: 0%"></div>
      </div>
      <span class="progress-label" id="progress-label"></span>
    </div>

    <div class="steps-scroll">
      <div class="steps stagger" id="steps-container"></div>
    </div>
  </div>

  <script>
    // ── Pipeline data ──────────────────────────────────────────────
    const PIPELINE = {
      site: '{{URL}}',
      steps: [
        {
          id: 'extract',
          label: 'Extract',
          status: 'done',
          meta: 'homepage captured · Jun 25',
          link: null,
          linkLabel: null
        },
        {
          id: 'audit',
          label: 'Audit',
          status: 'done',
          meta: '5 tensions found',
          link: '{{AUDIT_URL}}',
          linkLabel: 'view ↗'
        },
        {
          id: 'brand-review',
          label: 'Brand Review',
          status: 'done',
          meta: 'palette · typography · motifs extracted',
          link: '{{BRAND_REVIEW_URL}}',
          linkLabel: 'view ↗'
        },
        {
          id: 'direction',
          label: 'Direction',
          status: 'done',
          meta: '3 variants · editorial register',
          link: null,
          linkLabel: null,
          detail: [
            'A — Faithful + fixes (green-light)',
            'B — Amplify the photography ★ recommended',
            'C — Motion as identity (cinematic)'
          ]
        },
        {
          id: 'prototypes',
          label: 'Prototypes',
          status: 'done',
          meta: '3 variants generated',
          link: null,
          linkLabel: null,
          substeps: [
            { label: 'Variant A', status: 'done', link: '{{VARIANT_A_URL}}', linkLabel: 'view ↗' },
            { label: 'Variant B', status: 'done', link: '{{VARIANT_B_URL}}', linkLabel: 'view ↗' },
            { label: 'Variant C', status: 'done', link: '{{VARIANT_C_URL}}', linkLabel: 'view ↗' }
          ]
        },
        {
          id: 'deploy',
          label: 'Deploy',
          status: 'in-progress',
          meta: 'Variant B → stardust-demo-1',
          link: 'https://{{PREVIEW_URL}}/',
          linkLabel: 'preview ↗',
          substeps: [
            { label: 'Blocks built', status: 'done', meta: '5 blocks (hero · featured · articles · adventures · search)' },
            { label: 'Deliverables committed', status: 'done', meta: '15 artifacts in deliverables/wknd/' },
            { label: 'DA write', status: 'done', meta: 'nav · footer · index' },
            { label: 'Preview', status: 'done', meta: '{{PREVIEW_URL}}', link: 'https://{{PREVIEW_URL}}/', linkLabel: '↗' },
            { label: 'Publish', status: 'pending', meta: '—' }
          ]
        },
        {
          id: 'iterate',
          label: 'Iterate',
          status: 'pending',
          meta: '—',
          link: null,
          linkLabel: null
        }
      ]
    };

    // ── Helpers ────────────────────────────────────────────────────
    function iconHTML(status, size) {
      const isSmall = size === 'small';
      const dim = isSmall ? 16 : 24;
      const cls = `${isSmall ? 'substep-icon' : 'step-icon'} ${status}`;
      if (status === 'done') {
        return `<span class="${cls}" style="width:${dim}px;height:${dim}px">✓</span>`;
      }
      if (status === 'in-progress') {
        return `<span class="${cls} in-progress-dot" style="width:${dim}px;height:${dim}px">
          <svg width="${isSmall ? 8 : 10}" height="${isSmall ? 8 : 10}" viewBox="0 0 10 10" fill="none">
            <circle cx="5" cy="5" r="4" fill="#0a1024" opacity="0.75"/>
          </svg>
        </span>`;
      }
      // pending
      return `<span class="${cls}" style="width:${dim}px;height:${dim}px"></span>`;
    }

    function linkHTML(link, linkLabel, cls) {
      if (!link) return '';
      return `<a class="${cls}" href="${link}" target="_blank" rel="noopener">${linkLabel || 'view →'}</a>`;
    }

    // ── Render ─────────────────────────────────────────────────────
    function renderPipeline(steps) {
      const container = document.getElementById('steps-container');
      container.innerHTML = '';

      steps.forEach(function(step) {
        const el = document.createElement('div');
        el.className = 'step';
        el.setAttribute('data-status', step.status);
        el.setAttribute('data-id', step.id);

        // Step row
        let rowInner = iconHTML(step.status, 'large');
        rowInner += `<div class="step-content">
          <div class="step-label">
            ${escHtml(step.label)}
            ${linkHTML(step.link, step.linkLabel, 'step-link')}
          </div>
          <div class="step-meta">${escHtml(step.meta || '')}</div>
        </div>`;

        const row = document.createElement('div');
        row.className = 'step-row';
        row.innerHTML = rowInner;
        el.appendChild(row);

        // Detail list
        if (step.detail && step.detail.length) {
          const dl = document.createElement('div');
          dl.className = 'detail-list';
          step.detail.forEach(function(item) {
            const d = document.createElement('div');
            d.className = 'detail-item';
            d.textContent = item;
            dl.appendChild(d);
          });
          el.appendChild(dl);
        }

        // Sub-steps
        if (step.substeps && step.substeps.length) {
          const ss = document.createElement('div');
          ss.className = 'substeps';
          step.substeps.forEach(function(sub, i) {
            const subId = step.id + '-substep-' + i;
            const subEl = document.createElement('div');
            subEl.className = 'substep';
            subEl.setAttribute('data-status', sub.status);
            subEl.setAttribute('data-substep', subId);

            let inner = iconHTML(sub.status, 'small');
            inner += `<span class="substep-label">${escHtml(sub.label)}</span>`;
            if (sub.meta && sub.meta !== '—') {
              inner += `<span class="substep-meta">${escHtml(sub.meta)}</span>`;
            }
            if (sub.link) {
              inner += linkHTML(sub.link, sub.linkLabel, 'substep-link');
            }
            subEl.innerHTML = inner;
            ss.appendChild(subEl);
          });
          el.appendChild(ss);
        }

        container.appendChild(el);
      });

      updateProgress(steps);
    }

    function escHtml(s) {
      return String(s)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
    }

    // ── Progress bar ───────────────────────────────────────────────
    function updateProgress(steps) {
      const total = steps.length;
      const done = steps.filter(function(s) { return s.status === 'done'; }).length;
      const inProg = steps.filter(function(s) { return s.status === 'in-progress'; }).length;
      const pct = Math.round(((done + inProg * 0.5) / total) * 100);
      document.getElementById('progress-fill').style.width = pct + '%';
      document.getElementById('progress-label').textContent = done + ' / ' + total + ' done';
    }

    // ── Refresh ────────────────────────────────────────────────────
    async function refreshStatus() {
      const btn = document.getElementById('refresh-btn');
      btn.classList.add('spinning');

      try {
        const res = await slicc.fetch('https://admin.hlx.page/status/{{ORG}}/{{REPO}}/{{BRANCH}}/');
        const data = await res.json();
        const liveStatus = data && data.live && data.live.status;

        // If published (live returns 200), mark publish sub-step done
        if (liveStatus === 200) {
          const deployStep = PIPELINE.steps.find(function(s) { return s.id === 'deploy'; });
          if (deployStep && deployStep.substeps) {
            const publishSub = deployStep.substeps.find(function(s) { return s.label === 'Publish'; });
            if (publishSub && publishSub.status !== 'done') {
              publishSub.status = 'done';
              publishSub.meta = 'published to aem.live';
              deployStep.status = 'done';
              deployStep.meta = 'Variant B → stardust-demo-1 · live';
              // check if all steps done; if so update iterate
              renderPipeline(PIPELINE.steps);
            }
          }
        }

        document.getElementById('last-checked').textContent =
          'checked ' + new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
      } catch (e) {
        // silent fail — just update timestamp
        document.getElementById('last-checked').textContent =
          'checked ' + new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
      } finally {
        btn.classList.remove('spinning');
      }
    }

    // ── slicc update handler ───────────────────────────────────────
    slicc.on('update', function(data) {
      if (!data) return;

      // Allow external pushes to update a step or substep status
      if (data.action === 'update-step' && data.stepId) {
        const step = PIPELINE.steps.find(function(s) { return s.id === data.stepId; });
        if (step) {
          if (data.status) step.status = data.status;
          if (data.meta)   step.meta   = data.meta;
          if (data.link)   step.link   = data.link;
          renderPipeline(PIPELINE.steps);
        }
      }

      if (data.action === 'update-substep' && data.stepId && data.substepLabel) {
        const step = PIPELINE.steps.find(function(s) { return s.id === data.stepId; });
        if (step && step.substeps) {
          const sub = step.substeps.find(function(s) { return s.label === data.substepLabel; });
          if (sub) {
            if (data.status) sub.status = data.status;
            if (data.meta)   sub.meta   = data.meta;
            if (data.link)   sub.link   = data.link;
            renderPipeline(PIPELINE.steps);
          }
        }
      }

      // Full pipeline replacement
      if (data.action === 'replace-pipeline' && data.steps) {
        PIPELINE.steps = data.steps;
        renderPipeline(PIPELINE.steps);
      }
    });

    // ── Boot ───────────────────────────────────────────────────────
    renderPipeline(PIPELINE.steps);
    setTimeout(function() { document.body.classList.add('ready'); }, 50);

    // Auto-refresh every 30 seconds
    setInterval(refreshStatus, 30000);
    // Initial status check after 1s
    setTimeout(refreshStatus, 1000);
  </script>
</body>
</html>
