import 'package:flutter/foundation.dart';
import 'package:instagram/exceptions/app_exception.dart';
import 'package:instagram/repository/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final authRepository = AuthRepository();
  bool isSendingOtp = false;
  bool isVerifying = false;
  bool isResetingPassword = false;
  String? errorMessage;

  Future<void> requestOtp(String email) async {
    if (email.isEmpty) {
      errorMessage = "Email is required to request OTP";
      notifyListeners();
      return;
    }
    isSendingOtp = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await authRepository.requestOtp(email.trim());
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isSendingOtp = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    if (email.isEmpty) {
      errorMessage = "Invalid OTP";
      notifyListeners();
      return;
    }
    if (otp.trim().isEmpty) {
      errorMessage = "Please enter the OTP";
      notifyListeners();
      return;
    }
    isVerifying = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await authRepository.verifyOtp(email, otp);
    } on AppException catch (e) {
      print("ERROR IN VIEW MODEL :${e}");
      errorMessage = e.message;
    } catch (e) {
      print("ERROR IN CATCH BLOCK :${e}");
      errorMessage = e.toString();
    } finally {
      isVerifying = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String newPassword) async {
    if (newPassword.trim().isEmpty) {
      errorMessage = "Enter new password";
      notifyListeners();
      return;
    }
    isResetingPassword = true;
    errorMessage = null;
    notifyListeners();
    try {
      await authRepository.resetPassword(newPassword);
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isResetingPassword = false;
      notifyListeners();
    }
  }
}
