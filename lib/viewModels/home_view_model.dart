import 'package:flutter/material.dart';
import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/models/posts.dart';
import 'package:instagram/models/posts_response.dart';
import 'package:instagram/models/user_feed.dart';
import 'package:instagram/models/user_feed_response.dart';
import 'package:instagram/repository/auth_repository.dart';
import 'package:instagram/repository/posts_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final postsRepository = PostsRepository();
  final authRepository = AuthRepository();
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isLiking = false;
  bool retry = false;
  bool pushToLogin = false;
  bool isFollowingLoading = false;
  String? errorMessage;
  List<Posts> posts = [];
  List<UserFeed> postFeed = [];
  List<int> likedIds = [];
  List<int> followingId = [];
  int currentPage = 1;
  int limit = 5;
  int totalPosts = 0;
  int? likes;

  Future<void> getAllPosts() async {
    if (await authRepository.isSeesionExpired()) return;
    pushToLogin = false;
    isLoading = true;
    errorMessage = null;
    retry = false;
    currentPage = 1;
    notifyListeners();
    try {
      final res = await postsRepository.getAllPosts(1, limit);
      final postsResponse = res.data as PostsResponse;
      posts = postsResponse.posts;
      totalPosts = postsResponse.totalPosts;
    } on AppException catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
      retry = true;
    } catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
      retry = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (await checkSessionExpired()) return;
    if (isLoadingMore) {
      return;
    }
    if (posts.length >= totalPosts) {
      return;
    }
    final nextPage = currentPage + 1;
    isLoadingMore = true;
    errorMessage = null;
    notifyListeners();
    try {
      final morePosts = await postsRepository.getAllPosts(nextPage, limit);
      final postsResponse = morePosts.data as PostsResponse;
      posts.addAll(postsResponse.posts);
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

  Future<void> likePost(int postId) async {
    if (await authRepository.isSeesionExpired()) return;
    isLiking = true;
    errorMessage = null;
    notifyListeners();
    try {
      await postsRepository.likePost(postId);
      likedIds.add(postId);
    } on AppException catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } finally {
      isLiking = false;
      notifyListeners();
    }
  }

  Future<void> unlikePost(int postId) async {
    if (await authRepository.isSeesionExpired()) return;
    isLiking = true;
    errorMessage = null;
    notifyListeners();
    try {
      await postsRepository.unlikePost(postId);
      likedIds.remove(postId);
    } on AppException catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } finally {
      isLiking = false;
      notifyListeners();
    }
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

  Future<void> follow(int profileId) async {
    if (isFollowingLoading) return;
    isFollowingLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await postsRepository.follow(profileId);
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isFollowingLoading = false;
      notifyListeners();
    }
  }

  Future<void> unFollow(int profileId) async {
    if (isFollowingLoading) return;
    isFollowingLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await postsRepository.unFollow(profileId);
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isFollowingLoading = false;
      notifyListeners();
    }
  }

  Future<void> getUserFeed() async {
    if (await authRepository.isSeesionExpired()) return;
    pushToLogin = false;
    isLoading = true;
    errorMessage = null;
    retry = false;
    currentPage = 1;
    notifyListeners();
    try {
      final res = await postsRepository.getPostFeed(1, limit);
      final feedRes = res.data as UserFeedResponse;
      postFeed = feedRes.userFeed;
      totalPosts = feedRes.totalPosts;
      final postIds = feedRes.userFeed.map((id) => id.id).toList();
      await postsRepository.getLikedIds(postIds);
      final userIds = feedRes.userFeed.map((post) => post.userId).toList();
      final userIdRes = await postsRepository.getFollowingIds(userIds);
      followingId = List<int>.from(userIdRes.data);
    } on AppException catch (e) {
      if (await authRepository.isSeesionExpired()) return;
      errorMessage = e.message;
      retry = true;
    } catch (e) {
      if (await authRepository.isSeesionExpired()) return;
      errorMessage = e.toString();
      retry = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextFeed() async {
    if (await checkSessionExpired()) return;
    if (isLoadingMore) {
      return;
    }
    if (postFeed.length >= totalPosts) {
      return;
    }
    final nextPage = currentPage + 1;
    isLoadingMore = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await postsRepository.getPostFeed(nextPage, limit);
      final feedRes = res.data as UserFeedResponse;
      postFeed.addAll(feedRes.userFeed);
      currentPage = nextPage;
      totalPosts = feedRes.totalPosts;
      final postIds = feedRes.userFeed.map((id) => id.id).toList();
      final idRes = await postsRepository.getLikedIds(postIds);
      likedIds.addAll(List<int>.from(idRes.data));
      final userIds = feedRes.userFeed.map((id) => id.userId).toList();
      final userIdRes = await postsRepository.getFollowingIds(userIds);
      followingId.addAll(List<int>.from(userIdRes.data));
      followingId = followingId.toSet().toList();
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

  void updateFollowingStatus(int userId, bool isFollowing) {
    if (isFollowing) {
      followingId.add(userId);
    } else {
      followingId.remove(userId);
    }
    notifyListeners();
  }
}
