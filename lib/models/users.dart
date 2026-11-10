class Users {
  final int userId;
  final String name;

  Users({required this.name, required this.userId});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(name: json["name"], userId: json["id"]);
  }
}
