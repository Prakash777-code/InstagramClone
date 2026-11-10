import 'package:flutter/foundation.dart';
import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/models/search_user_response.dart';
import 'package:instagram/models/users.dart';
import 'package:instagram/repository/auth_repository.dart';
import 'package:instagram/repository/posts_repository.dart';
import 'package:instagram/utils/helper.dart';

class SearchUserViewModel extends ChangeNotifier {
  final postsRepository = PostsRepository();
  final authRepository = AuthRepository();
  final helper = Helper();
  bool isLoading = false;
  bool isLoadingMore = false;
  bool pushToLogin = false;
  int currentPage = 1;
  int limit = 10;
  int totalresults = 0;
  String? Query;
  String? errorMessage;
  List<Users> users = [];

  Future<void> searchUser(String query) async {
    if (isLoadingMore) return;
    if (query.trim().isEmpty) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    currentPage = 1;
    notifyListeners();
    try {
      final res = await postsRepository.searchUsers(query, 1, limit);
      final success = res.data as SearchUserResponse;
      users = success.users;
      Query = query;
      totalresults = success.totalResults;
    } on AppException catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.message;
    } catch (e) {
      if (await checkSessionExpired()) return;
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (isLoading || isLoadingMore) return;
    if (users.length >= totalresults) {
      return;
    }
    isLoadingMore = true;
    errorMessage = null;
    notifyListeners();
    int nextPage = currentPage + 1;
    try {
      final res = await postsRepository.searchUsers(Query!, nextPage, limit);
      final success = res.data as SearchUserResponse;
      users.addAll(success.users);
      currentPage = nextPage;
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
