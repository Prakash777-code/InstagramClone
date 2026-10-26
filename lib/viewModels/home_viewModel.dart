import 'package:flutter/material.dart';
import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/models/posts.dart';
import 'package:instagram/models/posts_response.dart';
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
  String? errorMessage;
  List<Posts> posts = [];
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
      print("GET POSTS: ${posts.length}");
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
      print("BEFORE: ${posts.length}");
      final morePosts = await postsRepository.getAllPosts(nextPage, limit);
      final postsResponse = morePosts.data as PostsResponse;
      print("RECEIVED: ${postsResponse.posts.length}");
      posts.addAll(postsResponse.posts);
      print("AFTER: ${posts.length}");
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
}
