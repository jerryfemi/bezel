// The key light's direction and strength, and how much the device reflects
// its surroundings. `angle` is where the light comes from, read like a clock
// face on the frame: 0° from the top, 90° from the right, 315° top-left.
const SPREAD = 2.5; // how far off-centre the light sits
const FRONT = 3; // how far in front of the device

export function applyLight(stage, light) {
  const { THREE, key, scene } = stage;
  const a = THREE.MathUtils.degToRad(light.angle);
  key.position.set(Math.sin(a) * SPREAD, Math.cos(a) * SPREAD, FRONT);
  key.intensity = 0.4 + 2.2 * light.intensity;
  scene.environmentIntensity = light.reflections ? 1 : 0.25;
  stage.invalidate();
}
