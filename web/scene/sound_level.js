// How loud a clip is at time t: its volume (0 when muted), shaped by its
// fade-in and fade-out. Shared by preview playback and the export mix.
export function levelAt(clip, t) {
  if (clip.muted) return 0;
  const volume = Math.max(0, Math.min(1, clip.volume ?? 1));
  const fadeIn = clip.fadeIn ?? 0;
  const fadeOut = clip.fadeOut ?? 0;
  let shape = 1;
  if (fadeIn > 0) shape = Math.min(shape, (t - clip.start) / fadeIn);
  if (fadeOut > 0) shape = Math.min(shape, (clip.end - t) / fadeOut);
  return volume * Math.max(0, Math.min(1, shape));
}

/** Schedules the same level curve on a Web Audio gain, for the export mix. */
export function scheduleLevel(gain, clip, end) {
  const volume = clip.muted ? 0 : Math.max(0, Math.min(1, clip.volume ?? 1));
  const fadeIn = Math.min(clip.fadeIn ?? 0, end - clip.start);
  const fadeOut = Math.min(clip.fadeOut ?? 0, end - clip.start - fadeIn);
  const g = gain.gain;
  g.setValueAtTime(fadeIn > 0 ? 0 : volume, clip.start);
  if (fadeIn > 0) g.linearRampToValueAtTime(volume, clip.start + fadeIn);
  if (fadeOut > 0) {
    g.setValueAtTime(volume, end - fadeOut);
    g.linearRampToValueAtTime(0, end);
  }
}
