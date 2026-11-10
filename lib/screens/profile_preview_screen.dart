import 'package:flutter/material.dart';
import 'package:instagram/repository/auth_repository.dart';

import 'package:instagram/viewModels/auth_view_model.dart';
import 'package:instagram/viewModels/home_view_model.dart';
import 'package:instagram/viewModels/profile_view_model.dart';

class ProfilePreviewScreen extends StatefulWidget {
  final int profileId;
  const ProfilePreviewScreen({super.key, required this.profileId});

  @override
  State<ProfilePreviewScreen> createState() {
    return _ProfilePreviewState();
  }
}

class _ProfilePreviewState extends State<ProfilePreviewScreen> {
  final ProfileViewModel profileViewModel = ProfileViewModel();
  final AuthViewModel authViewModel = AuthViewModel();
  final homeViewModel = HomeViewModel();
  bool isNavigatingToLogin = false;

  @override
  void initState() {
    super.initState();
    profileViewModel.addListener(profileListener);
    profileViewModel.getProfilebyId(widget.profileId);
  }

  void profileListener() {
    setState(() {});
  }

  @override
  void dispose() {
    profileViewModel.removeListener(profileListener);
    homeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = profileViewModel.profilePreview;
    final posts = profile?.profilePreview ?? [];
    final bool isOwnProfile =
        widget.profileId.toString() == AuthRepository.userId;
    final bool hasProfile = profile != null;
    final String userName = profile?.name ?? "User";
    print("Is own ${isOwnProfile}");
    print("Profile ID: ${widget.profileId}");
    print("Logged in ID: ${AuthRepository.userId}");
    print("Is own profile: $isOwnProfile");
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Profile'),
      ),
      body: profileViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade300,
                    child: hasProfile
                        ? Text(
                            userName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Text("U"),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    hasProfile ? userName : "U",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            (profileViewModel.profilePreview?.followers ?? 0)
                                .toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Followers'),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          Text(
                            (profileViewModel.profilePreview?.following ?? 0)
                                .toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Following'),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (!isOwnProfile)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: profileViewModel.isFollowingLoader
                              ? null
                              : () async {
                                  if (profileViewModel
                                      .profilePreview!
                                      .isFollowing) {
                                    profileViewModel
                                            .profilePreview!
                                            .isFollowing =
                                        false;
                                    await profileViewModel.unfollow(
                                      widget.profileId,
                                    );
                                    if (profileViewModel.errorMessage != null) {
                                      return;
                                    }
                                  } else {
                                    profileViewModel
                                            .profilePreview!
                                            .isFollowing =
                                        true;
                                    await profileViewModel.follow(
                                      widget.profileId,
                                    );
                                    if (profileViewModel.errorMessage != null) {
                                      return;
                                    }
                                  }
                                },
                          label: Text(
                            profileViewModel.profilePreview!.isFollowing
                                ? "Following"
                                : "Follow",
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  const Divider(),

                  const SizedBox(height: 5),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (profileViewModel.profilePreview == null ||
                      profileViewModel.profilePreview!.profilePreview.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Text("No posts yet"),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: profileViewModel
                          .profilePreview!
                          .profilePreview
                          .length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                      itemBuilder: (context, index) {
                        final post = profileViewModel
                            .profilePreview!
                            .profilePreview[index];
                        return Stack(
                          children: [
                            Image.network(
                              post.postUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade900,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.white54,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
