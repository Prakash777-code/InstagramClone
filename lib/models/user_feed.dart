class UserFeed {
  final int id;
  final int userId;
  final String postUrl;
  final String userName;
  int likes;

  UserFeed({
    required this.id,
    required this.userId,
    required this.postUrl,
    required this.userName,
    required this.likes,
  });

  factory UserFeed.fromJson(Map<String, dynamic> json) {
    return UserFeed(
      id: json["id"],
      userId: json["userId"],
      postUrl: json["postUrl"],
      userName: json["user"]["name"],
      likes: json["_count"]["likes"],
    );
  }
}
