
import 'package:flutter/foundation.dart';
import 'package:user_session_manager/src/data/secure_storage_session_manager.dart';
import 'package:user_session_manager/src/data/shared_prefs_session_manager.dart';
import 'package:user_session_manager/src/domain/i_user_session_repository.dart';
import 'package:user_session_manager/src/domain/typedefs.dart';

class UserSessionService<T> {

  final IUserSessionRepository<T> _repository;
  UserSessionService._(this._repository);

  @visibleForTesting
  factory UserSessionService.forTesting(IUserSessionRepository<T> repository) {
    return UserSessionService._(repository);
  }

  static Future<UserSessionService<T>> create<T>({
    ToJson<T>? toJson,
    FromJson<T>? fromJson,
    bool encrypt = false,
  }) async {
    final toJsonFn = _resolveToJson<T>(toJson);
    final fromJsonFn = _resolveFromJson<T>(fromJson);

    if (encrypt) {
      final SecureSessionRepository<T> repo = await SecureSessionRepository.create(
        toJson: toJsonFn,
        fromJson: fromJsonFn,
      );
      return UserSessionService._(repo);
    } else {
      final SharedPrefsSessionRepository<T> repo = await SharedPrefsSessionRepository.create(
        toJson: toJsonFn,
        fromJson: fromJsonFn,
      );
      return UserSessionService._(repo);
    }
  }

  Future<void> login(T user) => _repository.save(user);
  Future<void> logout() => _repository.clear();
  Future<T?> getUser() => _repository.read();
  Future<bool> isLoggedIn() async => (await getUser()) != null;

  static ToJson<T> _resolveToJson<T>(ToJson<T>? provided) {
    if (provided != null) return provided;

    return (value) {
      if (value is int || value is double || value is bool || value is String) {
        return {'value': value};
      }
      throw UnsupportedError('Missing toJson for type $T');
    };
  }

  static FromJson<T> _resolveFromJson<T>(FromJson<T>? provided) {
    if (provided != null) return provided;

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