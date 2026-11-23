// The screen's starting picture: a switched-off black display with a soft
// glass sheen and a quiet prompt to add a screen. Drawn on a canvas, so
// there is no asset to download.

export function drawDefaultWallpaper(aspect) {
  const h = 1600;
  const w = Math.round(h * aspect);
  const canvas = Object.assign(document.createElement('canvas'), { width: w, height: h });
  const g = canvas.getContext('2d');

  g.fillStyle = '#050506';
  g.fillRect(0, 0, w, h);

  // A faint diagonal reflection, like light across glass.
  const sheen = g.createLinearGradient(0, 0, w, h);
  sheen.addColorStop(0, 'rgba(255,255,255,0.07)');
  sheen.addColorStop(0.35, 'rgba(255,255,255,0.015)');
  sheen.addColorStop(0.36, 'rgba(255,255,255,0)');
  sheen.addColorStop(1, 'rgba(255,255,255,0.02)');
  g.fillStyle = sheen;
  g.fillRect(0, 0, w, h);

  // Prompt: an upload arrow in a ring, then two lines of text.
  const cx = w / 2;
  const cy = h * 0.47;
  const r = w * 0.085;
  g.strokeStyle = 'rgba(255,255,255,0.55)';
  g.lineWidth = w * 0.006;
  g.lineCap = 'round';
  g.beginPath(); g.arc(cx, cy, r, 0, Math.PI * 2); g.stroke();
  g.beginPath();
  g.moveTo(cx, cy + r * 0.42); g.lineTo(cx, cy - r * 0.42);
  g.moveTo(cx - r * 0.32, cy - r * 0.1); g.lineTo(cx, cy - r * 0.42); g.lineTo(cx + r * 0.32, cy - r * 0.1);
  g.stroke();

  g.textAlign = 'center';
  g.textBaseline = 'top';
  g.fillStyle = 'rgba(255,255,255,0.85)';
  g.font = `600 ${Math.round(w * 0.05)}px Inter, system-ui, sans-serif`;
  g.fillText('Tap to add your screen', cx, cy + r * 1.6);
  g.fillStyle = 'rgba(255,255,255,0.45)';
  g.font = `400 ${Math.round(w * 0.036)}px Inter, system-ui, sans-serif`;
  g.fillText('Screenshot or screen recording', cx, cy + r * 1.6 + w * 0.08);
  return canvas;
}
