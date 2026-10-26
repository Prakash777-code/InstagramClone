import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/screens/verify_otp_screen.dart';
import 'package:instagram/viewModels/forgot_password_view_model.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final forgotPasswordViewMoel = ForgotPasswordViewModel();
  final emailController = TextEditingController();

  @override
  void dispose() {
    forgotPasswordViewMoel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Forgot Password',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.lock_reset,
                  size: 70,
                  color: Color(0xFF0095F6),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Reset your password',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter your email so an OTP can be sent',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 35),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 16),
                ListenableBuilder(
                  listenable: forgotPasswordViewMoel,
                  builder: (context, child) {
                    return SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: forgotPasswordViewMoel.isSendingOtp
                            ? null
                            : () async {
                                if (emailController.text.trim().isNotEmpty) {
                                  await forgotPasswordViewMoel.requestOtp(
                                    emailController.text.trim(),
                                  );
                                  if (!context.mounted) return;
                                  if (forgotPasswordViewMoel.errorMessage !=
                                      null) {
                                    Fluttertoast.showToast(
                                      msg: "Something went wrong. Please try again.",
                                    );
                                    return;
                                  }
                                  Fluttertoast.showToast(
                                    msg: "If an account exists, we have sent you a 6-digit OTP",
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VerifyOtpScreen(
                                        email: emailController.text.trim(),
                                      ),
                                    ),
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Email is required to send an OTP",
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0095F6),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF0095F6),
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: forgotPasswordViewMoel.isSendingOtp
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
