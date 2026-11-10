import 'package:instagram/models/profile_preview.dart';

class ProfilePreviewResponse {
  final List<ProfilePreview> profilePreview;
  final int followers;
  final int following;
  bool isFollowing;
  final int userId;
  final String name;

  ProfilePreviewResponse({
    required this.followers,
    required this.following,
    required this.profilePreview,
    required this.isFollowing,
    required this.name,
    required this.userId,
  });

  factory ProfilePreviewResponse.fromJson(Map<String, dynamic> json) {
    return ProfilePreviewResponse(
      profilePreview: (json["profile"] as List)
          .map((item) => ProfilePreview.fromJson(item))
          .toList(),
      followers: json["connections"]["_count"]["followers"],
      following: json["connections"]["_count"]["following"],
      isFollowing: json["isFollowing"],
      name: json["name"],
      userId: json["userId"],
    );
  }
}
