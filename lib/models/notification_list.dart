class NotificationList {
  final int id;
  final String? imageUrl;
  final String userName;
  final int userId;
  final int senderId;
  final String notificationType;
  final String createdAt;

  NotificationList({
    required this.id,
    required this.imageUrl,
    required this.userName,
    required this.createdAt,
    required this.senderId,
    required this.userId,
    required this.notificationType,
  });

  factory NotificationList.fromJson(Map<String, dynamic> json) {
    return NotificationList(
      id: json["id"] as int? ?? 0,
      imageUrl: json["imageUrl"],
      senderId: json["senderId"] ?? 0,
      userName: json["userName"] ?? "User",
      createdAt: json["created_at"] ?? "Now",
      userId: json["userId"] ?? 0,
      notificationType: json["notificationType"] ?? "",
    );
  }
}
