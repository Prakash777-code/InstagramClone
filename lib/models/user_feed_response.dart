import 'package:instagram/models/user_feed.dart';

class UserFeedResponse {
  final List<UserFeed> userFeed;
  final int totalPosts;

  UserFeedResponse({required this.userFeed, required this.totalPosts});

  factory UserFeedResponse.fromJson(Map<String, dynamic> json) {
    return UserFeedResponse(
      userFeed: (json["userFeed"] as List)
          .map((item) => UserFeed.fromJson(item))
          .toList(),
      totalPosts: json["totalPosts"],
    );
  }
}
