import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/utils/helper.dart';
import 'package:instagram/viewModels/home_view_model.dart';
import 'package:instagram/viewModels/notification_view_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() {
    return _NotificationScreen();
  }
}

class _NotificationScreen extends State<NotificationScreen> {
  final notificationViewModel = NotificationViewModel();
  final helper = Helper();
  final scrollController = ScrollController();
  final homeViewModel = HomeViewModel();
  bool isNavigatingToLogin = false;

  @override
  void initState() {
    super.initState();
    notificationViewModel.addListener(notificationListener);
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.9) {
        notificationViewModel.loadMoreNotifications();
      }
    });
    getNotifications();
  }

  void getNotifications() async {
    await notificationViewModel.getNotifications();
  }

  void notificationListener() {
    if (!mounted) return;
    if (notificationViewModel.pushToLogin && !isNavigatingToLogin) {
      isNavigatingToLogin = true;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      Fluttertoast.showToast(msg: "Session expired, please login again");
    } else if (!notificationViewModel.pushToLogin) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    notificationViewModel.dispose();
    scrollController.dispose();
    homeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: notificationViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationViewModel.notificationList.isEmpty
          ? const Center(child: Text("No notifications yet"))
          : ListView.builder(
              controller: scrollController,
              itemCount: notificationViewModel.notificationList.length + 1,
              itemBuilder: (context, index) {
                if (index == notificationViewModel.notificationList.length) {
                  if (notificationViewModel.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox(height: 15);
                }
                final notification =
                    notificationViewModel.notificationList[index];
                final isFollowing = notificationViewModel.followingIds.contains(
                  notification.senderId,
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: Text(
                          notification.userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: notification.userName,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        notification.notificationType ==
                                            "FOLLOW"
                                        ? " started following you"
                                        : " Liked your post",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              helper.getTimeAgo(notification.createdAt),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      notification.notificationType == "FOLLOW"
                          ? ElevatedButton(
                              onPressed: notificationViewModel.isFollowing
                                  ? null
                                  : () async {
                                      if (isFollowing) {
                                        await notificationViewModel.unFollow(
                                          notification.senderId,
                                        );
                                        notificationViewModel.toggleFollow(
                                          notification.senderId,
                                          false,
                                        );
                                      } else {
                                        await notificationViewModel.follow(
                                          notification.senderId,
                                        );
                                        notificationViewModel.toggleFollow(
                                          notification.senderId,
                                          true,
                                        );
                                      }
                                      if (notificationViewModel.errorMessage !=
                                          null) {
                                        return;
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFollowing
                                    ? Colors.white
                                    : Colors.blue,
                                disabledBackgroundColor: isFollowing
                                    ? Colors.white
                                    : Colors.blue,
                                foregroundColor: isFollowing
                                    ? Colors.black
                                    : Colors.white,
                                disabledForegroundColor: isFollowing
                                    ? Colors.black
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    color: isFollowing
                                        ? Colors.black
                                        : Colors.transparent,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                minimumSize: const Size(100, 35),
                              ),
                              child: Text(
                                isFollowing ? "Following" : "Follow back",
                                style: TextStyle(
                                  color: isFollowing
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            )
                          : notification.imageUrl != null &&
                                notification.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Image.network(
                                notification.imageUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
