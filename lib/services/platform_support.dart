import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Direct (serverless) mode needs a real local filesystem and file manager
/// to open, and a local download engine we don't ship on mobile. Android
/// builds of this app are remote-server-only by design — see the project
/// README for why local mode isn't supported there.
bool get supportsDirectMode => !kIsWeb && !Platform.isAndroid;
