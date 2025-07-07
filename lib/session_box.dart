library;

import 'package:flutter/foundation.dart';
import 'package:session_box/src/application/user_session_service.dart';
import 'package:session_box/src/domain/typedefs.dart';

class SessionBox<T> {
  final UserSessionService<T> _service;
  SessionBox._(this._service);

  @visibleForTesting
  factory SessionBox.forTesting(UserSessionService<T> service) {
    return SessionBox._(service);
  }

  static Future<SessionBox<T>> create<T>({
     ToJson<T>? toJson,
     FromJson<T>? fromJson,
    bool encrypt = false,
    Future<bool> Function(T user)? isValidUser
  }) async {
    final UserSessionService<T> service = await UserSessionService.create(
      toJson: toJson,
      fromJson: fromJson,
      encrypt: encrypt,
      isValidUser: isValidUser
    );
    return SessionBox._(service);
  }

  Future<void> login(T user) => _service.login(user);
  Future<T?> refreshSession() => _service.refreshSession();
  Future<void> logout() => _service.logout();
  Future<T?> getUser() => _service.getUser();
  void setUserId(int userId) => _service.setSessionUserId(userId);
  int? getUserId() => _service.getSessionUserId();
  bool get hasUserId => _service.hasSessionUserId();

}