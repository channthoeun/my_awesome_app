class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  // A factory constructor for creating a new User instance from a map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}