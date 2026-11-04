import 'dart:convert';
import 'dart:io';

import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/models/posts_response.dart';
import 'package:instagram/models/user_feed_response.dart';
import 'package:instagram/response/api_response.dart';
import 'package:instagram/services/auth_api_service.dart';
import 'package:instagram/services/secure_storage.dart';
import 'package:instagram/models/profile.dart';
import 'package:http/http.dart' as http;

class PostsApiService {
  final baseUrl = "https://instagrambackend-aeed.onrender.com";
  final secureStorage = SecureStorage();
  final authApiService = AuthApiService();

  Future<ApiResponse> getAllPosts(int page, int limit) async {
    var accessToken = await secureStorage.getAccessToken();
    if (accessToken == null) {
      throw UnauthorizedException("Unauthorised");
    }
    var response = await http.get(
      Uri.parse("${baseUrl}/posts?page=${page}&limit=${limit}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (response.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      response = await http.get(
        Uri.parse("${baseUrl}/posts?page=${page}&limit=5"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );
    }
    print("GET POSTS RESONSE: ${response.body}");
    final data = jsonDecode(response.body);
    final postsResponse = PostsResponse.fromJson(data);
    return ApiResponse(statusCode: response.statusCode, data: postsResponse);
  }

  Future<ApiResponse> upload(File image) async {
    var accessToken = await secureStorage.getAccessToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/posts/upload'),
    );
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/posts/upload'),
      );
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    }
    return ApiResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
    );
  }

  Future<ApiResponse> deletePost(int postId) async {
    var accessToken = await secureStorage.getAccessToken();
    if (accessToken == null) {
      throw UnauthorizedException("Unauthorised");
    }
    var response = await http.delete(
      Uri.parse("${baseUrl}/posts/post/${postId}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (response.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      response = await http.delete(
        Uri.parse("${baseUrl}/posts/post/${postId}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );
    }
    return ApiResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
    );
  }

  Future<ApiResponse> likePost(int postId) async {
    var accessToken = await secureStorage.getAccessToken();
    var response = await http.post(
      Uri.parse("${baseUrl}/posts/like/${postId}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (response.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      response = await http.post(
        Uri.parse("${baseUrl}/posts/like/${postId}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );
    }
    return ApiResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
    );
  }

  Future<ApiResponse> unlikePost(int postId) async {
    var accessToken = await secureStorage.getAccessToken();
    var response = await http.delete(
      Uri.parse("${baseUrl}/posts/like/${postId}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (response.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      response = await http.delete(
        Uri.parse("${baseUrl}/posts/like/${postId}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );
    }
    return ApiResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
    );
  }

  Future<ApiResponse> getUserProfile() async {
    print("REACHED GET PROFILE");
    var accessToken = await secureStorage.getAccessToken();
    print("PROFILE ACCESS TOKEN: $accessToken");
    if (accessToken == null) {
      throw UnauthorizedException("Unauthorised");
    }
    var response = await http.get(
      Uri.parse("${baseUrl}/posts/user"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (response.statusCode == 401) {
      print("PROFILE 401");
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      response = await http.get(
        Uri.parse("${baseUrl}/posts/user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );
    }
    print("BEFORE JSON DECODE");
    final data = jsonDecode(response.body);

    print("AFTER JSON DECODE");
    final profile = Profile.fromJson(data["data"]);

    print("AFTER PROFILE PARSING");
    print("GET USER PROFILE:${response.body}");
    return ApiResponse(statusCode: response.statusCode, data: profile);
  }

  Future<ApiResponse> follow(int profileId) async {
    var accessToken = await secureStorage.getAccessToken();
    var res = await http.post(
      Uri.parse("${baseUrl}/posts/follow/${profileId}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (res.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      res = await http.post(
        Uri.parse("${baseUrl}/posts/follow/${profileId}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );
    }
    print("FOLLOW API RESPONSE :${res.body}");
    final success;
    if (res.body.isNotEmpty) {
      success = jsonDecode(res.body);
    } else {
      success = null;
    }
    return ApiResponse(statusCode: res.statusCode, data: success);
  }

  Future<ApiResponse> unFollow(int profileId) async {
    var accessToken = await secureStorage.getAccessToken();
    var res = await http.delete(
      Uri.parse("${baseUrl}/posts/unfollow/${profileId}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (res.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      res = await http.delete(
        Uri.parse("${baseUrl}/posts/unfollow/${profileId}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );
    }
    print("UNFOLLOW API RESPONSE :${res.body}");
    return ApiResponse(statusCode: res.statusCode, data: jsonDecode(res.body));
  }

  Future<ApiResponse> getPostFeed(int page, int limit) async {
    var accessToken = await secureStorage.getAccessToken();
    var res = await http.get(
      Uri.parse("${baseUrl}/posts/user-feed?page=${page}&limit=${limit}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (res.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      res = await http.get(
        Uri.parse("${baseUrl}/posts/user-feed?page=${page}&limit=${limit}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );
    }
    print("GET POST FEED API RESPONSE :${res.body}");
    final data = jsonDecode(res.body);

    print("FEED TYPE: ${data['feedType']}");
    print("USER FEED: ${data['userFeed']}");

    final feedRes = UserFeedResponse.fromJson(data);

    print("PARSED FEED LENGTH: ${feedRes.userFeed.length}");
    print("TOTAL POSTS: ${feedRes.totalPosts}");
    return ApiResponse(statusCode: res.statusCode, data: feedRes);
  }

  Future<ApiResponse> getLikedIds(List<int> postIds) async {
    var accessToken = await secureStorage.getAccessToken();
    var res = await http.post(
      Uri.parse("${baseUrl}/posts/liked"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode({"postIds": postIds}),
    );
    if (res.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      res = await http.post(
        Uri.parse("${baseUrl}/posts/liked"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode({"postIds": postIds}),
      );
    }
    print("LIKED ID API RESPONSE :${res.body}");
    return ApiResponse(
      statusCode: res.statusCode,
      data: jsonDecode(res.body)["likedIds"],
    );
  }

  Future<ApiResponse> getFollowingIds(List<int> userIds) async {
    print("GET FOLLOWING FUNCTIN CALLED");
    var accessToken = await secureStorage.getAccessToken();
    var res = await http.post(
      Uri.parse("${baseUrl}/posts/following"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode({"userIds": userIds}),
    );
    if (res.statusCode == 401) {
      accessToken = await authApiService.refreshToken();
      await secureStorage.saveAccessToken(accessToken);
      res = await http.post(
        Uri.parse("${baseUrl}/posts/following"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode({"userIds": userIds}),
      );
    }
    print("Following ID API RESPONSE :${res.body}");
    return ApiResponse(
      statusCode: res.statusCode,
      data: jsonDecode(res.body)["followingIds"],
    );
  }
}
