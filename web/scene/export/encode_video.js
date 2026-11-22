// MP4 (H.264) and WebM (VP9) with the browser's built-in encoder (WebCodecs),
// muxed into a file in memory.
import { Mp4Muxer, Mp4Target, WebmMuxer, WebmTarget } from '../vendor/encoders_bundle.js';

const CODECS = {
  mp4: ['avc1.640034', 'avc1.640033', 'avc1.4d0034', 'avc1.42003e'],
  webm: ['vp09.00.51.08', 'vp8'],
};

export async function createVideoEncoder({ format, width, height, fps }) {
  if (!('VideoEncoder' in window)) throw new Error('This browser cannot encode video. Try Chrome, Edge, Firefox or Safari.');
  const bitrate = Math.min(50e6, width * height * fps * 0.15);
  const codec = await firstSupported(CODECS[format], { width, height, bitrate, framerate: fps });

  const target = format === 'mp4' ? new Mp4Target() : new WebmTarget();
  const muxer = format === 'mp4'
    ? new Mp4Muxer({ target, video: { codec: 'avc', width, height, frameRate: fps }, fastStart: 'in-memory' })
    : new WebmMuxer({ target, video: { codec: codec.startsWith('vp09') ? 'V_VP9' : 'V_VP8', width, height, frameRate: fps } });

  let failure = null;
  const encoder = new VideoEncoder({
    output: (chunk, meta) => muxer.addVideoChunk(chunk, meta),
    error: (e) => { failure = e; },
  });
  encoder.configure({ codec, width, height, bitrate, framerate: fps });

  return {
    async addFrame(canvas, index) {
      if (failure) throw failure;
      const frame = new VideoFrame(canvas, { timestamp: Math.round((index * 1e6) / fps), duration: Math.round(1e6 / fps) });
      encoder.encode(frame, { keyFrame: index % (fps * 2) === 0 });
      frame.close();
      while (encoder.encodeQueueSize > 6) await new Promise((r) => setTimeout(r, 5));
    },
    async finish() {
      await encoder.flush();
      if (failure) throw failure;
      encoder.close();
      muxer.finalize();
      return new Blob([target.buffer], { type: format === 'mp4' ? 'video/mp4' : 'video/webm' });
    },
    cancel() { if (encoder.state !== 'closed') encoder.close(); },
  };
}

async function firstSupported(codecs, config) {
  for (const codec of codecs) {
    const { supported } = await VideoEncoder.isConfigSupported({ ...config, codec });
    if (supported) return codec;
  }
  throw new Error('No supported video codec for this size. Try a smaller quality.');
}
