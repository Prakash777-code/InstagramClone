import 'package:flutter/material.dart' hide Notification;
import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/models/notification_model.dart';
import 'package:instagram/repository/auth_repository.dart';
import 'package:instagram/repository/notification_repository.dart';
import 'package:instagram/models/notification_list.dart';
import 'package:instagram/services/secure_storage.dart';

class NotificationViewModel extends ChangeNotifier {
  final notificationRepository = NotificationRepository();
  final authRepository = AuthRepository();
  final secureStorage = SecureStorage();
  bool isLoading = false;
  bool isLoadingMore = false;
  bool pushToLogin = false;
  String? errorMessage;
  List<NotificationList> notificationList = [];
  int currentPage = 1;
  int limit = 10;
  int totalNotifications = 0;
  int? lastSeenNotificationId;
  bool showNotificationBadge = false;

  Future<void> getNotifications() async {
    if (await authRepository.isSeesionExpired()) return;
    isLoading = true;
    errorMessage = null;
    currentPage = 1;
    notifyListeners();
    try {
      final res = await notificationRepository.getUserNotifications(
        currentPage,
        limit,
      );
      final notificationRes = res.data as NotificationModel;
      notificationList = notificationRes.notificationList;
      totalNotifications = notificationRes.totalNotifications;
      showNotificationBadge = false;
    } on AppException catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNotifications() async {
    if (await authRepository.isSeesionExpired()) return;
    if (isLoadingMore) {
      return;
    }
    if (notificationList.length >= totalNotifications) {
      return;
    }
    final nextPage = currentPage + 1;
    isLoadingMore = true;
    errorMessage = null;
    try {
      final moreNotifications = await notificationRepository
          .getUserNotifications(nextPage, limit);
      final notificationRes = moreNotifications.data as NotificationModel;
      notificationList.addAll(notificationRes.notificationList);
      currentPage = nextPage;
    } on AppException catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> hasUnreadNotification() async {
    final res = await notificationRepository.hasUnreadNotification();
    final hasUnread = res.data["unread"];
    if (hasUnread == true) {
      showNotificationBadge = true;
    } else {
      showNotificationBadge = false;
    }
    notifyListeners();
  }

  Future<bool> checkSessionExpired() async {
    final expired = await authRepository.isSeesionExpired();
    if (expired) {
      pushToLogin = true;
      notifyListeners();
      return true;
    }
    return false;
  }
}
