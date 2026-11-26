/// Devices bundled with Bezel. Each lives in `web/devices/<id>/`.
class DeviceEntry {
  const DeviceEntry(this.id, this.label);

  final String id;
  final String label;

  String get baseUrl => 'devices/$id';
}

const deviceCatalog = [
  DeviceEntry('iphone-13-pro-max', 'iPhone 13 Pro Max'),
  DeviceEntry('iphone-16-pro-max', 'iPhone 16 Pro Max'),
];
