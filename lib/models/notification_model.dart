import 'package:instagram/models/followingIds.dart';
import 'package:instagram/models/notification_list.dart';

class NotificationModel {
  final List<NotificationList> notificationList;
  final int totalNotifications;
  final List<FollowingIds> followingIds;

  NotificationModel({
    required this.notificationList,
    required this.followingIds,
    required this.totalNotifications,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationList: (json["data"] as List)
          .map((item) => NotificationList.fromJson(item))
          .toList(),
      followingIds: (json["followingIds"] as List).map((item) => FollowingIds.fromJson(item)).toList(),
      totalNotifications: json["totalNotifications"],
    );
  }
}
