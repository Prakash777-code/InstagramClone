import 'dart:convert';

import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/response/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/services/secure_storage.dart';

class AuthApiService {
  final baseUrl = "http://172.20.10.2:3000";
  //https://instagrambackend-aeed.onrender.com
  final secureStorage = SecureStorage();
  static bool isSeesionExpired = false;

  Future<ApiResponse> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("${baseUrl}/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    return ApiResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
    );
  }

  Future<ApiResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("${baseUrl}/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    print("LOGIN API RESPONSE :${response.body}");
    return ApiResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
    );
  }

  Future<String> refreshToken() async {
    print("REFRESH TOKEN CALLED");
    final refreshToken = await secureStorage.getRefreshToken();
    if (refreshToken == null) {
      print("REFRESH TOKEN IS NULL");
      AuthApiService.isSeesionExpired = true;
      throw UnauthorizedException("Session expired. Please login again.");
    }
    final response = await http.post(
      Uri.parse("${baseUrl}/auth/refresh"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );
    print("REFRESH STATUS: ${response.statusCode}");
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      AuthApiService.isSeesionExpired = false;
      return data["accessToken"];
    }
    AuthApiService.isSeesionExpired = true;
    await secureStorage.clearTokens();
    throw UnauthorizedException(
      data["message"] ?? "Session expired. Please login again.",
    );
  }

  Future<ApiResponse> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final passwordUpdateToken = await secureStorage.getPasswordUpdateToken();
    final response = await http.post(
      Uri.parse("${baseUrl}/auth/updatePassword"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "currentPassword": currentPassword,
        "newPassword": newPassword,
        "passwordUpdateToken": passwordUpdateToken,
      }),
    );
    print("UPDATE PASSWORD API RESPONSE :${response.body}");
    return ApiResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
    );
  }

  Future<ApiResponse> requestOtp(String email) async {
    final response = await http.post(
      Uri.parse("${baseUrl}/auth/send-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    print("REQUEST OTP RESPONSE :${response.body}");
    return ApiResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
    );
  }

  Future<ApiResponse> verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse("${baseUrl}/auth/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    print("VERIFY API RESPONSE :${res.body}");
    return ApiResponse(statusCode: res.statusCode, data: jsonDecode(res.body));
  }

  Future<ApiResponse> resetPassword(
    String resetToken,
    String newPassword,
  ) async {
    final res = await http.post(
      Uri.parse("${baseUrl}/auth/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(({
        "resetToken": resetToken,
        "newPassword": newPassword,
      })),
    );
    print("RESET PASSWORD API RESPONSE :${res.body}");
    return ApiResponse(statusCode: res.statusCode, data: jsonDecode(res.body));
  }
}
