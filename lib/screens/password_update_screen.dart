
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/utils/helper.dart';
import 'package:instagram/viewModels/auth_view_model.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final formKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final helper = Helper();
  final authViewModel = AuthViewModel();

  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authViewModel,
      builder: (context, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const Text(
                        'For your account security, please update your password before continuing.\n\n'
                        'Enter your current password and choose a new, strong password below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 25),

                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrentPassword,
                        autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          hintText: 'Current password',
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrentPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureCurrentPassword =
                                    !obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Current password is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNewPassword,
                        autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          hintText: 'New password',
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureNewPassword =
                                    !obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'New password is required';
                          }

                          final res = helper.checkPassword(value);

                          if (res != "Strong password") {
                            return res;
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirmPassword,
                        autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          hintText: 'Confirm password',
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm password is required';
                          }

                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: authViewModel.isLoading
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    await authViewModel.updatePassword(
                                      currentPasswordController.text.trim(),
                                      newPasswordController.text.trim(),
                                    );

                                    if (authViewModel.errorMessage == null) {
                                      Fluttertoast.showToast(
                                        msg:
                                            "Your password was updated login to continue",
                                      );

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return const LoginScreen();
                                          },
                                        ),
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: authViewModel.errorMessage!,
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0095F6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: authViewModel.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Change password',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}