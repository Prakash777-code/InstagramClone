import 'package:instagram/models/profile_post.dart';

class Profile {
  final String name;
  final List<ProfilePost> posts;
  final int followers;
  final int following;

  Profile({
    required this.name,
    required this.posts,
    required this.followers,
    required this.following,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json["name"],
      posts: (json["posts"] as List)
          .map((post) => ProfilePost.fromJson(post))
          .toList(),
      followers: json["followers"] ?? 0,
      following: json["following"] ?? 0,
    );
  }
}
