import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/viewModels/auth_view_model.dart';
import 'package:instagram/utils/helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final authViewModel = AuthViewModel();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final helper = Helper();

  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authViewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Instagram',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'cursive',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sign up to see photos and videos from your friends.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(height: 30),

                      TextFormField(
                        controller: nameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintText: 'Name',
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }

                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          final res = helper.checkPassword(value!);
                          if (res != "Strong password") {
                            return res;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: authViewModel.isLoading
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    await authViewModel.register(
                                      nameController.text.trim(),
                                      emailController.text.trim(),
                                      passwordController.text,
                                    );

                                    if (authViewModel.errorMessage == null) {
                                      Fluttertoast.showToast(msg: "Registered");
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
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: Color(0xFFDBDBDB)),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: Color(0xFFDBDBDB)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const LoginScreen();
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                color: Color(0xFF0095F6),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
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
