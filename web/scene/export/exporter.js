// Renders the clip frame by frame at an exact size and encodes it. Every
// frame uses the same pose, caption and screen logic as the live preview, so
// the file matches what the user saw.
import { poseAt } from '../player.js';
import { createVideoEncoder } from './encode_video.js';
import { createGifEncoder, GIF_FPS } from './encode_gif.js';
import { mixAudio } from './mix_audio.js';
import { pickAudioCodec } from './encode_audio.js';

const STILL_CLIP_SECONDS = 3; // a clip with nothing timed exports as a 3 s hold

/**
 * `ctx`: {stage, timeline(), tracks(), duration(), applyPose(p), screen(), backdrop, assets, pause()}.
 * `settings`: {format: mp4|webm|gif|png, width, height, fps, name}.
 */
export async function exportClip(ctx, settings, onProgress, isCancelled) {
  const { stage } = ctx;
  const { format, width, height, name } = settings;
  const restoreSize = () => { stage.locked = false; stage.resize(); };
  ctx.pause();
  stage.locked = true;
  stage.setRenderSize(width, height, 1);

  try {
    if (format === 'png') {
      stage.renderer.render(stage.scene, stage.camera);
      const blob = await new Promise((r) => stage.renderer.domElement.toBlob(r, 'image/png'));
      return download(blob, `${name}.png`);
    }

    const fps = format === 'gif' ? GIF_FPS : settings.fps;
    const timeline = ctx.timeline();
    const duration = ctx.duration() > 0 ? ctx.duration() : STILL_CLIP_SECONDS;
    const total = Math.max(1, Math.round(duration * fps));

    let audio = null;
    if (format !== 'gif') {
      const codec = await pickAudioCodec(format);
      const buffer = codec ? await mixAudio(ctx.assets, ctx.tracks(), duration) : null;
      if (buffer) audio = { buffer, codec };
    }
    const encoder = format === 'gif'
      ? createGifEncoder({ width, height })
      : await createVideoEncoder({ format, width, height, fps, audio });

    for (let i = 0; i < total; i++) {
      if (isCancelled()) { encoder.cancel(); return null; }
      const t = i / fps;
      const pose = poseAt(timeline, t);
      if (pose) ctx.applyPose(pose);
      ctx.backdrop.setTime(t);
      await ctx.screen()?.prepareFrame(t);
      stage.renderer.render(stage.scene, stage.camera);
      await encoder.addFrame(stage.renderer.domElement, i);
      onProgress(i + 1, total);
      if (i % 4 === 0) await new Promise((r) => setTimeout(r, 0)); // let the UI breathe
    }
    const blob = await encoder.finish();
    return download(blob, `${name}.${format}`);
  } finally {
    restoreSize();
    ctx.restore?.();
  }
}

function download(blob, filename) {
  const url = URL.createObjectURL(blob);
  const a = Object.assign(document.createElement('a'), { href: url, download: filename });
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 10_000);
  return { filename, bytes: blob.size };
}
