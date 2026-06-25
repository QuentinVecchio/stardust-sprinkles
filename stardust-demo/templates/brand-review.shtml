<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Brand Review · {{URL}}</title>
  <link rel="icon" href="palette" />
  <style>
    :root {
      --bg: #f5f0e6;
      --surface: #fffdf8;
      --sunken: #ece4d2;
      --amber: #e8b95e;
      --amber-deep: #c9822d;
      --fg: rgba(26,31,56,0.95);
      --fg-muted: rgba(26,31,56,0.72);
      --fg-dim: rgba(26,31,56,0.52);
      --fg-faint: rgba(26,31,56,0.30);
      --hairline-soft: rgba(26,31,56,0.08);
      --success: #5f9669;
      --display: "SF Pro Display", Inter, system-ui, sans-serif;
      --text: "SF Pro Text", Inter, system-ui, sans-serif;
      --mono: "SF Mono", "JetBrains Mono", ui-monospace, monospace;
      --ease: cubic-bezier(0.16, 1, 0.3, 1);
    }

    *, *::before, *::after {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    html, body {
      height: 100%;
      overflow: hidden;
    }

    body {
      display: flex;
      flex-direction: column;
      height: 100vh;
      background: var(--bg);
      color: var(--fg);
      font-family: var(--text);
    }

    /* Sticky subheader */
    .subheader {
      flex-shrink: 0;
      height: 46px;
      background: var(--surface);
      border-bottom: 1px solid var(--hairline-soft);
      display: flex;
      align-items: center;
      padding: 0 16px;
      gap: 10px;
    }

    .subheader__eyebrow {
      font-family: var(--mono);
      font-size: 10px;
      font-weight: 600;
      letter-spacing: 0.08em;
      text-transform: uppercase;
      color: var(--amber-deep);
    }

    .subheader__sep {
      width: 1px;
      height: 14px;
      background: var(--hairline-soft);
      flex-shrink: 0;
    }

    .subheader__site {
      font-family: var(--text);
      font-size: 13px;
      color: var(--fg-dim);
      font-weight: 400;
    }

    /* iframe fills remaining space */
    .preview-frame {
      flex: 1;
      width: 100%;
      border: none;
      background: var(--bg);
      display: block;
    }
  </style>
</head>
<body>
  <header class="subheader">
    <span class="subheader__eyebrow">Brand Review</span>
    <div class="subheader__sep"></div>
    <span class="subheader__site">{{URL}}</span>
  </header>
  <iframe
    class="preview-frame"
    src="{{BRAND_REVIEW_URL}}"
    title="{{URL}} Brand Review"
  ></iframe>
</body>
</html>
