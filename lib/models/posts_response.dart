import 'package:instagram/models/posts.dart';

class PostsResponse {
  final List<Posts> posts;
  final int totalPosts;

  PostsResponse({
    required this.posts,
    required this.totalPosts,
  });

  factory PostsResponse.fromJson(Map<String, dynamic> json) {
    return PostsResponse(
      posts: (json["data"] as List)
          .map((item) => Posts.fromJson(item))
          .toList(),
      totalPosts: json["totalPosts"],
    );
  }


}