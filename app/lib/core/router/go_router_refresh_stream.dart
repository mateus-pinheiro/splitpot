import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adaptador de `Stream` para `Listenable`, usado pelo GoRouter
/// para reavaliar redirects quando o estado do Cubit muda.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
