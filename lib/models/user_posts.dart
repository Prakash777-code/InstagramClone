import 'package:instagram/models/user_posts_list.dart';

class UserPosts {
  final List<UserPostsList> postlList;
  final int totalPosts;

  UserPosts({required this.postlList, required this.totalPosts});

  factory UserPosts.fromJson(Map<String, dynamic> json) {
    return UserPosts(
      postlList: (json["posts"] as List)
          .map((item) => UserPostsList.fromJson(item))
          .toList(),
      totalPosts: json["totalPosts"],
    );
  }
}
