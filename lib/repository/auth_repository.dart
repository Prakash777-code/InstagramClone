import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/repository/notification_repository.dart';
import 'package:instagram/response/api_response.dart';
import 'package:instagram/services/auth_api_service.dart';
import 'package:instagram/services/firebase_notification_service.dart';
import 'package:instagram/utils/helper.dart';

import '../services/secure_storage.dart';

class AuthRepository {
  final authApiservice = AuthApiService();
  final secureStorage = SecureStorage();
  final helper = Helper();
  final firebaseNotificationService = FirebaseNotificationService();
  final notificationRepository = NotificationRepository();
  bool changePasswordRequired = false;

  Future<ApiResponse> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await authApiservice.register(name, email, password);
      helper.handleRequest(response);
      return response;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await authApiservice.login(email, password);
      helper.handleRequest(response);
      if (response.statusCode == 201 &&
          response.data["passwordChangeRequired"] == true) {
        changePasswordRequired = true;
        await secureStorage.saveRefreshToken(response.data["refreshToken"]);
      } else {
        changePasswordRequired = false;
        await secureStorage.saveTokens(
          response.data["accessToken"],
          response.data["refreshToken"],
        );
        print("GETTING FCM TOKEN");
        try {
          final fcmToken = await firebaseNotificationService.getToken();
          if (fcmToken != null) {
            await notificationRepository.saveFcmToken(fcmToken);
            await secureStorage.saveFcmToken(fcmToken);
          }
        } catch (e) {
          print(e);
        }
      }
      return response;
    } on AppException {
      rethrow;
    }
  }

  Future<void> logout() async {
    final fcmToken = await secureStorage.getFcmToken();
    try {
      if (fcmToken != null) {
        await notificationRepository.deleteFcmToken(fcmToken);
      }
    } catch (e) {
      print(e);
    } finally {
      await secureStorage.clearTokens();
    }
  }

  Future<bool> isLoggedIn() async {
    final accessToken = await secureStorage.getAccessToken();
    final refreshToken = await secureStorage.getRefreshToken();
    if (accessToken == null || refreshToken == null) {
      return false;
    }
    return true;
  }

  Future<ApiResponse> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await authApiservice.updatePassword(
        currentPassword,
        newPassword,
      );
      helper.handleRequest(response);
      return response;
    } on AppException {
      rethrow;
    }
  }
}
