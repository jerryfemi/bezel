// Plays a timeline of keyframes on the device. The same `poseAt` drives the
// live preview and (in export) each rendered frame, so they always match.
import { apply } from './easing.js';

/** The pose at time `t` (seconds) on `timeline`. */
export function poseAt(timeline, t) {
  const keys = timeline?.keyframes ?? [];
  if (!keys.length) return null;
  if (t <= keys[0].time) return pick(keys[0]);
  const last = keys[keys.length - 1];
  if (t >= last.time) return pick(last);
  let i = 0;
  while (keys[i + 1].time < t) i++;
  const a = keys[i];
  const b = keys[i + 1];
  const span = b.time - a.time;
  const p = span <= 0 ? 1 : apply(b.easing, (t - a.time) / span);
  return {
    turn: a.turn + (b.turn - a.turn) * p,
    tilt: a.tilt + (b.tilt - a.tilt) * p,
    zoom: a.zoom + (b.zoom - a.zoom) * p,
  };
}

function pick(k) {
  return { turn: k.turn, tilt: k.tilt, zoom: k.zoom };
}

/**
 * Plays the clip in real time via the stage's frame loop. The clip lasts until
 * the last keyframe or the end of the last clip (`clipsEnd()`), whichever is later.
 */
export function createPlayer(stage, applyPose, onTime, clipsEnd = () => 0) {
  let timeline = { keyframes: [], loop: true };
  let playing = false;
  let time = 0;
  let last = 0;
  let range = null; // {start, end} while looping one move

  const duration = () => Math.max(timeline.keyframes.at(-1)?.time ?? 0, clipsEnd());
  const start = () => range?.start ?? 0;
  const end = () => range?.end ?? duration();

  const show = () => {
    const pose = poseAt(timeline, time);
    if (pose) applyPose(pose);
    onTime(time, playing);
  };

  stage.onFrame.push((now) => {
    if (!playing) return;
    const dt = Math.min(0.1, (now - last) / 1000); // clamp after a hidden tab
    last = now;
    time += dt;
    if (time >= end()) {
      const length = end() - start();
      if ((range || timeline.loop) && length > 0) time = start() + ((time - start()) % length);
      else { time = end(); playing = false; }
    }
    show();
  });

  return {
    setTimeline(next) {
      timeline = next;
      time = Math.min(time, duration());
      if (!playing) show();
    },
    /** Call after the clips change: re-shows the current moment. */
    refresh() {
      time = Math.min(time, duration());
      if (!playing) show();
    },
    get time() { return time; },
    get duration() { return duration(); },
    /** Loops only [start, end] (one move); pass negatives to play the whole clip. */
    setLoopRange(a, b) {
      range = a >= 0 && b > a ? { start: a, end: b } : null;
      if (range && (time < a || time > b)) time = a;
    },
    play() {
      if (end() - start() <= 0) return;
      if (time >= end() || time < start()) time = start();
      playing = true;
      last = performance.now();
      onTime(time, playing);
    },
    pause() { playing = false; onTime(time, playing); },
    seek(t) { time = Math.max(0, Math.min(duration(), t)); show(); },
    get playing() { return playing; },
  };
}
