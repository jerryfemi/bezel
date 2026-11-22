// The screen's starting picture, so a fresh device never looks switched off
// or empty. Drawn on a canvas: no asset to download.

export function drawDefaultWallpaper(aspect) {
  const h = 1600;
  const w = Math.round(h * aspect);
  const canvas = Object.assign(document.createElement('canvas'), { width: w, height: h });
  const g = canvas.getContext('2d');

  const base = g.createLinearGradient(0, 0, w * 0.4, h);
  base.addColorStop(0, '#1B2340');
  base.addColorStop(0.55, '#2A1E4A');
  base.addColorStop(1, '#0D1022');
  g.fillStyle = base;
  g.fillRect(0, 0, w, h);

  glow(g, w * 0.25, h * 0.3, w * 0.9, 'rgba(90, 140, 255, 0.55)');
  glow(g, w * 0.85, h * 0.7, w * 0.8, 'rgba(176, 108, 255, 0.45)');
  return canvas;
}

function glow(g, x, y, r, color) {
  const grad = g.createRadialGradient(x, y, 0, x, y, r);
  grad.addColorStop(0, color);
  grad.addColorStop(1, 'rgba(0, 0, 0, 0)');
  g.fillStyle = grad;
  g.fillRect(0, 0, g.canvas.width, g.canvas.height);
}
