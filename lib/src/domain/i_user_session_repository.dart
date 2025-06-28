
abstract interface class IUserSessionRepository<T> {

  Future<void> save(T user);
  Future<T?> read();
  Future<void> clear();
}