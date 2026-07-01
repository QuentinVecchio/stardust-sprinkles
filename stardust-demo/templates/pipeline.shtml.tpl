<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <link rel="icon" href="workflow" />
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>{{SLUG}} · pipeline</title>
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
    .eyebrow {
      font: 500 11px/1 var(--mono);
      letter-spacing: 0.16em;
      text-transform: uppercase;
      color: var(--amber-deep);
    }
    .sub-site { font-size: 13px; color: var(--fg-dim); }

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
    .step[data-status="active"] .step-row {
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
    .step-icon.active { background: var(--amber); color: #0a1024; }
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

    /* ── Animations ── */
    @keyframes riseIn {
      from { opacity: 0; transform: translateY(6px); }
      to   { opacity: 1; transform: none; }
    }
    @keyframes pulse {
      0%, 100% { opacity: 1; transform: scale(1); }
      50%       { opacity: 0.6; transform: scale(0.85); }
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

    .active-dot { animation: pulse 1.4s ease-in-out infinite; }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="subheader">
      <div class="sub-left">
        <span class="eyebrow">pipeline</span>
        <span class="sub-site">{{URL}}</span>
      </div>
    </div>

    <div class="summary-bar">
      <div class="progress-track">
        <div class="progress-fill" id="progress-fill" style="width: 0%"></div>
      </div>
      <span class="progress-label" id="progress-label">0 / 6</span>
    </div>

    <div class="steps-scroll">
      <div class="steps stagger" id="steps-container"></div>
    </div>
  </div>

  <script>
    var STEPS = [
      { id: 'extract', label: 'Extract', summary: 'Crawl & capture homepage' },
      { id: 'audit', label: 'Audit', summary: 'Identify design tensions' },
      { id: 'brand-review', label: 'Brand Review', summary: 'Extract palette, type, motifs' },
      { id: 'direction', label: 'Direction', summary: 'Define 3 variant directions' },
      { id: 'prototypes', label: 'Prototypes', summary: 'Generate 3 variant prototypes' },
      { id: 'deploy', label: 'Deploy', summary: 'Convert to EDS site' }
    ];

    var state = {
      steps: STEPS.map(function(s) {
        return { id: s.id, status: 'pending', summary: s.summary, link: null };
      })
    };

    function iconHTML(status) {
      var cls = 'step-icon ' + status;
      if (status === 'done') {
        return '<span class="' + cls + '">✓</span>';
      }
      if (status === 'active') {
        return '<span class="' + cls + ' active-dot"><svg width="10" height="10" viewBox="0 0 10 10" fill="none"><circle cx="5" cy="5" r="4" fill="#0a1024" opacity="0.75"/></svg></span>';
      }
      return '<span class="' + cls + '"></span>';
    }

    function render() {
      var container = document.getElementById('steps-container');
      container.innerHTML = '';

      state.steps.forEach(function(step) {
        var el = document.createElement('div');
        el.className = 'step';
        el.setAttribute('data-status', step.status);

        var linkHtml = step.link
          ? '<a class="step-link" href="' + step.link + '" target="_blank" rel="noopener">view ↗</a>'
          : '';

        el.innerHTML = '<div class="step-row">' +
          iconHTML(step.status) +
          '<div class="step-content">' +
            '<div class="step-label">' + step.id.replace(/-/g, ' ').replace(/\b\w/g, function(c) { return c.toUpperCase(); }) + ' ' + linkHtml + '</div>' +
            '<div class="step-meta">' + (step.summary || '—') + '</div>' +
          '</div>' +
        '</div>';

        container.appendChild(el);
      });

      updateProgress();
    }

    function updateProgress() {
      var total = state.steps.length;
      var done = state.steps.filter(function(s) { return s.status === 'done'; }).length;
      var active = state.steps.filter(function(s) { return s.status === 'active'; }).length;
      var pct = Math.round(((done + active * 0.5) / total) * 100);
      document.getElementById('progress-fill').style.width = pct + '%';
      document.getElementById('progress-label').textContent = done + ' / ' + total + ' done';
    }

    // Restore persisted state
    var saved = slicc.getState();
    if (saved && saved.steps && saved.steps.length === STEPS.length) {
      state = saved;
    }

    // Updates from cone
    slicc.on('update', function(data) {
      if (!data || !data.step) return;
      var idx = state.steps.findIndex(function(s) { return s.id === data.step; });
      if (idx === -1) return;

      if (data.status) state.steps[idx].status = data.status;
      if (data.summary) state.steps[idx].summary = data.summary;
      if (data.link) state.steps[idx].link = data.link;

      slicc.setState(state);
      render();
    });

    render();
    setTimeout(function() { document.body.classList.add('ready'); }, 50);
  </script>
</body>
</html>
