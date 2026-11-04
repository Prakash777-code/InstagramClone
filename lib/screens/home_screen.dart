import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/repository/auth_repository.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/screens/notification_screen.dart';
import 'package:instagram/services/secure_storage.dart';
import 'package:instagram/viewModels/auth_view_model.dart';
import 'package:instagram/viewModels/home_view_model.dart';
import 'package:instagram/viewModels/notification_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final homeViewModel = HomeViewModel();
  final authViewModel = AuthViewModel();
  final scrollController = ScrollController();
  final notificationViewModel = NotificationViewModel();
  bool isNavigatingToLogin = false;

  @override
  void initState() {
    super.initState();
    homeViewModel.addListener(homeListener);
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.9) {
        homeViewModel.loadNextFeed();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserAuthentication();
    });
    notificationViewModel.hasUnreadNotification();
  }

  void homeListener() {
    if (!mounted) return;
    if (homeViewModel.pushToLogin && !isNavigatingToLogin) {
      isNavigatingToLogin = true;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      Fluttertoast.showToast(msg: "Session expired, please login again");
    } else if (!homeViewModel.pushToLogin) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    homeViewModel.dispose();
    scrollController.dispose();
    notificationViewModel.dispose();
    super.dispose();
  }

  Future<void> checkUserAuthentication() async {
    await authViewModel.checkAuthentication();
    if (!mounted) {
      return;
    }
    if (!authViewModel.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
      );
      return;
    }
    await homeViewModel.getUserFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Instagram',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            fontFamily: 'cursive',
            color: Colors.black,
          ),
        ),
        actions: [
          const SizedBox(width: 6),

          AnimatedBuilder(
            animation: notificationViewModel,
            builder: (context, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const NotificationScreen();
                          },
                        ),
                      ).then((_) {
                        notificationViewModel.hasUnreadNotification();
                        homeViewModel.getUserFeed();
                      });
                      ;
                    },
                    icon: const Icon(
                      Icons.favorite_border,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),

                  if (notificationViewModel.showNotificationBadge)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: homeViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: scrollController,
              itemCount: homeViewModel.postFeed.length + 1,
              itemBuilder: (context, index) {
                if (index == homeViewModel.postFeed.length) {
                  if (homeViewModel.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return const SizedBox(height: 15);
                }
                final post = homeViewModel.postFeed[index];
                final isLiked = homeViewModel.likedIds.contains(post.id);
                final isFollowing = homeViewModel.followingId.contains(
                  post.userId,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey.shade300,
                            child: Text(
                              post.userName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            post.userName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (post.userId.toString() != AuthRepository.userId)
                            GestureDetector(
                              onTap: homeViewModel.isFollowingLoading
                                  ? null
                                  : () async {
                                      if (isFollowing) {
                                        homeViewModel.updateFollowingStatus(
                                          post.userId,
                                          false,
                                        );
                                        await homeViewModel.unFollow(
                                          post.userId,
                                        );
                                        if (homeViewModel.errorMessage !=
                                            null) {
                                          return;
                                        }
                                      } else {
                                        homeViewModel.updateFollowingStatus(
                                          post.userId,
                                          true,
                                        );
                                        await homeViewModel.follow(post.userId);
                                        if (homeViewModel.errorMessage !=
                                            null) {
                                          return;
                                        }
                                      }
                                    },
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isFollowing
                                      ? Colors.white
                                      : Colors.blue,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isFollowing
                                        ? Colors.black
                                        : Colors.blue,
                                  ),
                                ),
                                child: Text(
                                  isFollowing ? "Following" : "Follow",
                                  style: TextStyle(
                                    color: isFollowing
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 380,
                      color: Colors.grey.shade200,
                      child: Image.network(
                        post.postUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image, size: 40),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6, top: 5),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: homeViewModel.isLiking
                                ? null
                                : () async {
                                    if (isLiked) {
                                      await homeViewModel.unlikePost(post.id);
                                      if (homeViewModel.errorMessage == null) {
                                        post.likes--;
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: homeViewModel.errorMessage!,
                                        );
                                      }
                                    } else {
                                      await homeViewModel.likePost(post.id);
                                      if (homeViewModel.errorMessage == null) {
                                        post.likes++;
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: homeViewModel.errorMessage!,
                                        );
                                      }
                                    }
                                  },
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 28,
                              color: isLiked ? Colors.red : Colors.black,
                            ),
                          ),

                          Text(
                            post.likes.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
