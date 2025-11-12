import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();

/// Simple app lifecycle observer
class AppLifecycleHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When the app comes back to foreground (e.g., from Settings)
      _closeOpenDialog();
    }
  }

  void _closeOpenDialog() {
    final navigator = globalNavigatorKey.currentState;
    if (navigator?.canPop() ?? false) {
      // Only close popup/dialog routes, do not reset the stack to the first route
      navigator!.popUntil((route) => route is! PopupRoute);
    }
  }
}
