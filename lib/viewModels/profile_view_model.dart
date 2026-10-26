import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/models/profile.dart';
import 'package:instagram/repository/auth_repository.dart';
import 'package:instagram/repository/posts_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final postsRepository = PostsRepository();
  final authRepository = AuthRepository();
  bool isLoading = false;
  bool buttonLoader = false;
  bool pushToLogin = false;
  String? errorMessage;
  Profile? profile;

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
    profile?.posts.removeWhere((item) => item.id == postId);
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
}
