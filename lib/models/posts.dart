class Posts {
  final int id;
  final int userId;
  final String name;
  final String postUrl;
  int likes;


  Posts({
    required this.id,
    required this.userId,
    required this.name,
    required this.postUrl,
    required this.likes,
  });

  factory Posts.fromJson(Map<String, dynamic> json) {
    return Posts(
      id: json["id"],
      userId: json["userId"],
      name: json["user"]["name"],
      postUrl: json["postUrl"],
      likes: json["_count"]["likes"],
    );
  }
}
