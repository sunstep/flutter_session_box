<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# 🗝️ Session Box for Flutter

A clean, lightweight, and testable Dart package for securely managing user session data across app restarts using `SharedPreferences` or `flutter_secure_storage`.

Designed with SOLID principles and clean architecture, it supports both primitive types (like `String`, `int`) and custom objects using JSON serialization.

This is just functionality that I wrote for my own app. I am making it available for everyone to use. Read more below about why you should choose this package.

---

## ✨ Features

- Choose between secure or plain storage (with `encrypt: true`)
- Persist any data type (primitives or complex models)
- Blazing fast access to session state
- Fully testable with in-memory mock repository
- Easy to integrate into any Dart or Flutter app
- No DB dependency required for login state
- Forces you to refresh your user id if you make use of the user id functionality

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  session_box: ^1.0.3
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Getting Started

### Primitive Example (int - userId)

You just want to persist a basic value like a userId (e.g. int) and retrieve it later — no database involved.

```dart
final session = await UserSessionManager.create<int>(encrypt: false);

await session.login(42);                      // Save user ID
final userId = await session.getUser();       // 42
final isLoggedIn = await session.isLoggedIn(); // true

await session.logout(); // User remains persisted until you call this method.
```

---

### Custom Object Example

Use case: You manage users in a database and want to persist session identity (e.g. email), not just a raw ID. This lets you safely re-link to the correct user record on app startup, without blindly trusting a stored ID. This package adds safety by only storing the user id in memory, forcing you to refesh the user id on app start up.

```dart
class User {
  final int id;
  final String name;
  final String email;

  User(this.id, this.name, this.email);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    json['id'],
    json['name'],
    json['email'],
  );
}

// Create the session manager
final session = await SessionBox.create<User>(
  encrypt: true,
  toJson: (user) => user.toJson(),
  fromJson: (json) => User.fromJson(json),

  // Optional: validate the user on app startup
  isValidUser: (user) async {
    final exists = await authService.isValidUser(user.email);
    return exists;
  },
);

// On login
final user = User(1, 'Alice', 'alice@example.com');

await session.login(user);       // Persist session identity (email, name)
await session.setUserId(user.id); // Cache user ID in memory only (not persisted)

// On app startup or resume
final storedUser = await session.getUser();

if (storedUser != null) {
  // Use the stored email to re-fetch the user from the database
  final dbUser = await userRepository.getByEmail(storedUser.email);

  if (dbUser != null) {
    await session.setUserId(dbUser.id); // Safe: this user still exists
  } else {
    await session.logout(); // User no longer exists — invalidate session
  }
}
```
> ⚠️ Important: Never blindly reuse a previously stored userId. Always resolve it from the database using stable identity fields (like email or username) before calling setUserId(...).

---

## 🧪 Testing with In-Memory Storage

For testing without platform dependencies:

```dart
final repo = InMemorySessionRepository<User>();
final service = UserSessionService.forTesting(repo);
final session = UserSessionManager.forTesting(service);
```

---

## API

### `SessionBox<T>`

| Member / Method                                                                                                                                                                                      | Description                                                                                                                                                                  |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `static Future<SessionBox<T>> create<T>({ToJson<T>? toJson, FromJson<T>? fromJson, bool encrypt = false, Future<bool> Function(T user)? isValidUser})` | Factory to create a session box.            |                                                                                                                                                                              |
| `Future<void> login(T user)`                                                                                                                                                                         | Persists the full user object                                                                                                                                                |
| `Future<T?> getUser()`                                                                                                                                                                               | Gets the persisted user object, or `null` if none. Useful if you need fields from the stored user (e.g., email).                                                             |
| `Future<T?> refreshSession()`                                                                                                                                                                        | Re-reads the stored user and (if `isValidUser` is set) validates it. Returns the valid user or `null` if invalid.                                                            |
| `Future<void> logout()`                                                                                                                                                                              | Clears the persisted user and in‑memory userId.                                                                                                                              |
| `Future<void> setUserId(int userId)`                                                                                                                                                                 | Sets an **in‑memory only** user id (not persisted). Most apps don’t need to call this directly.                                                                              |
| `int? getUserId()`                                                                                                                                                                                   | Returns the in‑memory user id (or `null` if not set). Typically becomes available after your app resolves the real DB user using info from `getUser()` / `refreshSession()`. |
| `bool get hasUserId`                                                                                                                                                                                 | `true` if an in‑memory user id is set.                                                                                                                                       |



---

## When to Use

| Use Case                            | Use this package?                   |
| ----------------------------------- | ----------------------------------- |
| Fast session check at startup       | ✅ Yes                               |
| Managing full user profile data     | ❌ Use your database                 |
| Persisting lightweight identity     | ✅ Yes                               |
| Storing auth tokens securely        | ✅ Yes (`encrypt: true`)             |
| Testing login logic without a DB    | ✅ Yes                               |
| Ensuring safe `userId` refresh flow | ✅ Yes (in-memory only, never stale) |


---

## 🛡️ Security

- When encrypt: true, session data is stored securely using flutter_secure_storage

- ✅ Ideal for storing auth tokens, user identity, or small session payloads

- ❗ Do not store sensitive data like raw passwords or biometric data

- 🧠 User ID safety:
SessionBox never persists userId, it's stored in memory only.
You are encouraged to resolve the ID from your database on app startup (e.g. by email or username) before using it.
This avoids relying on potentially stale IDs after DB resets or migrations.



---

## 📂 Folder Structure

```
lib/
├── session_box.dart         # Public API
└── src/
    ├── application/
    ├── data/
    ├── domain/
```

---

## 📜 License

BSD 3-Clause "New" or "Revised" License. See [LICENSE](LICENSE) for details.
