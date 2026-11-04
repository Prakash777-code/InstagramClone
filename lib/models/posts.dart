class Posts {
  final int id;
  final int userId;
  final String name;
  final String postUrl;
  bool isFollowing;
  int likes;
  bool isLiked;

  Posts({
    required this.id,
    required this.userId,
    required this.name,
    required this.postUrl,
    required this.likes,
    required this.isLiked,
    required this.isFollowing,
  });

  factory Posts.fromJson(Map<String, dynamic> json) {
    return Posts(
      id: json["id"],
      userId: json["userId"],
      name: json["name"],
      postUrl: json["postUrl"],
      likes: json["likes"],
      isLiked: json["isLiked"],
      isFollowing: json["isFollowing"],
    );
  }
}
