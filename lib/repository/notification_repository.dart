import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/response/api_response.dart';
import 'package:instagram/services/notification_api_service.dart';
import 'package:instagram/utils/helper.dart';

class NotificationRepository {
  final helper = Helper();
  final notificationApiService = NotificationApiService();

  Future<ApiResponse> getUserNotifications(int page, int limit) async {
    try {
      final response = await notificationApiService.getUserNotifications(
        page,
        limit,
      );
      helper.handleRequest(response);
      return response;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> hasUnreadNotification() async {
    try {
      final response = await notificationApiService.hasUnreadNotification();
      helper.handleRequest(response);
      return response;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> saveFcmToken(String fcmToken) async {
    try {
      final response = await notificationApiService.saveFcmToken(fcmToken);
      helper.handleRequest(response);
      return response;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> deleteFcmToken(String fcmToken) async {
    try {
      final response = await notificationApiService.deleteFcmToken(fcmToken);
      helper.handleRequest(response);
      return response;
    } on AppException {
      rethrow;
    }
  }
}
