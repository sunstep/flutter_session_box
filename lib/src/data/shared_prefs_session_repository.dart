
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:session_box/src/data/session_key.dart';
import 'package:session_box/src/domain/i_user_session_repository.dart';
import 'package:session_box/src/domain/typedefs.dart';

class SharedPrefsSessionRepository<T> implements IUserSessionRepository<T> {

  final SharedPreferencesAsync _prefs;
  final ToJson<T> toJson;
  final FromJson<T> fromJson;

  SharedPrefsSessionRepository._(this._prefs, this.toJson, this.fromJson);

  static Future<SharedPrefsSessionRepository<T>> create<T>({
    required ToJson<T> toJson,
    required FromJson<T> fromJson,
  }) async {
    final prefs = SharedPreferencesAsync();
    return SharedPrefsSessionRepository._(prefs, toJson, fromJson);
  }

  @override
  Future<void> saveUser(T user) async {
    final json = jsonEncode(toJson(user));
    await _prefs.setString(UserSessionManagerKey.userSession, json);
  }

  @override


  @override
  Future<T?> getUser() async {

    final json = await _prefs.getString(UserSessionManagerKey.userSession);

    if (json == null) {
      return null;
    }
      return fromJson(jsonDecode(json));

  }

  @override
  Future<void> clear() async {
    await _prefs.remove(UserSessionManagerKey.userSession);
  }
}