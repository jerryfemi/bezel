// Draws the headline and subtitle onto the backdrop canvas.
// Sizes are relative to the frame height so the layout holds at any export size.
const FONT = "'Inter', system-ui, -apple-system, 'Segoe UI', sans-serif";

/** Canvas text does not trigger web-font loading, so load Inter explicitly. */
export function loadCaptionFont() {
  if (!document.fonts?.load) return Promise.resolve();
  return Promise.all([
    document.fonts.load("700 48px 'Inter'"),
    document.fonts.load("400 24px 'Inter'"),
  ]).catch(() => {});
}

/** `box` is {x, y, w, h} in canvas pixels; `align` is 'left' or 'center'. */
export function drawCaption(g, caption, box, align, colors) {
  const { width: W, height: H } = g.canvas;
  // Scale by the smaller side so narrow frames don't get oversized text.
  const headSize = Math.round(Math.min(H * 0.085, W * 0.085));
  const subSize = Math.round(Math.min(H * 0.034, W * 0.04));
  g.textBaseline = 'top';
  g.textAlign = align;
  const x = align === 'center' ? box.x + box.w / 2 : box.x;

  g.font = `700 ${headSize}px ${FONT}`;
  if ('letterSpacing' in g) g.letterSpacing = `${-0.03 * headSize}px`;
  const head = wrap(g, caption.headline, box.w);
  g.font = `400 ${subSize}px ${FONT}`;
  if ('letterSpacing' in g) g.letterSpacing = '0px';
  const sub = wrap(g, caption.subtitle, box.w);

  const headLine = headSize * 1.08;
  const subLine = subSize * 1.45;
  const gap = sub.length && head.length ? headSize * 0.4 : 0;
  const total = head.length * headLine + gap + sub.length * subLine;
  let y = Math.max(box.y, box.y + (box.h - total) / 2);

  g.fillStyle = colors.headline;
  g.font = `700 ${headSize}px ${FONT}`;
  if ('letterSpacing' in g) g.letterSpacing = `${-0.03 * headSize}px`;
  for (const line of head) { g.fillText(line, x, y); y += headLine; }
  y += gap;

  g.fillStyle = colors.subtitle;
  g.font = `400 ${subSize}px ${FONT}`;
  if ('letterSpacing' in g) g.letterSpacing = '0px';
  for (const line of sub) { g.fillText(line, x, y); y += subLine; }
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
