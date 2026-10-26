import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await secureStorage.write(key: "accessToken", value: accessToken);
    await secureStorage.write(key: "refreshToken", value: refreshToken);
  }

  Future<void> saveAccessToken(String accessToken) async {
    await secureStorage.write(key: "accessToken", value: accessToken);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await secureStorage.write(key: "refreshToken", value: refreshToken);
  }

  Future<void> saveFcmToken(String fcmToken) async {
    await secureStorage.write(key: "fcmToken", value: fcmToken);
  }

  Future<void> saveResetToken(String resetToekn) async {
    await secureStorage.write(key: "reset-token", value: resetToekn);
  }

  Future<void> savePasswordpdateToken(String passwordUpdateToken) async {
    await secureStorage.write(
      key: "passwordUpdateToken",
      value: passwordUpdateToken,
    );
  }

  Future<String?> getPasswordUpdateToken() async {
    return await secureStorage.read(key: "passwordUpdateToken");
  }

  Future<String?> getResetToken() async {
    return await secureStorage.read(key: 'reset-token');
  }

  Future<String?> getFcmToken() async {
    return await secureStorage.read(key: "fcmToken");
  }

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: "accessToken");
  }

  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: "refreshToken");
  }

  Future<void> clearTokens() async {
    await secureStorage.delete(key: "accessToken");
    await secureStorage.delete(key: "refreshToken");
    await secureStorage.delete(key: "fcmToken");
  }
}
