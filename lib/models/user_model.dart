class UserPermission {
  final int id;
  final String name;
  final String codename;

  UserPermission({required this.id, required this.name, required this.codename});

  factory UserPermission.fromJson(Map<String, dynamic> json) {
    return UserPermission(id: json['id'], name: json['name'], codename: json['codename']);
  }
}

class Branch {
  final String id;
  final String name;
  final String address;
  final String phone;

  Branch({required this.id, required this.name, required this.address, required this.phone});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(id: json['id'], name: json['name'], address: json['address'], phone: json['phone']);
  }
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final Branch branch;
  final List<UserPermission> permissions;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.branch,
    required this.permissions,
  });

  String get fullName => '$firstName $lastName';

  // ADD THIS GETTER
  String get initials {
    // Handles cases where names might be empty
    final List<String> nameParts = fullName.trim().split(' ');
    if (nameParts.isEmpty || nameParts.first.isEmpty) {
      return '?';
    }
    final String firstInitial = nameParts.first[0].toUpperCase();
    if (nameParts.length > 1 && nameParts.last.isNotEmpty) {
      final String lastInitial = nameParts.last[0].toUpperCase();
      return '$firstInitial$lastInitial';
    }
    return firstInitial;
  }

  bool hasPermission(String codename) {
    return permissions.any((p) => p.codename == codename);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    var permissionsList = json['user_permissions'] as List;
    List<UserPermission> parsedPermissions = permissionsList.map((p) => UserPermission.fromJson(p)).toList();

    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      email: json['email'],
      branch: Branch.fromJson(json['branch']),
      permissions: parsedPermissions,
    );
  }
}