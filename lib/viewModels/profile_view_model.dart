import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/models/profile.dart';
import 'package:instagram/models/profile_preview_response.dart';
import 'package:instagram/models/user_posts.dart';
import 'package:instagram/models/user_posts_list.dart';
import 'package:instagram/repository/auth_repository.dart';
import 'package:instagram/repository/posts_repository.dart';
import 'package:instagram/services/secure_storage.dart';

class ProfileViewModel extends ChangeNotifier {
  final postsRepository = PostsRepository();
  final authRepository = AuthRepository();
  final secureStorage = SecureStorage();
  bool isLoading = false;
  bool isFollowingLoader = false;
  bool buttonLoader = false;
  bool pushToLogin = false;
  String? errorMessage;
  Profile? profile;
  ProfilePreviewResponse? profilePreview;
  int currentPage = 1;
  int limit = 9;
  bool isLoadingMore = false;
  bool postsLoading = false;
  int totalPosts = 0;
  List<UserPostsList> userPostsList = [];
  String? userId;

  Future<void> getUserProfile() async {
    if (await authRepository.isSeesionExpired()) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await postsRepository.getUserProfile();
      profile = res.data;
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

  Future<void> uploadPost(File image) async {
    if (await authRepository.isSeesionExpired()) return;
    buttonLoader = true;
    errorMessage = null;
    notifyListeners();
    try {
      await postsRepository.uploadPost(image);
    } on AppException catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } finally {
      buttonLoader = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(int postId) async {
    if (await authRepository.isSeesionExpired()) return;
    buttonLoader = true;
    errorMessage = null;
    notifyListeners();
    try {
      await postsRepository.deletePost(postId);
    } on AppException catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } finally {
      buttonLoader = false;
      notifyListeners();
    }
  }

  void removePostLocally(int postId) {
    userPostsList.removeWhere((item) => item.id == postId);
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

  Future<void> getProfilebyId(int profileId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await postsRepository.getProfilePreview(profileId);
      profilePreview = res.data;
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

  Future<void> follow(int profileId) async {
    if (isFollowingLoader) return;
    isFollowingLoader = true;
    errorMessage = null;
    notifyListeners();
    try {
      await postsRepository.follow(profileId);
    } on AppException catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.message;
    } catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
      notifyListeners();
    } finally {
      isFollowingLoader = false;
      notifyListeners();
    }
  }

  Future<void> unfollow(int profileId) async {
    if (isFollowingLoader) return;
    isFollowingLoader = true;
    errorMessage = null;
    notifyListeners();
    try {
      await postsRepository.unFollow(profileId);
    } on AppException catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.message;
    } catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } finally {
      isFollowingLoader = false;
      notifyListeners();
    }
  }

  Future<void> getUserPosts() async {
    print("GET USER POSTS CALLED IN VM");
    if (postsLoading || isLoadingMore) return;
    errorMessage = null;
    postsLoading = true;
    currentPage = 1;
    notifyListeners();
    try {
      final res = await postsRepository.getUserPosts(currentPage, limit);
      final data = res.data as UserPosts;
      userPostsList = data.postlList;
      totalPosts = data.totalPosts;
      print("USER POSTS LENGTH :${userPostsList.length}");
      print("TOTAL USER POSTS :${totalPosts}");
    } on AppException catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.message;
    } catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } finally {
      postsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    print("CALLEDD NEXT PAGE");
    if (postsLoading || isLoadingMore) return;
    if (userPostsList.length >= totalPosts) return;
    int nextPage = currentPage + 1;
    isLoadingMore = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await postsRepository.getUserPosts(nextPage, limit);
      final data = res.data as UserPosts;
      userPostsList.addAll(data.postlList);
      currentPage = nextPage;
      print("CUREENT PAGE ${currentPage}");
      print("USER POSTS LENGTH AFTER NEXT PAGE :${userPostsList.length}");
    } on AppException catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.message;
    } catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> getUserIdFromStorage() async {
    userId = await secureStorage.getLoggedInUserId();
    print("USER ID IN PROFILE VM:${userId}");
  }
}
