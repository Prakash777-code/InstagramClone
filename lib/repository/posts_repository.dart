import 'dart:io';

import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/response/api_response.dart';
import 'package:instagram/services/posts_api_service.dart';
import 'package:instagram/utils/helper.dart';

class PostsRepository {
  final postsApiService = PostsApiService();
  final helper = Helper();

  Future<ApiResponse> getAllPosts(int page, int limit) async {
    try {
      final response = await postsApiService.getAllPosts(page, limit);
      return response;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> uploadPost(File image) async {
    try {
      final response = await postsApiService.upload(image);
      helper.handleRequest(response);
      return response;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> deletePost(int postId) async {
    try {
      final response = await postsApiService.deletePost(postId);
      helper.handleRequest(response);
      return response;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> likePost(int postId) async {
    try {
      final response = await postsApiService.likePost(postId);
      helper.handleRequest(response);
      return response;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> unlikePost(int postId) async {
    try {
      final response = await postsApiService.unlikePost(postId);
      helper.handleRequest(response);
      return response;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> getUserProfile() async {
    try {
      final response = await postsApiService.getUserProfile();
      helper.handleRequest(response);
      return response;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> follow(int profileId) async {
    try {
      final res = await postsApiService.follow(profileId);
      helper.handleRequest(res);
      return res;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> unFollow(int profileId) async {
    try {
      final res = await postsApiService.unFollow(profileId);
      helper.handleRequest(res);
      return res;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> getPostFeed(int page, int limit) async {
    try {
      final res = await postsApiService.getPostFeed(page, limit);
      helper.handleRequest(res);
      return res;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> getLikedIds(List<int> postIds) async {
    try {
      final res = await postsApiService.getLikedIds(postIds);
      helper.handleRequest(res);
      return res;
    } on AppException {
      rethrow;
    }
  }

  Future<ApiResponse> getFollowingIds(List<int> userIds) async {
    print('REPOSITORY CALLED FOR GET FOLLOWING');
    try {
      final res = await postsApiService.getFollowingIds(userIds);
      helper.handleRequest(res);
      return res;
    } on AppException {
      rethrow;
    }
  }
}
