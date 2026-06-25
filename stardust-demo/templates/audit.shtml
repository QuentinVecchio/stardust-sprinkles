<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>AUDIT · {{URL}}</title>
  <link rel="icon" href="triangle-alert" />
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
      --hairline-soft: rgba(26,31,56,0.08);
      --hairline: rgba(26,31,56,0.14);
      --success: #5f9669;
      --danger: #c0453f;
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
      line-height: 1.5;
      -webkit-font-smoothing: antialiased;
    }

    body {
      display: flex;
      flex-direction: column;
      overflow: hidden;
    }

    /* ── Sticky subheader ── */
    .subheader {
      flex-shrink: 0;
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 11px 20px 10px;
      background: var(--bg);
      border-bottom: 1px solid var(--hairline);
      position: sticky;
      top: 0;
      z-index: 10;
    }

    .subheader__eyebrow {
      font-family: var(--mono);
      font-size: 10px;
      font-weight: 700;
      letter-spacing: 0.08em;
      color: var(--amber-deep);
      text-transform: uppercase;
    }

    .subheader__sep {
      width: 1px;
      height: 14px;
      background: var(--hairline);
      flex-shrink: 0;
    }

    .subheader__site {
      font-family: var(--mono);
      font-size: 12px;
      color: var(--fg-dim);
      letter-spacing: 0.01em;
    }

    .subheader__spacer { flex: 1; }

    .subheader__pill {
      background: var(--sunken);
      color: var(--fg-dim);
      font-family: var(--mono);
      font-size: 11px;
      border-radius: 999px;
      padding: 4px 10px;
      white-space: nowrap;
    }

    /* ── Scrollable body ── */
    .scroll-body {
      flex: 1;
      overflow-y: auto;
      padding: 20px 20px 32px;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    /* ── Tension card ── */
    .tension-card {
      background: var(--surface);
      border: 1px solid var(--hairline-soft);
      border-radius: 13px;
      padding: 16px 18px;
      box-shadow: 0 1px 2px rgba(26,31,56,0.04);
      position: relative;
      padding-left: 22px; /* extra left room for accent bar */
      overflow: hidden;
    }

    .tension-card::before {
      content: '';
      position: absolute;
      left: 0;
      top: 0;
      bottom: 0;
      width: 3px;
      border-radius: 13px 0 0 13px;
    }

    /* Category accent colors */
    .tension-card--dated-pattern::before  { background: var(--danger); }
    .tension-card--ia-clutter::before     { background: var(--amber-deep); }
    .tension-card--density::before        { background: var(--fg-dim); }
    .tension-card--cliche::before         { background: var(--danger); }
    .tension-card--missed-opportunity::before { background: var(--success); }

    .tension-card__top {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 7px;
      gap: 8px;
    }

    .tension-card__number {
      font-family: var(--mono);
      font-size: 11px;
      color: var(--fg-faint);
      letter-spacing: 0.06em;
      margin-left: auto;
      flex-shrink: 0;
    }

    /* Category tag pills */
    .tag {
      display: inline-block;
      font-family: var(--mono);
      font-size: 10px;
      font-weight: 700;
      letter-spacing: 0.07em;
      text-transform: uppercase;
      border-radius: 999px;
      padding: 3px 9px;
    }

    .tag--dated-pattern {
      background: rgba(192,69,63,0.10);
      color: #c0453f;
    }
    .tag--ia-clutter {
      background: rgba(201,130,45,0.10);
      color: var(--amber-deep);
    }
    .tag--density {
      background: rgba(26,31,56,0.07);
      color: var(--fg-dim);
    }
    .tag--cliche {
      background: rgba(192,69,63,0.10);
      color: #c0453f;
    }
    .tag--missed-opportunity {
      background: rgba(95,150,105,0.10);
      color: var(--success);
    }

    .tension-card__title {
      font-family: var(--display);
      font-size: 15px;
      font-weight: 600;
      color: var(--fg);
      line-height: 1.35;
      margin-bottom: 8px;
    }

    .tension-card__body {
      font-family: var(--text);
      font-size: 13px;
      color: var(--fg-muted);
      line-height: 1.6;
    }

    /* ── Stagger animation ── */
    @keyframes riseIn {
      from { opacity: 0; transform: translateY(8px); }
      to   { opacity: 1; transform: none; }
    }

    .stagger > * {
      opacity: 0;
      animation: riseIn .5s var(--ease) forwards;
      animation-play-state: paused;
    }

    body.ready .stagger > * { animation-play-state: running; }

    .stagger > *:nth-child(1) { animation-delay: .04s; }
    .stagger > *:nth-child(2) { animation-delay: .10s; }
    .stagger > *:nth-child(3) { animation-delay: .16s; }
    .stagger > *:nth-child(4) { animation-delay: .22s; }
    .stagger > *:nth-child(5) { animation-delay: .28s; }

    /* ── Scrollbar ── */
    .scroll-body::-webkit-scrollbar { width: 6px; }
    .scroll-body::-webkit-scrollbar-track { background: transparent; }
    .scroll-body::-webkit-scrollbar-thumb { background: var(--hairline); border-radius: 999px; }
  </style>
</head>
<body>

  <!-- Sticky subheader -->
  <header class="subheader">
    <span class="subheader__eyebrow">Audit</span>
    <span class="subheader__sep"></span>
    <span class="subheader__site">{{URL}}</span>
    <span class="subheader__spacer"></span>
    <span class="subheader__pill">5 tensions found</span>
  </header>

  <!-- Scrollable card list -->
  <div class="scroll-body">
    <div class="stagger" id="cards">

      <!-- 1. Dated Pattern -->
      <article class="tension-card tension-card--dated-pattern">
        <div class="tension-card__top">
          <span class="tag tag--dated-pattern">Dated Pattern</span>
          <span class="tension-card__number">01</span>
        </div>
        <h2 class="tension-card__title">Auto-advancing carousel hero reads as 2019 CMS template</h2>
        <p class="tension-card__body">The three-slide hero carousel (5000ms auto-advance, hard-cut transitions, text overlaid on image with a band of yellow) is the signature layout of every AEM/WordPress landing page from 2018–2020. Modern adventure brands (REI, Patagonia, Komoot) have moved to a single full-viewport hero image with scroll-driven reveal or a stacked editorial hero. The carousel also creates a CTA-type inconsistency ("View Trips" for an adventure vs "Full Article" for magazine content on slides 2–3) that erodes first-impression clarity.</p>
      </article>

      <!-- 2. IA / Clutter -->
      <article class="tension-card tension-card--ia-clutter">
        <div class="tension-card__top">
          <span class="tag tag--ia-clutter">IA / Clutter</span>
          <span class="tension-card__number">02</span>
        </div>
        <h2 class="tension-card__title">Discovery entry-point buried at the bottom of the page</h2>
        <p class="tension-card__body">"Where do you want to go?" (the keyword search field) is the fifth and final content section, positioned below two identical horizontal card rails. The primary intent of an adventure-travel visitor — finding and booking a trip — has the page's lowest real-estate priority. Above-the-fold contains only the rotating carousel with no immediate invitation to explore the catalogue.</p>
      </article>

      <!-- 3. Density -->
      <article class="tension-card tension-card--density">
        <div class="tension-card__top">
          <span class="tag tag--density">Density</span>
          <span class="tension-card__number">03</span>
        </div>
        <h2 class="tension-card__title">Two structurally identical card rails create density without hierarchy</h2>
        <p class="tension-card__body">Section 3 ("Recent Articles") and Section 4 ("Next Adventures") both use the exact same 4-up image-list rail component with the same visual weight, same card proportions, same heading treatment (Source Sans Pro 600 underline). There is no typographic, chromatic, or spatial differentiation between editorial content and bookable trips. The page density results in the featured article and featured adventure competing — two full-width featured teasers flank the identical rails with no breathing room.</p>
      </article>

      <!-- 4. Cliché -->
      <article class="tension-card tension-card--cliche">
        <div class="tension-card__top">
          <span class="tag tag--cliche">Cliché</span>
          <span class="tension-card__number">04</span>
        </div>
        <h2 class="tension-card__title">Photography cropped to thumbnails defeats the brand's primary visual asset</h2>
        <p class="tension-card__body">The page carries high-quality adventure photography (1180–1620px natural width) but renders 6 of 9 below-fold images at approximately 300px card thumbnail size. Every competitor in the adventure space uses oversized, edge-to-edge photography as its primary brand differentiator. Cropping Dolomites skiing, Australian bush, and New Zealand climbing photography to 300px thumbnail cards negates their power and makes WKND read like a news aggregator rather than an experiential travel brand.</p>
      </article>

      <!-- 5. Missed Opportunity -->
      <article class="tension-card tension-card--missed-opportunity">
        <div class="tension-card__top">
          <span class="tag tag--missed-opportunity">Missed Opportunity</span>
          <span class="tension-card__number">05</span>
        </div>
        <h2 class="tension-card__title">Asar's display serif character is suppressed below structural voice</h2>
        <p class="tension-card__body">Asar (a distinctive contrast serif loaded via Google Fonts) is used on exactly 3 elements on the homepage: the h2 titles in the hero carousel slides. All section titles, navigation, and CTAs use Source Sans Pro. The captured brand already owns a strong editorial display typeface that's never promoted to structural scope. Extending Asar to section titles, the featured article heading, and key display moments would give WKND a typographic personality that no AEM reference site currently has.</p>
      </article>

    </div>
  </div>

  <script>
    setTimeout(function () {
      document.body.classList.add('ready');
    }, 50);
  </script>
</body>
</html>
