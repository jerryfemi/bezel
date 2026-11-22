/** The small JSON file the app reads to know what a device offers. */
export function buildProfile(device, size, screenAspect) {
  return {
    id: device.id,
    name: device.name,
    model: 'model.glb',
    size: round(size),
    screens: [{ id: 'front', aspect: +screenAspect.toFixed(4) }],
    finishes: device.finishes,
    defaultFinish: device.finishes[0].id,
  };
}

function round(obj) {
  return Object.fromEntries(Object.entries(obj).map(([k, v]) => [k, +v.toFixed(4)]));
}
