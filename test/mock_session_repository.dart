import 'package:session_box/src/domain/i_user_session_repository.dart';

class InMemorySessionRepository<T> implements IUserSessionRepository<T> {
  T? _user;

  @override
  Future<void> saveUser(T user) async {
    _user = user;
  }

  @override
  Future<T?> getUser() async => _user;

  @override
  Future<void> clear() async {
    _user = null;
  }
}