import 'package:chat_messaging/features/auth/presentation/screens/otp_verify.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  static const String name = '/phone_number';

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController phoneController = TextEditingController();

  String completePhoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Enter Your Phone Number',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Text(
                'Please confirm your country code and enter your phone number.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 40),

              IntlPhoneField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                initialCountryCode: 'BD',
                style: const TextStyle(color: Colors.black, fontSize: 16),
                dropdownTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),

                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: AppTheme.lightTheme.hintColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),

                onChanged: (phone) {
                  setState(() {
                    completePhoneNumber = phone.completeNumber;
                  });
                  debugPrint("PHONE: $completePhoneNumber");
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed: () {
                    if (completePhoneNumber.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter valid phone number'),
                        ),
                      );
                      return;
                    }

                    print('Complete Phone Number: $completePhoneNumber');

                    Navigator.pushNamed(
                      context,
                      OtpVerifyScreen.name,
                      arguments: {'phoneNumber': completePhoneNumber},
                    );
                  },

                  child: const Text(
                    'Continue',
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
