
abstract interface class IUserSessionRepository<T> {

  Future<void> saveUser(T user);
  Future<T?> getUser();
  Future<void> clear();
}