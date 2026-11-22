// Puts an image or video on the device screen, cropped to fill it ("cover").
import * as THREE from './vendor/three_bundle.js';
import { drawDefaultWallpaper } from './default_wallpaper.js';

export function createScreenMedia(stage, device) {
  const aspect = device.profile.screens[0].aspect;
  // DoubleSide: some models' screens face inward in the file; one-sided
  // drawing would make the screen invisible.
  const material = new THREE.MeshBasicMaterial({ toneMapped: false, side: THREE.DoubleSide });
  device.parts.screen.forEach((mesh) => { mesh.material = material; });
  let video = null;

  const show = (texture, mediaAspect) => {
    texture.colorSpace = THREE.SRGBColorSpace;
    texture.flipY = false; // the prepared screen UVs use glTF's top-left origin
    cover(texture, mediaAspect, aspect);
    material.map?.dispose();
    material.map = texture;
    material.needsUpdate = true;
    stage.invalidate();
  };

  const stopVideo = () => {
    if (!video) return;
    video.pause();
    video.removeAttribute('src');
    video = null;
    stage.alwaysRender = false;
  };

  show(new THREE.CanvasTexture(drawDefaultWallpaper(aspect)), aspect);

  return {
    async setImage(url) {
      stopVideo();
      const texture = await new THREE.TextureLoader().loadAsync(url);
      show(texture, texture.image.width / texture.image.height);
    },
    async setVideo(url) {
      stopVideo();
      video = Object.assign(document.createElement('video'), {
        src: url, muted: true, loop: true, playsInline: true, crossOrigin: 'anonymous',
      });
      await video.play();
      show(new THREE.VideoTexture(video), video.videoWidth / video.videoHeight);
      stage.alwaysRender = true;
    },
    /** Export: pauses a playing video and shows its frame at `seconds`. */
    async seekVideo(seconds) {
      if (!video) return;
      video.pause();
      const target = seconds % (video.duration || 1);
      if (Math.abs(video.currentTime - target) > 0.001) {
        await new Promise((resolve) => {
          const done = () => { clearTimeout(timer); resolve(); };
          const timer = setTimeout(done, 2000); // never stall an export on one frame
          video.addEventListener('seeked', done, { once: true });
          video.currentTime = target;
        });
      }
      if (material.map) material.map.needsUpdate = true;
    },
    resumeVideo() { video?.play().catch(() => {}); },
    dispose() { stopVideo(); material.map?.dispose(); material.dispose(); },
  };
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
