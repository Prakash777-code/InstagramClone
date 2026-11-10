import 'package:instagram/models/users.dart';

class SearchUserResponse {
  final List<Users> users;
  final int totalResults;

  SearchUserResponse({required this.totalResults, required this.users});

  factory SearchUserResponse.fromJson(Map<String, dynamic> json) {
    return SearchUserResponse(
      users: (json["users"] as List)
          .map((item) => Users.fromJson(item))
          .toList(),
      totalResults: json["totalResult"],
    );
  }
}
