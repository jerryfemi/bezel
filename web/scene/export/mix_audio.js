// Mixes every sound in the clip (music clips, and the sound of screen
// recordings) into one stereo track for export, using an OfflineAudioContext.
import { scheduleLevel } from '../sound_level.js';

export const SAMPLE_RATE = 48000;

/** Resolves with an AudioBuffer of `duration` seconds, or null if the clip is silent. */
export async function mixAudio(assets, tracks, duration) {
  const sources = [
    ...tracks.audio,
    ...tracks.screens.filter((c) => assets.get(c.assetId)?.kind === 'video'),
  ].filter((c) => !c.muted && (c.volume ?? 1) > 0 && c.start < duration);
  if (!sources.length) return null;

  const ctx = new OfflineAudioContext(2, Math.ceil(duration * SAMPLE_RATE), SAMPLE_RATE);
  let scheduled = 0;
  for (const clip of sources) {
    const buffer = await assets.decode(clip.assetId);
    if (!buffer) continue;
    const length = Math.min(clip.end, duration) - clip.start;
    if (length <= 0 || clip.inPoint >= buffer.duration) continue;
    const source = ctx.createBufferSource();
    source.buffer = buffer;
    const gain = ctx.createGain();
    scheduleLevel(gain, clip, clip.start + length);
    source.connect(gain).connect(ctx.destination);
    source.start(clip.start, clip.inPoint, length);
    scheduled++;
  }
  return scheduled ? ctx.startRendering() : null;
}
