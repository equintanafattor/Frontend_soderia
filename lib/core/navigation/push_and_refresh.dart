import 'package:flutter/material.dart';
import 'app_shell_actions.dart';

Future<void> pushAndRefresh({
  required BuildContext context,
  required String route,
  Object? arguments,
  required VoidCallback onRefresh,
}) async {
  final result = await AppShellActions.push(
    context,
    route,
    arguments: arguments,
  );

  if (result == true && context.mounted) {
    onRefresh();
  }
}
