class FollowingIds {
  final int followingId;

  FollowingIds({required this.followingId});

  factory FollowingIds.fromJson(Map<String, dynamic> json) {
    return FollowingIds(
      followingId: json["followingId"],
    );
  }
}