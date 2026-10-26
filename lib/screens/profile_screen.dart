import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/viewModels/auth_view_model.dart';
import 'package:instagram/viewModels/home_viewModel.dart';
import 'package:instagram/viewModels/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? selectedImage;

  final ImagePicker picker = ImagePicker();
  final ProfileViewModel profileViewModel = ProfileViewModel();
  final AuthViewModel authViewModel = AuthViewModel();
  final homeViewModel = HomeViewModel();
  bool isNavigatingToLogin = false;

  @override
  void initState() {
    super.initState();
    profileViewModel.addListener(profileListener);
    profileViewModel.getUserProfile();
  }

  void profileListener() {
    if (!mounted) return;
    if (profileViewModel.pushToLogin && !isNavigatingToLogin) {
      isNavigatingToLogin = true;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      Fluttertoast.showToast(msg: "Session expired, please login again");
    } else if (!profileViewModel.pushToLogin) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    profileViewModel.removeListener(profileListener);
    homeViewModel.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<void> logout() async {
    await authViewModel.logout();
    if (!mounted) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const LoginScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = profileViewModel.profile?.name ?? "User";
    final bool hasProfile = profileViewModel.profile != null;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
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
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Post'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImage!,
                              width: double.infinity,
                              height: 350,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: profileViewModel.buttonLoader
                                      ? null
                                      : () async {
                                          if (selectedImage == null) {
                                            Fluttertoast.showToast(
                                              msg: "Please select an image",
                                            );
                                            return;
                                          }
                                          if (await selectedImage!.length() >
                                              3 * 1024 * 1024) {
                                            Fluttertoast.showToast(
                                              msg: "File size must be less than 3 mb",
                                            );
                                            return;
                                          }
                                          await profileViewModel.uploadPost(
                                            selectedImage!,
                                          );
                                          if (profileViewModel.errorMessage ==
                                              null) {
                                            Fluttertoast.showToast(
                                              msg: "Post uploaded",
                                            );
                                            selectedImage = null;
                                            print(
                                              "CALLING GET PROFILE TO UPDATE",
                                            );
                                            await profileViewModel
                                                .getUserProfile();
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: profileViewModel
                                                  .errorMessage!,
                                            );
                                          }
                                        },
                                  child: profileViewModel.buttonLoader
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Upload Post'),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: OutlinedButton(
                                  onPressed: profileViewModel.buttonLoader
                                      ? null
                                      : () {
                                          setState(() {
                                            selectedImage = null;
                                          });
                                        },
                                  child: const Text('Remove'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

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

                  if (profileViewModel.profile == null ||
                      profileViewModel.profile!.posts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Text("No posts yet"),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: profileViewModel.profile!.posts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                      itemBuilder: (context, index) {
                        final post = profileViewModel.profile!.posts[index];
                        return Stack(
                          children: [
                            Image.network(
                              post.postUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),

                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        title: const Text('Are you sure?'),
                                        content: const Text(
                                          'Do you want to delete this post?',
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                              context,
                                              'Cancel',
                                            ),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await profileViewModel.deletePost(
                                                post.id,
                                              );
                                              if (profileViewModel
                                                      .errorMessage ==
                                                  null) {
                                                Fluttertoast.showToast(
                                                  msg: "Post deleted",
                                                );
                                                if (!mounted) {
                                                  return;
                                                }
                                                Navigator.pop(context);
                                                profileViewModel
                                                    .removePostLocally(post.id);
                                              } else {
                                                Fluttertoast.showToast(
                                                  msg: profileViewModel
                                                      .errorMessage!,
                                                );
                                              }
                                            },

                                            child: profileViewModel.buttonLoader
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                ),
                              ),
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
