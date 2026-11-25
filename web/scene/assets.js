// The project's media files (screenshots, screen recordings, music), shared
// by the screen track, the audio track and export. Each asset has one blob:
// URL; video assets also get one <video> element that the screen shows.

let audioContext = null; // created on first decode; decoding needs no user gesture

export function createAssets() {
  const assets = new Map(); // id -> {id, url, kind, video?, decoded?: Promise<AudioBuffer|null>}

  const makeVideo = (url) => Object.assign(document.createElement('video'), {
    src: url, preload: 'auto', playsInline: true, crossOrigin: 'anonymous',
  });

  return {
    /** kind: 'image' | 'video' | 'audio'. */
    add(id, url, kind) {
      if (assets.has(id)) return;
      const asset = { id, url, kind };
      if (kind === 'video') asset.video = makeVideo(url);
      assets.set(id, asset);
    },
    remove(id) {
      const a = assets.get(id);
      if (!a) return;
      if (a.video) { a.video.pause(); a.video.removeAttribute('src'); a.video.load(); }
      assets.delete(id);
    },
    get(id) { return assets.get(id); },
    has(id) { return assets.has(id); },

    /** {duration (s, 0 for images), width, height}. */
    async probe(id) {
      const a = assets.get(id);
      if (!a) return { duration: 0, width: 0, height: 0 };
      if (a.kind === 'image') {
        const img = await loadImage(a.url);
        return { duration: 0, width: img.naturalWidth, height: img.naturalHeight };
      }
      const el = document.createElement(a.kind === 'video' ? 'video' : 'audio');
      el.preload = 'metadata';
      el.src = a.url;
      await once(el, 'loadedmetadata', 10000);
      const duration = Number.isFinite(el.duration) ? el.duration : 0;
      const out = { duration, width: el.videoWidth ?? 0, height: el.videoHeight ?? 0 };
      el.removeAttribute('src');
      return out;
    },

    /** The file's sound as an AudioBuffer, or null if it has none we can read. */
    decode(id) {
      const a = assets.get(id);
      if (!a || a.kind === 'image') return Promise.resolve(null);
      a.decoded ??= (async () => {
        try {
          audioContext ??= new AudioContext({ sampleRate: 48000 });
          const bytes = await (await fetch(a.url)).arrayBuffer();
          return await audioContext.decodeAudioData(bytes);
        } catch (_) {
          return null; // e.g. a silent recording, or a container the browser can't read
        }
      })();
      return a.decoded;
    },

    /** Loudness 0..1 in `count` buckets, for the waveform. */
    async peaks(id, count) {
      const buffer = await this.decode(id);
      if (!buffer) return [];
      const data = buffer.getChannelData(0);
      const step = Math.max(1, Math.floor(data.length / count));
      const out = [];
      let loudest = 0;
      for (let i = 0; i < count; i++) {
        let peak = 0;
        const end = Math.min(data.length, (i + 1) * step);
        for (let j = i * step; j < end; j += 16) peak = Math.max(peak, Math.abs(data[j]));
        out.push(peak);
        loudest = Math.max(loudest, peak);
      }
      return loudest > 0 ? out.map((p) => p / loudest) : out;
    },

    /** `count` small JPEG frames (data URLs) spread across a video, or the image itself. */
    async filmstrip(id, count, height) {
      const a = assets.get(id);
      if (!a) return [];
      if (a.kind === 'image') {
        const img = await loadImage(a.url);
        return [thumb(img, img.naturalWidth, img.naturalHeight, height)];
      }
      if (a.kind !== 'video') return [];
      const v = makeVideo(a.url);
      v.muted = true;
      await once(v, 'loadeddata', 10000);
      const frames = [];
      const duration = Number.isFinite(v.duration) ? v.duration : 0;
      for (let i = 0; i < count; i++) {
        v.currentTime = Math.max(0, Math.min(duration - 0.05, ((i + 0.5) / count) * duration));
        await once(v, 'seeked', 3000);
        frames.push(thumb(v, v.videoWidth, v.videoHeight, height));
      }
      v.removeAttribute('src');
      return frames;
    },

    dispose() { for (const id of [...assets.keys()]) this.remove(id); },
  };
}

function thumb(source, w, h, height) {
  const c = document.createElement('canvas');
  c.height = height;
  c.width = Math.max(1, Math.round((height * (w || 9)) / (h || 16)));
  c.getContext('2d').drawImage(source, 0, 0, c.width, c.height);
  return c.toDataURL('image/jpeg', 0.7);
}

function loadImage(url) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve(img);
    img.onerror = reject;
    img.src = url;
  });
}

/** Resolves on `event` (or after `timeout` ms, so nothing ever hangs). */
export function once(el, event, timeout) {
  return new Promise((resolve) => {
    const done = () => { clearTimeout(timer); resolve(); };
    const timer = setTimeout(done, timeout);
    el.addEventListener(event, done, { once: true });
  });
}
