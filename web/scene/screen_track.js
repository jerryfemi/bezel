// The phone's screen over time: whichever screen clip covers the current
// time is shown, cropped to fill the screen ("cover"). Video clips play from
// their in-point, kept in sync with the timeline. With no clips at all the
// screen shows the "tap to add" prompt; in a gap between clips it is black.
import * as THREE from './vendor/three_bundle.js';
import { drawDefaultWallpaper } from './default_wallpaper.js';
import { once } from './assets.js';

const DRIFT = 0.25; // seconds a playing video may drift before it is corrected

export function createScreenTrack(stage, device, assets) {
  const aspect = device.profile.screens[0].aspect;
  // DoubleSide: some models' screens face inward in the file.
  const material = new THREE.MeshBasicMaterial({ toneMapped: false, side: THREE.DoubleSide });
  device.parts.screen.forEach((mesh) => { mesh.material = material; });

  const prompt = prepare(new THREE.CanvasTexture(drawDefaultWallpaper(aspect)), aspect, aspect);
  const black = prepare(new THREE.DataTexture(new Uint8Array([0, 0, 0, 255]), 1, 1), aspect, aspect);
  black.needsUpdate = true;
  const textures = new Map(); // assetId -> texture (VideoTexture or image texture)
  const loading = new Set();
  let clips = [];
  let time = 0;
  let playing = false;

  const show = (texture) => {
    if (material.map === texture) return;
    material.map = texture;
    material.needsUpdate = true;
    stage.invalidate();
  };

  const textureFor = (asset) => {
    const ready = textures.get(asset.id);
    if (ready) return ready;
    if (asset.kind === 'video') {
      const v = asset.video;
      const t = prepare(new THREE.VideoTexture(v), v.videoWidth / v.videoHeight || aspect, aspect);
      if (!v.videoWidth) v.addEventListener('loadedmetadata', () => cover(t, v.videoWidth / v.videoHeight, aspect), { once: true });
      textures.set(asset.id, t);
      return t;
    }
    if (!loading.has(asset.id)) {
      loading.add(asset.id);
      new THREE.TextureLoader().loadAsync(asset.url).then((t) => {
        textures.set(asset.id, prepare(t, t.image.width / t.image.height, aspect));
        loading.delete(asset.id);
        update(time, playing);
      }).catch(() => loading.delete(asset.id));
    }
    return null;
  };

  const active = (t) => {
    let found = null;
    for (const c of clips) if (t >= c.start && t < c.end) found = c;
    return found;
  };

  const pauseOthers = (keep) => {
    for (const c of clips) {
      const v = assets.get(c.assetId)?.video;
      if (v && v !== keep && !v.paused) v.pause();
    }
  };

  /** Shows the screen at time `t`; `isPlaying` keeps video running in sync. */
  function update(t, isPlaying) {
    time = t;
    playing = isPlaying;
    const clip = active(t);
    const asset = clip && assets.get(clip.assetId);
    const video = asset?.video ?? null;
    pauseOthers(video);
    stage.alwaysRender = Boolean(video && isPlaying);
    if (!clip || !asset) return show(clips.length ? black : prompt);

    const texture = textureFor(asset);
    if (texture) show(texture);
    if (!video) return;

    const target = clip.inPoint + (t - clip.start);
    video.volume = Math.max(0, Math.min(1, clip.volume ?? 1));
    video.muted = video.volume === 0;
    if (isPlaying) {
      if (video.paused) { video.currentTime = target; video.play().catch(() => {}); }
      else if (Math.abs(video.currentTime - target) > DRIFT) video.currentTime = target;
    } else {
      if (!video.paused) video.pause();
      if (Math.abs(video.currentTime - target) > 0.03) {
        video.currentTime = target;
        video.addEventListener('seeked', () => {
          if (texture) texture.needsUpdate = true;
          stage.invalidate();
        }, { once: true });
      }
    }
  }

  return {
    /** clips: [{id, start, end, assetId, inPoint, volume}], in time order. */
    setClips(next) {
      clips = next;
      update(time, playing);
    },
    update,
    /** Export: shows the exact frame at `t` and waits for the video to get there. */
    async prepareFrame(t) {
      const clip = active(t);
      const asset = clip && assets.get(clip.assetId);
      pauseOthers(asset?.video ?? null);
      stage.alwaysRender = false;
      if (!clip || !asset) return show(clips.length ? black : prompt);
      let texture = textureFor(asset);
      if (!texture && asset.kind === 'image') {
        const t2 = await new THREE.TextureLoader().loadAsync(asset.url);
        texture = prepare(t2, t2.image.width / t2.image.height, aspect);
        textures.set(asset.id, texture);
      }
      if (texture) show(texture);
      const video = asset.video;
      if (!video) return;
      video.pause();
      const target = clip.inPoint + (t - clip.start);
      if (Math.abs(video.currentTime - target) > 0.001) {
        const seeked = once(video, 'seeked', 2000); // never stall an export on one frame
        video.currentTime = target;
        await seeked;
      }
      if (texture) texture.needsUpdate = true;
    },
    pauseAll() { pauseOthers(null); stage.alwaysRender = false; },
    dispose() {
      pauseOthers(null);
      stage.alwaysRender = false;
      for (const t of textures.values()) t.dispose();
      prompt.dispose();
      black.dispose();
      material.dispose();
    },
  };
}

function prepare(texture, mediaAspect, screenAspect) {
  texture.colorSpace = THREE.SRGBColorSpace;
  texture.flipY = false; // the prepared screen UVs use glTF's top-left origin
  cover(texture, mediaAspect, screenAspect);
  return texture;
}

/** Crops the texture so it fills a screen of `screenAspect` without stretching. */
function cover(texture, mediaAspect, screenAspect) {
  texture.repeat.set(1, 1);
  texture.offset.set(0, 0);
  if (mediaAspect > screenAspect) {
    texture.repeat.x = screenAspect / mediaAspect;
    texture.offset.x = (1 - texture.repeat.x) / 2;
  } else {
    texture.repeat.y = mediaAspect / screenAspect;
    texture.offset.y = (1 - texture.repeat.y) / 2;
  }
}
