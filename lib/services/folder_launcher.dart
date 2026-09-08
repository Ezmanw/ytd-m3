import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Opens the local downloads folder in the OS file manager. Only meaningful
/// in Direct mode — there is no way to browse a remote server's filesystem
/// from here, so callers should check for an active remote server first.
class FolderLauncher {
  const FolderLauncher._();

  static Future<Directory> resolveDownloadsDirectory() async {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) return downloads;
    // Fall back to a ytd_m3 subfolder of the app's documents directory if the
    // platform has no notion of a shared Downloads folder.
    final documents = await getApplicationDocumentsDirectory();
    final fallback = Directory('${documents.path}/Downloads');
    if (!await fallback.exists()) {
      await fallback.create(recursive: true);
    }
    return fallback;
  }

  static Future<void> openDownloadsFolder() async {
    final directory = await resolveDownloadsDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    if (Platform.isLinux) {
      await Process.run('xdg-open', [directory.path]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [directory.path]);
    } else if (Platform.isWindows) {
      await Process.run('explorer', [directory.path]);
    } else {
      throw UnsupportedError('Opening a folder is not supported on this platform.');
    }
  }
}
