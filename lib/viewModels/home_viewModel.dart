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
  Set<int> likedIds = {};
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
     print("Posts length${posts.length }");
    notifyListeners();
    try {
      final res = await postsRepository.getAllPosts(1, limit);
      final postsResponse = res.data as PostsResponse;
      posts = postsResponse.posts;
      final postIds = posts.map((id) => id.id).toList();
      final idRes = await postsRepository.getLikedPostsIds(postIds);
      likedIds = Set<int>.from(idRes.data["data"]);
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
    print("Load more called");
   
    if (await checkSessionExpired()) return;
    if (isLoadingMore) {
      return;
    }
    if (posts.length >= totalPosts) {
      return;
    }
    final nextPage = currentPage + 1;
    print("POSTS LENGTH: ${posts.length}");
    print("TOTAL POSTS: $totalPosts");
    print("CURRENT PAGE: $currentPage");
    print("IS LOADING MORE: $isLoadingMore");
    isLoadingMore = true;
    errorMessage = null;
    notifyListeners();
    try {
      final morePosts = await postsRepository.getAllPosts(nextPage, limit);
      final postsResponse = morePosts.data as PostsResponse;
      final newPosts = postsResponse.posts;
      posts.addAll(newPosts);
      final postIds = newPosts.map((id) => id.id).toList();
      final res = await postsRepository.getLikedPostsIds(postIds);
      likedIds.addAll(Set<int>.from(res.data["data"]));
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
