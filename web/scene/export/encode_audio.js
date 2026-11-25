// Encodes a mixed AudioBuffer with the browser's AudioEncoder (WebCodecs),
// fed in step with the video frames so the muxer gets both in time order.
import { SAMPLE_RATE } from './mix_audio.js';

const CHUNK = 1024; // sample frames per AudioData

const CANDIDATES = {
  mp4: [{ codec: 'mp4a.40.2', mux: 'aac' }, { codec: 'opus', mux: 'opus' }],
  webm: [{ codec: 'opus', mux: 'A_OPUS' }],
};

/** The first audio codec this browser can encode for `format`, or null. */
export async function pickAudioCodec(format) {
  if (!('AudioEncoder' in window)) return null;
  for (const c of CANDIDATES[format] ?? []) {
    const config = { codec: c.codec, sampleRate: SAMPLE_RATE, numberOfChannels: 2, bitrate: 160000 };
    try {
      if ((await AudioEncoder.isConfigSupported(config)).supported) return { ...c, config };
    } catch (_) { /* try the next one */ }
  }
  return null;
}

/** Feeds `buffer` to an AudioEncoder that hands chunks to `onChunk(chunk, meta)`. */
export function createAudioFeed(buffer, codec, onChunk) {
  let failure = null;
  const encoder = new AudioEncoder({ output: onChunk, error: (e) => { failure = e; } });
  encoder.configure(codec.config);
  const left = buffer.getChannelData(0);
  const right = buffer.numberOfChannels > 1 ? buffer.getChannelData(1) : left;
  let sent = 0;

  const sendUntil = (frameIndex) => {
    while (sent < Math.min(frameIndex, buffer.length)) {
      const n = Math.min(CHUNK, buffer.length - sent);
      const planar = new Float32Array(n * 2);
      planar.set(left.subarray(sent, sent + n), 0);
      planar.set(right.subarray(sent, sent + n), n);
      const data = new AudioData({
        format: 'f32-planar',
        sampleRate: SAMPLE_RATE,
        numberOfFrames: n,
        numberOfChannels: 2,
        timestamp: Math.round((sent / SAMPLE_RATE) * 1e6),
        data: planar,
      });
      encoder.encode(data);
      data.close();
      sent += n;
    }
  };

  return {
    /** Sends everything up to `seconds` into the clip. */
    feed(seconds) {
      if (failure) throw failure;
      sendUntil(Math.ceil(seconds * SAMPLE_RATE));
    },
    async finish() {
      sendUntil(buffer.length);
      await encoder.flush();
      if (failure) throw failure;
      encoder.close();
    },
    cancel() { if (encoder.state !== 'closed') encoder.close(); },
  };
}
