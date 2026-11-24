import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/screens/profile_preview_screen.dart';
import 'package:instagram/viewModels/search_user_view_model.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final searchUserViewModel = SearchUserViewModel();
  final scrollController = ScrollController();
  final Debouncer _debouncer = Debouncer();

  bool isNavigatingToLogin = false;

  @override
  void initState() {
    super.initState();
    searchUserViewModel.addListener(searchListener);
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.9) {
        searchUserViewModel.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    searchUserViewModel.removeListener(searchListener);
    searchUserViewModel.dispose();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void searchListener() {
    if (!mounted) return;
    if (searchUserViewModel.pushToLogin && !isNavigatingToLogin) {
      isNavigatingToLogin = true;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      Fluttertoast.showToast(msg: "Session expired, please login again");
    } else if (!searchUserViewModel.pushToLogin) {
      setState(() {});
    }
  }

  void _handleTextFieldChange(String value) {
    _debouncer.debounce(
      duration: const Duration(milliseconds: 500),
      onDebounce: () {
        searchUserViewModel.searchUser(searchController.text.trim());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: _handleTextFieldChange,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: searchUserViewModel.users.length,
                  itemBuilder: (context, index) {
                    final user = searchUserViewModel.users[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ProfilePreviewScreen(
                                      profileId: user.userId,
                                    );
                                  },
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey.shade300,
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ProfilePreviewScreen(
                                      profileId: user.userId,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
