class UserPostsList {
  final int id;
  final String imageUrl;

  UserPostsList({required this.id, required this.imageUrl});

  factory UserPostsList.fromJson(Map<String, dynamic> json) {
    return UserPostsList(id: json["id"], imageUrl: json["postUrl"]);
  }
}
