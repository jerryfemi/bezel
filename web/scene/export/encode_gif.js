// Looping GIF. Frames are scaled down (GIFs get huge fast) and each gets its
// own 256-colour palette.
import { GIFEncoder, quantize, applyPalette } from '../vendor/encoders_bundle.js';

export const GIF_MAX_SIDE = 720;
export const GIF_FPS = 20;

export function createGifEncoder({ width, height }) {
  const scale = Math.min(1, GIF_MAX_SIDE / Math.max(width, height));
  const w = Math.round(width * scale);
  const h = Math.round(height * scale);
  const scratch = Object.assign(document.createElement('canvas'), { width: w, height: h });
  const g = scratch.getContext('2d', { willReadFrequently: true });
  const gif = GIFEncoder();

  return {
    async addFrame(canvas) {
      g.drawImage(canvas, 0, 0, w, h);
      const { data } = g.getImageData(0, 0, w, h);
      const palette = quantize(data, 256);
      gif.writeFrame(applyPalette(data, palette), w, h, { palette, delay: 1000 / GIF_FPS });
    },
    async finish() {
      gif.finish();
      return new Blob([gif.bytes()], { type: 'image/gif' });
    },
    cancel() {},
  };
}
