// One entry per device Bezel ships. `source` is relative to the repo root.
// `frontAxis` is the direction the screen faces in the source file; prep
// rotates every model so the screen faces +Z with +Y up.
// `screenGlassMeshes` (optional) names glass meshes over the screen whose
// material is shared with other parts.
// Finish colours are close approximations of Apple's published finishes.
export const devices = [
  {
    id: 'iphone-13-pro-max',
    name: 'iPhone 13 Pro Max',
    source: 'assets/devices/apple_iphone_13_pro_max.glb',
    frontAxis: '-z',
    materials: {
      screen: ['Wallpaper'],
      screenGlass: ['Screen_Glass'],
      body: ['Body'],
      frame: ['Frame', 'Frame2'],
    },
    finishes: [
      { id: 'graphite', name: 'Graphite', body: '#54524F', frame: '#4A4946' },
      { id: 'silver', name: 'Silver', body: '#E9EAE5', frame: '#D6D7D2' },
      { id: 'gold', name: 'Gold', body: '#F4E1C5', frame: '#E3C9A1' },
      { id: 'sierra-blue', name: 'Sierra Blue', body: '#A7C1D9', frame: '#9AB3CB' },
      { id: 'alpine-green', name: 'Alpine Green', body: '#576856', frame: '#4D5C4C' },
    ],
  },
  {
    id: 'iphone-16-pro-max',
    name: 'iPhone 16 Pro Max',
    source: 'assets/devices/iphone_16_pro_max.glb',
    frontAxis: '-x',
    // The front glass shares its material with the lens covers, so it is
    // split out by mesh name and given its own screen-glass material.
    screenGlassMeshes: ['Cube.014_glass.002_0'],
    materials: {
      screen: ['screen.001'],
      screenGlass: [],
      body: ['basecolor.001'],
      frame: ['metalframe.002'],
    },
    finishes: [
      { id: 'black-titanium', name: 'Black Titanium', body: '#3C3C3D', frame: '#4A4A4C' },
      { id: 'white-titanium', name: 'White Titanium', body: '#F2F1ED', frame: '#D9D7D1' },
      { id: 'natural-titanium', name: 'Natural Titanium', body: '#C2BCB2', frame: '#A9A399' },
      { id: 'desert-titanium', name: 'Desert Titanium', body: '#BFA48F', frame: '#A88E79' },
    ],
  },
];
