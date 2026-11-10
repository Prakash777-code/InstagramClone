class ProfilePreview {
  final String postUrl;

  ProfilePreview({required this.postUrl});

  factory ProfilePreview.fromJson(Map<String, dynamic> json) {
    return ProfilePreview(postUrl: json["postUrl"]);
  }
}
