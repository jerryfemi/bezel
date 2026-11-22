// Draws the headline and subtitle onto the backdrop canvas.
// Headline: Archivo Black (900) at its widest (125%), all caps, tracked −3%,
// slanted 9° in code (Archivo has no italic). Subtitle: Inter, for reading.
// Sizes are relative to the frame so the layout holds at any export size.
const HEADLINE = {
  family: "'Archivo', 'Inter', system-ui, sans-serif",
  weight: 900,
  stretch: 'expanded', // CSS keyword for 125%
  tracking: -0.03,
  slant: Math.tan(0.16), // same as Flutter's Matrix4.skewX(-0.16)
};
const SUBTITLE = { family: "'Inter', system-ui, sans-serif", weight: 400, stretch: 'normal', tracking: 0 };

/** Canvas text does not trigger web-font loading, so load the fonts explicitly. */
export function loadCaptionFont() {
  if (!document.fonts?.load) return Promise.resolve();
  return Promise.all([
    document.fonts.load("900 expanded 48px 'Archivo'"),
    document.fonts.load("400 24px 'Inter'"),
  ]).catch(() => {});
}

/** `box` is {x, y, w, h} in canvas pixels; `align` is 'left' or 'center'. */
export function drawCaption(g, caption, box, align, colors) {
  const { width: W, height: H } = g.canvas;
  // Scale by the smaller side so narrow frames don't get oversized text.
  const headSize = Math.round(Math.min(H, W) * 0.07);
  const subSize = Math.round(Math.min(H * 0.034, W * 0.04));
  g.textBaseline = 'top';
  g.textAlign = align;
  const x = align === 'center' ? box.x + box.w / 2 : box.x;

  use(g, HEADLINE, headSize);
  const head = wrap(g, (caption.headline ?? '').toUpperCase(), box.w);
  use(g, SUBTITLE, subSize);
  const sub = wrap(g, caption.subtitle, box.w);

  const headLine = headSize * 1.02;
  const subLine = subSize * 1.45;
  const gap = sub.length && head.length ? headSize * 0.45 : 0;
  const total = head.length * headLine + gap + sub.length * subLine;
  let y = Math.max(box.y, box.y + (box.h - total) / 2);

  g.fillStyle = colors.headline;
  use(g, HEADLINE, headSize);
  for (const line of head) { slanted(g, line, x, y, HEADLINE.slant); y += headLine; }
  y += gap;

  g.fillStyle = colors.subtitle;
  use(g, SUBTITLE, subSize);
  for (const line of sub) { g.fillText(line, x, y); y += subLine; }
}

function use(g, style, size) {
  g.font = `${style.weight} ${style.stretch} ${size}px ${style.family}`;
  if ('fontStretch' in g) g.fontStretch = style.stretch;
  if ('letterSpacing' in g) g.letterSpacing = `${style.tracking * size}px`;
}

/** Draws one line leaning right: lower parts shift left, like an italic. */
function slanted(g, text, x, y, slant) {
  g.save();
  g.translate(x, y);
  g.transform(1, 0, -slant, 1, 0, 0);
  g.fillText(text, 0, 0);
  g.restore();
}

/** Greedy word wrap to `maxWidth` with the context's current font. */
function wrap(g, text, maxWidth) {
  const lines = [];
  for (const para of (text ?? '').split('\n')) {
    let line = '';
    for (const word of para.split(/\s+/).filter(Boolean)) {
      const next = line ? `${line} ${word}` : word;
      if (line && g.measureText(next).width > maxWidth) { lines.push(line); line = word; } else line = next;
    }
    if (line) lines.push(line);
  }
  return lines;
}
