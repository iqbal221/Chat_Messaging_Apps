import 'package:chat_messaging/core/screens/profile_screen.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  static const String name = '/otp_verify_screen';

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController otpController = TextEditingController();

  String verificationId = '';

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    sendOTP();
  }

  Future<void> sendOTP() async {
    setState(() {
      isLoading = true;
    });

    if (widget.phoneNumber.trim().isEmpty) {
      debugPrint("EMPTY PHONE RECEIVED");
      return;
    }

    await auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,

      // AUTO VERIFY
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone Verified Automatically')),
          );
        }
      },

      // ERROR
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Verification Failed')),
        );
      },

      // CODE SENT
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('OTP Sent Successfully')));
      },

      // TIMEOUT
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },

      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> verifyOTP() async {
    if (otpController.text.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter valid OTP')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      await auth.signInWithCredential(credential);

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login Successful')));

      // Navigate Home Screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        ProfileScreen.name,
        (route) => false,
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,

      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              const SizedBox(height: 40),

              const Text(
                'Enter Code',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Text(
                'We have sent you an SMS with the code \nto ${widget.phoneNumber}',
                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 50),

              Pinput(
                controller: otpController,
                length: 6,

                defaultPinTheme: defaultPinTheme,

                focusedPinTheme: defaultPinTheme.copyDecorationWith(
                  border: Border.all(color: AppTheme.lightTheme.primaryColor),
                ),

                submittedPinTheme: defaultPinTheme,

                onCompleted: (pin) {
                  verifyOTP();
                },
              ),

              const SizedBox(height: 30),

              TextButton(
                onPressed: sendOTP,

                child: const Text('Resend OTP', style: TextStyle(fontSize: 16)),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed: isLoading ? null : verifyOTP,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
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
    );
  }
}
