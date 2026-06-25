<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <link rel="icon" href="layout-panel-left" />
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>wknd · directions</title>
  <style>
    :root {
      --ink: #0a1024;
      --bg: #f5f0e6;
      --surface: #fffdf8;
      --sunken: #ece4d2;
      --paper: #f3eee4;
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
      font: 400 14px/1.55 var(--text);
      -webkit-font-smoothing: antialiased;
    }

    @keyframes riseIn {
      from { opacity: 0; transform: translateY(8px); }
      to   { opacity: 1; transform: none; }
    }

    .fade { opacity: 0; transition: opacity .34s var(--ease); }
    body.ready .fade { opacity: 1; }

    .stagger > * {
      opacity: 0;
      animation: riseIn .56s var(--ease) forwards;
      animation-play-state: paused;
    }
    body.ready .stagger > * { animation-play-state: running; }
    .stagger > *:nth-child(1) { animation-delay: .04s; }
    .stagger > *:nth-child(2) { animation-delay: .10s; }
    .stagger > *:nth-child(3) { animation-delay: .16s; }

    /* ── Shell ── */
    .wrap { display: flex; flex-direction: column; height: 100vh; }

    /* ── Sticky subheader ── */
    .subheader {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      height: 46px;
      flex: none;
      padding: 0 14px;
      background: var(--surface);
      border-bottom: 1px solid var(--hairline-soft);
      position: sticky;
      top: 0;
      z-index: 10;
    }
    .sub-left  { display: flex; align-items: center; gap: 10px; }
    .sub-right { display: flex; align-items: center; }
    .eyebrow   { font: 500 11px/1 var(--mono); letter-spacing: 0.16em; text-transform: uppercase; color: var(--amber-deep); }
    .sub-meta  { font-size: 13px; color: var(--fg-dim); }
    .sub-hint  { font: 500 12px/1 var(--mono); color: var(--amber-deep); cursor: pointer; }
    .sub-hint:hover { text-decoration: underline; }

    /* ── Scrollable body ── */
    .body {
      flex: 1;
      overflow-y: auto;
      padding: 14px;
      display: flex;
      flex-direction: column;
      gap: 14px;
      scrollbar-width: thin;
      scrollbar-color: var(--hairline) transparent;
    }

    /* ── Shared fixes banner ── */
    .shared {
      background: var(--surface);
      border: 1px solid var(--hairline-soft);
      border-radius: 13px;
      padding: 14px 16px;
      box-shadow: 0 1px 2px rgba(26,31,56,0.04);
    }
    .sh {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 10px;
    }
    .sh .e {
      font: 600 10px/1 var(--mono);
      letter-spacing: 0.14em;
      text-transform: uppercase;
      color: var(--amber-deep);
    }
    .sh .t  { font-size: 13px; color: var(--fg-muted); }
    .sh .t b { color: var(--fg); }
    .fixchips { display: flex; flex-wrap: wrap; gap: 7px; }
    .fixchip {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      font: 500 12px/1 var(--text);
      color: var(--fg-muted);
      background: var(--bg);
      border: 1px solid var(--hairline-soft);
      border-radius: 999px;
      padding: 6px 11px;
    }
    .fixchip .ck { color: var(--success); font-size: 11px; font-weight: 700; }

    /* ── Gallery ── */
    .gallery {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 14px;
      align-items: start;
    }
    @media (max-width: 600px) { .gallery { grid-template-columns: 1fr; } }

    /* ── Variant cards ── */
    .vcard {
      position: relative;
      border: 1px solid var(--hairline-soft);
      border-radius: 14px;
      overflow: hidden;
      background: var(--surface);
      box-shadow: 0 2px 8px -4px rgba(26,31,56,0.12);
      cursor: pointer;
      transition: transform .22s var(--ease), box-shadow .22s var(--ease);
      display: flex;
      flex-direction: column;
    }
    .vcard:hover {
      transform: translateY(-3px);
      box-shadow: 0 18px 40px -18px rgba(26,31,56,0.28);
    }
    .vcard.rec {
      box-shadow: 0 0 0 2px var(--amber), 0 18px 40px -20px rgba(201,130,45,0.4);
    }
    .vcard.rec:hover {
      box-shadow: 0 0 0 2px var(--amber), 0 22px 48px -18px rgba(201,130,45,0.45);
    }

    /* Thumbnail */
    .thumb {
      aspect-ratio: 16/10;
      overflow: hidden;
      background: var(--paper);
      border-bottom: 1px solid var(--hairline-soft);
      flex: none;
    }
    .thumb img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      object-position: top center;
      display: block;
    }

    /* Card body */
    .meta {
      padding: 13px 14px 15px;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    .top { display: flex; align-items: center; gap: 9px; }
    .k {
      width: 20px;
      height: 20px;
      border-radius: 5px;
      background: var(--sunken);
      display: grid;
      place-items: center;
      font: 600 11px/1 var(--mono);
      color: var(--fg-dim);
      flex: none;
    }
    .vcard.rec .k {
      background: var(--amber);
      color: var(--ink);
      box-shadow: inset 0 0 0 1px rgba(201,130,45,0.5);
    }
    .ttl {
      font: 600 15px/1.15 var(--display);
      letter-spacing: -0.01em;
      color: var(--fg);
    }
    .pitch {
      font-size: 13px;
      line-height: 1.45;
      color: var(--fg-muted);
      margin: 0;
    }

    /* What if box */
    .whatif {
      background: rgba(201,130,45,0.08);
      border: 1px solid rgba(201,130,45,0.22);
      border-radius: 9px;
      padding: 9px 11px;
    }
    .whatif .q {
      font: 600 9px/1 var(--mono);
      letter-spacing: 0.12em;
      text-transform: uppercase;
      color: var(--amber-deep);
      display: block;
      margin-bottom: 5px;
    }
    .whatif .qt {
      font-size: 12.5px;
      color: var(--fg);
      line-height: 1.4;
      font-style: italic;
    }

    /* Faithful line */
    .faithful {
      font: 500 12px/1.4 var(--mono);
      color: var(--fg-dim);
      padding: 4px 0;
    }

    /* Moves list */
    .moves {
      margin: 0;
      padding: 0;
      list-style: none;
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .moves .ml {
      font: 600 9px/1 var(--mono);
      letter-spacing: 0.1em;
      text-transform: uppercase;
      color: var(--fg-faint);
    }
    .moves li.m {
      display: flex;
      gap: 8px;
      align-items: baseline;
      font-size: 12.5px;
      color: var(--fg-muted);
      line-height: 1.4;
    }
    .moves li.m .a { color: var(--amber-deep); flex: none; }

    /* Role */
    .role {
      margin-top: 2px;
      font: 500 11px/1 var(--mono);
      letter-spacing: 0.04em;
      color: var(--fg-faint);
      padding-top: 8px;
      border-top: 1px solid var(--hairline-soft);
    }

    /* Rec pill */
    .recpill {
      position: absolute;
      top: 10px;
      right: 10px;
      z-index: 2;
      font: 600 9.5px/1 var(--mono);
      letter-spacing: 0.1em;
      text-transform: uppercase;
      color: var(--ink);
      background: var(--amber);
      padding: 5px 8px;
      border-radius: 6px;
      box-shadow: inset 0 0 0 1px rgba(201,130,45,0.5);
    }
  </style>
</head>
<body>
<div class="wrap">

  <!-- Sticky subheader -->
  <div class="subheader">
    <div class="sub-left">
      <span class="eyebrow">directions</span>
      <span class="sub-meta">3 variants · brand-faithful</span>
    </div>
    <div class="sub-right"></div>
  </div>

  <!-- Scrollable body -->
  <div class="body">

    <!-- Shared fixes banner -->
    <div class="shared fade">
      <div class="sh">
        <span class="e">all three fix</span>
        <span class="t"><b>5 tensions</b> resolved across every variant</span>
      </div>
      <div class="fixchips">
        <span class="fixchip"><span class="ck">✓</span> carousel → single hero</span>
        <span class="fixchip"><span class="ck">✓</span> search elevated to hero</span>
        <span class="fixchip"><span class="ck">✓</span> Asar promoted to headings</span>
        <span class="fixchip"><span class="ck">✓</span> card rails differentiated</span>
        <span class="fixchip"><span class="ck">✓</span> photography at proper scale</span>
      </div>
    </div>

    <!-- 3-col gallery -->
    <div class="gallery stagger">

      <!-- Card A -->
      <div class="vcard" data-url="{{VARIANT_A_URL}}">
        <div class="thumb">
          <img src="{{SCREENSHOT_A}}" alt="Variant A" loading="lazy" />
        </div>
        <div class="meta">
          <div class="top">
            <span class="k">A</span>
            <span class="ttl">Faithful + fixes</span>
          </div>
          <p class="pitch">Your site tomorrow — same IA, the obvious fixes. The risk-averse green-light.</p>
          <div class="faithful">no new bet · the 5 fixes, nothing else moves</div>
          <ul class="moves">
            <li class="ml">composition</li>
            <li class="m"><span class="a">→</span> carousel replaced with single hero</li>
            <li class="m"><span class="a">→</span> search field elevated to hero-adjacency</li>
          </ul>
          <div class="role">static · green-light pick</div>
        </div>
      </div>

      <!-- Card B — Recommended -->
      <div class="vcard rec" data-url="{{VARIANT_B_URL}}">
        <span class="recpill">★ recommended</span>
        <div class="thumb">
          <img src="{{SCREENSHOT_B}}" alt="Variant B" loading="lazy" />
        </div>
        <div class="meta">
          <div class="top">
            <span class="k">B</span>
            <span class="ttl">Amplify the photography</span>
          </div>
          <p class="pitch">The brand's most ownable asset, foregrounded — from thumbnail crop to the whole canvas.</p>
          <div class="whatif">
            <span class="q">what if</span>
            <span class="qt">photography &amp; the portrait 2:3 grid owned the page, not a thin card strip?</span>
          </div>
          <ul class="moves">
            <li class="ml">composition</li>
            <li class="m"><span class="a">→</span> 2-column portrait grid, title overlay on image</li>
            <li class="m"><span class="a">→</span> featured article as 60/40 editorial bleed</li>
            <li class="m"><span class="a">→</span> photography as primary design voice</li>
          </ul>
          <div class="role">static · brand exploration</div>
        </div>
      </div>

      <!-- Card C -->
      <div class="vcard" data-url="{{VARIANT_C_URL}}">
        <div class="thumb">
          <img src="{{SCREENSHOT_C}}" alt="Variant C" loading="lazy" />
        </div>
        <div class="meta">
          <div class="top">
            <span class="k">C</span>
            <span class="ttl">Motion as identity</span>
          </div>
          <p class="pitch">The site gains a third dimension — editorial cinematic register.</p>
          <div class="whatif">
            <span class="q">what if</span>
            <span class="qt">motion was woven into the brand identity — not decoration but voice?</span>
          </div>
          <ul class="moves">
            <li class="ml">motion</li>
            <li class="m"><span class="a">→</span> hero micro-parallax at editorial pace</li>
            <li class="m"><span class="a">→</span> section titles fade in at reading pace</li>
            <li class="m"><span class="a">→</span> card hover: gentle scale 1.02 at 900ms</li>
          </ul>
          <div class="role">cinematic · visionary pick</div>
        </div>
      </div>

    </div><!-- /gallery -->
  </div><!-- /body -->
</div><!-- /wrap -->

<script>
  setTimeout(() => document.body.classList.add('ready'), 50);
  document.querySelectorAll('.vcard[data-url]').forEach(c => {
    c.addEventListener('click', () => window.open(c.dataset.url, '_blank'));
  });
  slicc.on('update', function(data) {});
</script>
</body>
</html>
