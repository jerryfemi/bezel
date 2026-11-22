// Everything behind the device, drawn in 2D at the canvas's pixel size and
// used as the scene background: the colour, spotlight or image, and the caption.
// Because it is part of the 3D canvas, it is part of every exported frame.
import * as THREE from './vendor/three_bundle.js';
import { drawCaption, loadCaptionFont } from './caption.js';
import { resolveSide, captionBox, placeDevice } from './layout.js';

export function createBackdrop(stage, pivot) {
  const canvas = document.createElement('canvas');
  const g = canvas.getContext('2d');
  const texture = new THREE.CanvasTexture(canvas);
  texture.colorSpace = THREE.SRGBColorSpace;
  stage.scene.background = texture;

  let background = { style: 'spotlight', color: '#1A1F2B' };
  let image = null;
  let caption = { enabled: false };

  const draw = () => {
    const { width: w, height: h } = stage.renderer.domElement;
    if (!w || !h) return;
    if (canvas.width !== w || canvas.height !== h) {
      Object.assign(canvas, { width: w, height: h });
      texture.dispose(); // GPU texture size is fixed after upload; reallocate
    }
    paintBackground(g, background, image, w, h);
    const side = resolveSide(caption, w / h);
    placeDevice(pivot, side, w / h);
    if (side !== 'none') {
      const colors = textColors(background, image);
      drawCaption(g, caption, captionBox(side, w, h), side === 'above' ? 'center' : 'left', colors);
    }
    texture.needsUpdate = true;
    stage.invalidate();
  };
  stage.onResize.push(draw);
  loadCaptionFont().then(draw);

  return {
    async setBackground(next) {
      background = next;
      image = next.style === 'image' && next.imageUrl ? await loadImage(next.imageUrl) : null;
      draw();
    },
    setCaption(next) { caption = next; draw(); },
    redraw: draw,
    dispose() { texture.dispose(); },
  };
}

function paintBackground(g, bg, image, w, h) {
  g.fillStyle = bg.color;
  g.fillRect(0, 0, w, h);
  if (bg.style === 'spotlight') {
    const grad = g.createRadialGradient(w * 0.5, h * 0.35, 0, w * 0.5, h * 0.35, Math.max(w, h) * 0.75);
    grad.addColorStop(0, shade(bg.color, 0.22));
    grad.addColorStop(1, shade(bg.color, -0.35));
    g.fillStyle = grad;
    g.fillRect(0, 0, w, h);
  }
  if (image) {
    const s = Math.max(w / image.width, h / image.height);
    const iw = image.width * s;
    const ih = image.height * s;
    g.drawImage(image, (w - iw) / 2, (h - ih) / 2, iw, ih);
  }
}

/** Dark text on light backgrounds, light text otherwise. */
function textColors(bg, image) {
  const light = !image && luminance(bg.color) > 0.5;
  return light
    ? { headline: '#111114', subtitle: '#4A4A52' }
    : { headline: '#F5F5F7', subtitle: '#B4B8C2' };
}

function rgb(hex) {
  const n = parseInt(hex.replace('#', ''), 16);
  return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
}

function luminance(hex) {
  const [r, g, b] = rgb(hex).map((v) => v / 255);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/** Lightens (amount > 0) or darkens (amount < 0) a hex colour. */
function shade(hex, amount) {
  const mix = amount > 0 ? 255 : 0;
  const k = Math.abs(amount);
  const [r, g, b] = rgb(hex).map((v) => Math.round(v + (mix - v) * k));
  return `rgb(${r}, ${g}, ${b})`;
}

function loadImage(url) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve(img);
    img.onerror = reject;
    img.src = url;
  });
}
