library;

import 'package:flutter/foundation.dart';
import 'package:user_session_manager/src/application/user_session_service.dart';
import 'package:user_session_manager/src/domain/typedefs.dart';

class UserSessionManager<T> {
  final UserSessionService<T> _service;
  UserSessionManager._(this._service);

  @visibleForTesting
  factory UserSessionManager.forTesting(UserSessionService<T> service) {
    return UserSessionManager._(service);
  }

  static Future<UserSessionManager<T>> create<T>({
     ToJson<T>? toJson,
     FromJson<T>? fromJson,
    bool encrypt = false,
  }) async {
    final UserSessionService<T> service = await UserSessionService.create(
      toJson: toJson,
      fromJson: fromJson,
      encrypt: encrypt,
    );
    return UserSessionManager._(service);
  }

  Future<void> login(T user) => _service.login(user);
  Future<void> logout() => _service.logout();
  Future<T?> getUser() => _service.getUser();
  Future<bool> isLoggedIn() => _service.isLoggedIn();
}