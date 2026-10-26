import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:instagram/models/notification_model.dart';
import 'package:instagram/response/api_response.dart';
import 'package:instagram/services/auth_api_service.dart';
import 'package:instagram/services/secure_storage.dart';

class NotificationApiService {
  final baseUrl = "http://172.20.10.2:3000";
  final secureStorage = SecureStorage();
  final authApiService = AuthApiService();

  Future<ApiResponse> getUserNotifications(int page, int limit) async {
    print("NOTIFICATION API ");
    var accessToken = await secureStorage.getAccessToken();
    var response = await http.get(
      Uri.parse("${baseUrl}/posts/notification?page=${page}&limit=${limit}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (response.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      response = await http.get(
        Uri.parse("${baseUrl}/posts/notification?page=${page}&limit=${limit}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );
    }
    print("NOTIFICATION API RESPONSE : ${response.body}");
    final data = json.decode(response.body);
    final notificationRes = NotificationModel.fromJson(data);
    return ApiResponse(statusCode: response.statusCode, data: notificationRes);
  }

  Future<ApiResponse> hasUnreadNotification() async {
    var accessToken = await secureStorage.getAccessToken();
    var response = await http.get(
      Uri.parse("${baseUrl}/posts/unread"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (response.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      response = await http.get(
        Uri.parse("${baseUrl}/posts/unread"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );
    }
    print("UNREAD API RESPONSE : ${response.body}");
    final data = json.decode(response.body);
    return ApiResponse(statusCode: response.statusCode, data: data);
  }

  Future<ApiResponse> saveFcmToken(String fcmToken) async {
    var accessToken = await secureStorage.getAccessToken();
    var response = await http.post(
      Uri.parse("${baseUrl}/posts/notifications/fcm-token"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: json.encode({"fcmToken": fcmToken}),
    );
    if (response.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      response = await http.post(
        Uri.parse("${baseUrl}/posts/notifications/fcm-token"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: json.encode({"fcmToken": fcmToken}),
      );
    }
    print("SAVE FCM TOKEN RESPONSE : ${response.body}");
    final data = json.decode(response.body);
    return ApiResponse(statusCode: response.statusCode, data: data);
  }

  Future<ApiResponse> deleteFcmToken(String fcmToken) async {
    var accessToken = await secureStorage.getAccessToken();
    var res = await http.delete(
      Uri.parse("${baseUrl}/posts/notification/fcm"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: json.encode({"fcmToken": fcmToken}),
    );
    if (res.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      res = await http.delete(
        Uri.parse("${baseUrl}/posts/notification/fcm"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: json.encode({"fcmToken": fcmToken}),
      );
    }
    print("DELETE FCM RESPONSE : ${res.body}");
    return ApiResponse(statusCode: res.statusCode, data: jsonDecode(res.body));
  }
}
