// Draws the headline and subtitle onto the backdrop canvas, in one of a few
// type styles. Sizes are relative to the frame so the layout holds at any
// export size.

/** Headline/subtitle pairs. `slant` is a tangent (Archivo has no italic). */
const STYLES = {
  bricolage: {
    headline: { family: "'Bricolage Grotesque', sans-serif", weight: 800, stretch: 'normal', tracking: -0.035, caps: false, slant: 0, lineHeight: 0.95, size: 0.08 },
    subtitle: { family: "'Instrument Sans', sans-serif", weight: 400, stretch: 'normal', tracking: 0 },
  },
  archivo: {
    headline: { family: "'Archivo', sans-serif", weight: 900, stretch: 'expanded', tracking: -0.03, caps: true, slant: Math.tan(0.16), lineHeight: 1.02, size: 0.07 },
    subtitle: { family: "'Inter', sans-serif", weight: 400, stretch: 'normal', tracking: 0 },
  },
  inter: {
    headline: { family: "'Inter', sans-serif", weight: 700, stretch: 'normal', tracking: -0.025, caps: false, slant: 0, lineHeight: 1.05, size: 0.075 },
    subtitle: { family: "'Inter', sans-serif", weight: 400, stretch: 'normal', tracking: 0 },
  },
  instrumentSerif: {
    headline: { family: "'Instrument Serif', serif", weight: 400, stretch: 'normal', tracking: -0.01, caps: false, slant: 0, lineHeight: 1.0, size: 0.09 },
    subtitle: { family: "'Instrument Sans', sans-serif", weight: 400, stretch: 'normal', tracking: 0 },
  },
};

/** Canvas text does not trigger web-font loading, so load every caption font. */
export function loadCaptionFont() {
  if (!document.fonts?.load) return Promise.resolve();
  return Promise.all([
    "800 48px 'Bricolage Grotesque'", "900 expanded 48px 'Archivo'", "700 48px 'Inter'",
    "400 48px 'Instrument Serif'", "400 24px 'Instrument Sans'", "400 24px 'Inter'",
  ].map((f) => document.fonts.load(f))).catch(() => {});
}

/**
 * `box` is {x, y, w, h} in canvas pixels, `align` the default alignment.
 * Caption extras (all optional):
 *   size, subSize   scale of the headline / subtitle (1 = default)
 *   align           'left' | 'center' | 'right'
 *   dx, dy          offset of the whole caption, as fractions of the frame
 *   subDx, subDy    extra offset of the subtitle only (when pulled apart)
 *   hidden          'headline' | 'subtitle': measured but not drawn, while
 *                   the user types that part in place
 * Returns {head, sub}: each part's bounds in canvas pixels, or null if empty.
 */
export function drawCaption(g, caption, box, align, colors) {
  const { width: W, height: H } = g.canvas;
  const style = STYLES[caption.font] ?? STYLES.bricolage;
  const HEADLINE = style.headline;
  const SUBTITLE = style.subtitle;
  const scale = caption.size ?? 1;
  const subScale = caption.subSize ?? 1;
  // Scale by the smaller side so narrow frames don't get oversized text.
  const headSize = Math.round(Math.min(H, W) * HEADLINE.size * scale);
  const subSize = Math.round(Math.min(H * 0.034, W * 0.04) * subScale);
  const a = caption.align ?? align;
  const bx = box.x + (caption.dx ?? 0) * W;
  const by = box.y + (caption.dy ?? 0) * H;
  const x = a === 'center' ? bx + box.w / 2 : a === 'right' ? bx + box.w : bx;
  const sx = x + (caption.subDx ?? 0) * W;
  g.textBaseline = 'top';
  g.textAlign = a;

  use(g, HEADLINE, headSize);
  const text = caption.headline ?? '';
  const head = wrap(g, HEADLINE.caps ? text.toUpperCase() : text, box.w * Math.max(1, scale));
  const headW = Math.max(0, ...head.map((l) => g.measureText(l).width));
  use(g, SUBTITLE, subSize);
  const sub = wrap(g, caption.subtitle, box.w * Math.max(1, subScale));
  const subW = Math.max(0, ...sub.map((l) => g.measureText(l).width));

  const headLine = headSize * HEADLINE.lineHeight;
  const subLine = subSize * 1.45;
  const gap = sub.length && head.length ? headSize * 0.45 : 0;
  const total = head.length * headLine + gap + sub.length * subLine;
  const top = Math.max(by, by + (box.h - total) / 2);
  const subTop = top + head.length * headLine + gap + (caption.subDy ?? 0) * H;
  const edge = (ax, w) => (a === 'center' ? ax - w / 2 : a === 'right' ? ax - w : ax);
  const bounds = {
    head: head.length ? { x: edge(x, headW), y: top, w: headW, h: head.length * headLine } : null,
    sub: sub.length ? { x: edge(sx, subW), y: subTop, w: subW, h: sub.length * subLine } : null,
  };

  if (caption.hidden !== 'headline') {
    let y = top;
    g.fillStyle = colors.headline;
    use(g, HEADLINE, headSize);
    for (const line of head) {
      if (HEADLINE.slant) slanted(g, line, x, y, HEADLINE.slant); else g.fillText(line, x, y);
      y += headLine;
    }
  }
  if (caption.hidden !== 'subtitle') {
    let y = subTop;
    g.fillStyle = colors.subtitle;
    use(g, SUBTITLE, subSize);
    for (const line of sub) { g.fillText(line, sx, y); y += subLine; }
  }
  return bounds;
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
