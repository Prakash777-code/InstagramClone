import 'package:flutter/material.dart';
import 'package:instagram/screens/home_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/utils/helper.dart';
import 'package:instagram/viewModels/home_viewModel.dart';
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
    if (mounted) {
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
                          style: TextStyle(
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
                                    text: " liked your post",
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

                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.network(
                          notification.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
