import 'dart:js_interop';
import 'dart:typed_data';

@JS('Blob')
extension type _Blob._(JSObject _) implements JSObject {
  external factory _Blob(JSArray<JSAny> parts, JSObject options);
}

@JS('URL.createObjectURL')
external String _createObjectUrl(JSObject blob);

/// A blob: URL the browser (and the 3D view) can load [bytes] from.
String blobUrlFor(Uint8List bytes, String mimeType) {
  final options = {'type': mimeType}.jsify()! as JSObject;
  return _createObjectUrl(_Blob([bytes.toJS].toJS, options));
}

/// Best guess at a file's MIME type from its name.
String mimeTypeFor(String name, {String? reported}) {
  if (reported != null && reported.isNotEmpty) return reported;
  final ext = name.split('.').last.toLowerCase();
  return switch (ext) {
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    'webp' => 'image/webp',
    'gif' => 'image/gif',
    'mp4' || 'm4v' => 'video/mp4',
    'mov' => 'video/quicktime',
    'webm' => 'video/webm',
    _ => 'application/octet-stream',
  };
}
