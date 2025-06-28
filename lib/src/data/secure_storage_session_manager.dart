
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user_session_manager/src/data/session_key.dart';
import 'package:user_session_manager/src/domain/i_user_session_repository.dart';
import 'package:user_session_manager/src/domain/typedefs.dart';

class SecureSessionRepository<T> implements IUserSessionRepository<T> {

  final FlutterSecureStorage _storage;
  final ToJson<T> toJson;
  final FromJson<T> fromJson;

  SecureSessionRepository._(this._storage, this.toJson, this.fromJson);

  static Future<SecureSessionRepository<T>> create<T>({
    required ToJson<T> toJson,
    required FromJson<T> fromJson,
  }) async {
    return SecureSessionRepository._(
        const FlutterSecureStorage(), toJson, fromJson);
  }

  @override
  Future<void> save(T user) async {
    final json = jsonEncode(toJson(user));
    await _storage.write(key: UserSessionManagerKey.userSession, value: json);
  }

  @override
  Future<T?> read() async {
    final json = await _storage.read(key: UserSessionManagerKey.userSession);
    if (json == null) return null;
    return fromJson(jsonDecode(json));
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: UserSessionManagerKey.userSession);
  }
}