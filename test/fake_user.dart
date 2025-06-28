class FakeUser {
  final int id;
  final String name;

  FakeUser(this.id, this.name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  static FakeUser fromJson(Map<String, dynamic> json) =>
      FakeUser(json['id'], json['name']);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FakeUser &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}