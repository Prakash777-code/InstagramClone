import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:instagram/main.dart';
import 'package:instagram/screens/notification_screen.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Notifications for likes and other activity',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        openNotificationScreen();
      },
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;

      if (notification != null) {
        await _localNotifications.show(
          id: notification.hashCode,
          title: notification.title ?? 'New Notification',
          body: notification.body ?? '',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'Notifications for likes and other activity',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      openNotificationScreen();
    });

    final initialMessage = await _messaging.getInitialMessage();
    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();

    if (initialMessage != null ||
        (launchDetails?.didNotificationLaunchApp ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openNotificationScreen();
      });
    }
  }

  void openNotificationScreen() {
    final context = navigatorKey.currentContext;

    if (context != null) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
    }
  }

  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    print('FCM TOKEN: $token');
    return token;
  }

  void showNotificationBanner(String title, String body) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 12,
        right: 12,
        child: Material(
          color: Colors.transparent,
          child: Card(
            elevation: 8,
            color: Colors.white,
            child: ListTile(
              leading: Image.asset(
                'assets/icon/app_icon.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(body),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => entry.remove(),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }
}
