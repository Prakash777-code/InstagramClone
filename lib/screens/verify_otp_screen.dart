import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/screens/forgot_password_screen.dart';
import 'package:instagram/screens/reset_password_screen.dart';
import 'package:instagram/viewModels/forgot_password_view_model.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  const VerifyOtpScreen({required this.email, super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final FocusNode otpFocusNode = FocusNode();
  final forgottPasswrodViewmodel = ForgotPasswordViewModel();
  final TextEditingController otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 45),

                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 75,
                  color: Color(0xFF0095F6),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Enter Confirmation Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Enter the 6-digit code we sent to your email address.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 35),

                GestureDetector(
                  onTap: () =>
                      FocusScope.of(context).requestFocus(otpFocusNode),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                          (index) => Container(
                            width: 42,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              border: Border.all(
                                color: const Color(0xFFDBDBDB),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              otpController.text.length > index
                                  ? otpController.text[index]
                                  : '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: otpController,
                          focusNode: otpFocusNode,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: forgottPasswrodViewmodel.isSendingOtp
                        ? null
                        : () async {
                            await forgottPasswrodViewmodel.requestOtp(
                              widget.email.trim(),
                            );
                            if (forgottPasswrodViewmodel.errorMessage == null) {
                              otpController.clear();
                              Fluttertoast.showToast(msg: "OTP sent");
                            } else if (forgottPasswrodViewmodel.errorMessage !=
                                null) {
                              Fluttertoast.showToast(
                                msg: forgottPasswrodViewmodel.errorMessage!,
                              );
                            }
                          },
                    child: forgottPasswrodViewmodel.isSendingOtp
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Resend Code',
                            style: TextStyle(
                              color: Color(0xFF0095F6),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                ListenableBuilder(
                  listenable: forgottPasswrodViewmodel,
                  builder: (context, child) {
                    return SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: forgottPasswrodViewmodel.isVerifying
                            ? null
                            : () async {
                                await forgottPasswrodViewmodel.verifyOtp(
                                  widget.email.trim(),
                                  otpController.text.trim(),
                                );
                                if (forgottPasswrodViewmodel.errorMessage !=
                                    null) {
                                  Fluttertoast.showToast(
                                    msg: forgottPasswrodViewmodel.errorMessage!,
                                  );
                                  return;
                                } else if (forgottPasswrodViewmodel
                                        .errorMessage ==
                                    null) {
                                  print(forgottPasswrodViewmodel.errorMessage);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const ResetPasswordScreen();
                                      },
                                    ),
                                  );
                                  Fluttertoast.showToast(
                                    msg: forgottPasswrodViewmodel.errorMessage!,
                                  );
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
                        child: forgottPasswrodViewmodel.isVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Verify Code',
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
