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

  /// Factory to create a session box.
  static Future<SessionBox<T>> create<T>({
    ToJson<T>? toJson,
    FromJson<T>? fromJson,
    bool encrypt = false,
    Future<bool> Function(T user)? isValidUser,
  }) async {
    final UserSessionService<T> service = await UserSessionService.create(
      toJson: toJson,
      fromJson: fromJson,
      encrypt: encrypt,
      isValidUser: isValidUser,
    );
    return SessionBox._(service);
  }

  /// Persists the full user object
  Future<void> login(T user) => _service.login(user);
  /// Gets the persisted user object, or `null` if none. Useful if you need fields from the stored user (e.g., email).
  Future<T?> getUser() => _service.getUser();
  /// Re-reads the stored user and (if `isValidUser` is set) validates it. Returns the valid user or `null` if invalid.
  Future<T?> refreshSession() => _service.refreshSession();
  /// Clears the persisted user and in‑memory userId.
  Future<void> logout() => _service.logout();
  /// Sets an in‑memory only user id (not persisted). Most apps don’t need to call this directly.
  void setUserId(int userId) => _service.setSessionUserId(userId);
  /// Returns the in‑memory user id (or null if not set). Requires that you set it with [setUserId]. Ideally after using refreshSession, with isValidUser passed when creating the session box.
  int? getUserId() => _service.getSessionUserId();
  /// true if an in‑memory user id is set.
  bool get hasUserId => _service.hasSessionUserId();
}
