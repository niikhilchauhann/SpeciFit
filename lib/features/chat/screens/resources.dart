import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;

Future<Uint8List> readResource(String name) {
  return File(path.join(_resourceDirectory.path, name)).readAsBytes();
}

final _resourceDirectory = Directory.fromUri(
  Platform.script.resolve('../resources/'),
);
