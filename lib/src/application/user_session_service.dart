import 'package:flutter/foundation.dart';
import 'package:session_box/src/data/secure_session_repository.dart';
import 'package:session_box/src/data/shared_prefs_session_repository.dart';
import 'package:session_box/src/domain/i_user_session_repository.dart';
import 'package:session_box/src/domain/typedefs.dart';

class UserSessionService<T> {

  final Future<bool> Function(T user)? _isValidUserAsync;
  int? _userId;

  final IUserSessionRepository<T> _repository;
  UserSessionService._(this._repository, [this._isValidUserAsync]);

  @visibleForTesting
  factory UserSessionService.forTesting(IUserSessionRepository<T> repository) {
    return UserSessionService._(repository);
  }

  static Future<UserSessionService<T>> create<T>({
    ToJson<T>? toJson,
    FromJson<T>? fromJson,
    bool encrypt = false,
    Future<bool> Function(T user)? isValidUser
  }) async {
    final toJsonFn = _resolveToJson<T>(toJson);
    final fromJsonFn = _resolveFromJson<T>(fromJson);

    if (encrypt) {
      final SecureSessionRepository<T> repo = await SecureSessionRepository.create(
        toJson: toJsonFn,
        fromJson: fromJsonFn
      );
      return UserSessionService._(repo);
    } else {
      final SharedPrefsSessionRepository<T> repo = await SharedPrefsSessionRepository.create(
        toJson: toJsonFn,
        fromJson: fromJsonFn,
      );
      return UserSessionService._(repo, isValidUser);
    }
  }

  Future<void> login(T user) async {
    await _repository.saveUser(user);
  }

  void setSessionUserId(int userId) {
    _userId = userId;
  }

  Future<void> logout() async {
    _repository.clear();
    _userId = null;
  }

  Future<T?> getUser() async {
    return await _repository.getUser();
  }

  int? getSessionUserId() {
    return _userId;
  }

  Future<T?> refreshSession() async {

    final T? user = await getUser();

    // User null: returns null, user not null validates the user, and if the user is not valid anymore, also return null;
    if (user != null) {
      if (_isValidUserAsync != null && !await _isValidUserAsync(user)) {
        return null; //
      }
    }

    return user;
  }

  bool hasSessionUserId() {
    return _userId != null;
  }

  static ToJson<T> _resolveToJson<T>(ToJson<T>? provided) {

    if (provided != null) {
      return provided;
    }

    return (value) {
      if (value is int || value is double || value is bool || value is String) {
        return {'value': value};
      }
      throw UnsupportedError('Missing toJson for type $T');
    };

  }

  static FromJson<T> _resolveFromJson<T>(FromJson<T>? provided) {

    if (provided != null) {
      return provided;
    }

    return (json) {
      final value = json['value'];
      if (T == int) return value as T;
      if (T == double) return value as T;
      if (T == bool) return value as T;
      if (T == String) return value as T;
      throw UnsupportedError('Missing fromJson for type $T');
    };

  }
}