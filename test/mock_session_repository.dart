import 'package:user_session_manager/src/domain/i_user_session_repository.dart';

class InMemorySessionRepository<T> implements IUserSessionRepository<T> {
  T? _user;

  @override
  Future<void> save(T user) async {
    _user = user;
  }

  @override
  Future<T?> read() async => _user;

  @override
  Future<void> clear() async {
    _user = null;
  }
}