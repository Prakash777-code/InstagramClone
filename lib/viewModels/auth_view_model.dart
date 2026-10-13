import 'package:flutter/material.dart';
import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/repository/auth_repository.dart';
import 'package:instagram/utils/helper.dart';

class AuthViewModel extends ChangeNotifier {
  final authRepository = AuthRepository();
  final helper = Helper();
  bool isLoading = false;
  String? errorMessage;
  bool isLoggedIn = false;
  bool changePasswordRequired = false;

  Future<void> register(String name, String email, String password) async {
    errorMessage = helper.checkPassword(password.replaceAll(' ', ''));
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await authRepository.register(name, email, password);
    } on AppException catch (e) {
      errorMessage = e.toString();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await authRepository.login(email, password.replaceAll(' ', ''));
      if (authRepository.changePasswordRequired) {
        changePasswordRequired = true;
        isLoggedIn = false;
      } else {
        changePasswordRequired = false;
        isLoggedIn = true;
      }
      print("PASSWORD CHNAGE REQUIRED : ${changePasswordRequired}");
    } on AppException catch (e) {
      errorMessage = e.toString();
    } catch (e) {
      isLoggedIn = false;
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
  }

  Future<void> checkAuthentication() async {
    isLoggedIn = await authRepository.isLoggedIn();
    notifyListeners();
  }

  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await authRepository.updatePassword(currentPassword, newPassword);
    } on AppException catch (e) {
      errorMessage = e.toString();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
