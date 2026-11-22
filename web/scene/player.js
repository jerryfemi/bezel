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

/** Plays `timeline` in real time via the stage's frame loop. */
export function createPlayer(stage, applyPose, onTime) {
  let timeline = { keyframes: [], loop: true };
  let playing = false;
  let time = 0;
  let last = 0;

  const duration = () => timeline.keyframes.at(-1)?.time ?? 0;

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
    if (time >= duration()) {
      if (timeline.loop && duration() > 0) time %= duration();
      else { time = duration(); playing = false; }
    }
    show();
  });

  return {
    setTimeline(next) {
      timeline = next;
      time = Math.min(time, duration());
      if (!playing) show();
    },
    play() {
      if (duration() <= 0) return;
      if (time >= duration()) time = 0;
      playing = true;
      last = performance.now();
      onTime(time, playing);
    },
    pause() { playing = false; onTime(time, playing); },
    seek(t) { time = Math.max(0, Math.min(duration(), t)); show(); },
    get playing() { return playing; },
  };
}
