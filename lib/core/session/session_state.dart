import 'package:flutter/foundation.dart';

class SessionUser {
  final String nombre;

  const SessionUser({required this.nombre});
}

class SessionState extends ValueNotifier<SessionUser?> {
  SessionState() : super(null);

  void setUser(SessionUser user) => value = user;
  void clear() => value = null;
}

final sessionState = SessionState();
