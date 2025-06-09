class User {
  final int? id;
  final String username;
  final String password;
  final String? imagePath;

  User({
    this.id,
    required this.username,
    required this.password,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'imagePath': imagePath,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      imagePath: map['imagePath'],
    );
  }
}
