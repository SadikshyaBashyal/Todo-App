class AppUser {
  final String username;
  final String password;
  final String name;
  final String? photoPath;

  AppUser({
    required this.username,
    required this.password,
    required this.name,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'name': name,
        'photoPath': photoPath,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        username: json['username'],
        password: json['password'],
        name: json['name'],
        photoPath: json['photoPath'],
      );
} 