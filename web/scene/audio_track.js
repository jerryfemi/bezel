// Music and sound clips during preview: one <audio> element per clip, played
// from its in-point while the playhead is inside it and kept in sync.
// (Export mixes the sound separately; see export/mix_audio.js.)
import { levelAt } from './sound_level.js';

const DRIFT = 0.3;

export function createAudioTrack(assets) {
  let clips = [];
  const players = new Map(); // clipId -> {el, assetId}

  const playerFor = (clip) => {
    let p = players.get(clip.id);
    const asset = assets.get(clip.assetId);
    if (!asset) return null;
    if (!p || p.assetId !== clip.assetId) {
      p?.el.pause();
      p = { el: Object.assign(new Audio(asset.url), { preload: 'auto' }), assetId: clip.assetId };
      players.set(clip.id, p);
    }
    return p;
  };

  return {
    /** clips: [{id, start, end, assetId, inPoint, volume, muted, fadeIn, fadeOut}]. */
    setClips(next) {
      clips = next;
      const keep = new Set(next.map((c) => c.id));
      for (const [id, p] of players) if (!keep.has(id)) { p.el.pause(); players.delete(id); }
    },
    update(t, playing) {
      for (const clip of clips) {
        const inside = t >= clip.start && t < clip.end;
        const p = inside || players.has(clip.id) ? playerFor(clip) : null;
        if (!p) continue;
        const el = p.el;
        if (!(playing && inside)) { if (!el.paused) el.pause(); continue; }
        el.volume = levelAt(clip, t);
        const target = clip.inPoint + (t - clip.start);
        if (el.paused) { el.currentTime = target; el.play().catch(() => {}); }
        else if (Math.abs(el.currentTime - target) > DRIFT) el.currentTime = target;
      }
    },
    pauseAll() { for (const p of players.values()) p.el.pause(); },
    dispose() { this.pauseAll(); players.clear(); },
  };
}
