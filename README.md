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

# 🗝️ user_session_manager

A clean, lightweight, and testable Dart package for securely managing user session data across app restarts using `SharedPreferences` or `flutter_secure_storage`.

Designed with SOLID principles and clean architecture, it supports both primitive types (like `String`, `int`) and custom objects using JSON serialization.

This is just functionality that I wrote for my own app. I felt like that the functionality should have been provided by an existing package, but there was none.

---

## ✨ Features

- Choose between secure or plain storage (with `encrypt: true`)
- Persist any data type (primitives or complex models)
- Blazing fast access to session state
- Fully testable with in-memory mock repository
- Easy to integrate into any Dart or Flutter app
- No DB dependency required for login state

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  (coming soon)
```

Then run:

```bash
flutter pub get
```

> ✨ Will be available on pub.dev soon!

---

## 🚀 Getting Started

### Primitive Example (int - userId)

```dart
final session = await UserSessionManager.create<int>(encrypt: false);

await session.login(42);                      // Save user ID
final userId = await session.getUser();       // 42
final isLoggedIn = await session.isLoggedIn(); // true

await session.logout();
```

---

### Custom Object Example

```dart
class User {
  final int id;
  final String name;

  User(this.id, this.name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory User.fromJson(Map<String, dynamic> json) =>
      User(json['id'], json['name']);

  factory User.fromJson(Map<String, dynamic> json) => User(
    json['id'],
    json['name'],
  );
 }

final session = await UserSessionManager.create<User>(
  encrypt: true,
  toJson: (u) => u.toJson(),
  fromJson: (json) => User.fromJson(json),
);

await session.login(User(1, 'Alice'));
final user = await session.getUser(); // User instance
```

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

### `UserSessionManager<T>`

| Method             | Description                         |
|--------------------|-------------------------------------|
| `login(T user)`    | Saves the session                   |
| `logout()`         | Clears the session                  |
| `getUser()`        | Retrieves the stored object or null |
| `isLoggedIn()`     | Returns true if a user exists       |

---

## When to Use

| Use Case                           | Use this package? |
|------------------------------------|-------------------|
| Fast session check at startup      | ✅ Yes            |
| Complex profile management         | ❌ Use your DB     |
| Persisting lightweight identity    | ✅ Yes            |
| Storing auth tokens securely       | ✅ Yes (`encrypt`) |
| Testing login logic without DB     | ✅ Yes            |

---

## 🛡️ Security

- When `encrypt: true`, session data is stored via `flutter_secure_storage`
- ❗ Do not store sensitive data like raw passwords

---

## 📂 Folder Structure

```
lib/
├── user_session_manager.dart         # Public API
└── src/
    ├── api/
    ├── application/
    ├── domain/
    ├── data/
```

---

## 📜 License

MIT License. See [LICENSE](LICENSE) for details.
