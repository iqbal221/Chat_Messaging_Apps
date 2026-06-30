import 'package:chat_messaging/core/screens/main_nav_bar.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:chat_messaging/features/auth/services/auth_service.dart';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const name = "/register";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool obscure = true;
  bool isLoading = false;
  String phoneNumber = '';

  Future<void> registerUser() async {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneNumber.isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await AuthService().register(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneNumber,
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registration Successful")));
      Navigator.pushReplacementNamed(context, MainNavBarScreen.name);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkTheme.scaffoldBackgroundColor
          : AppTheme.lightTheme.scaffoldBackgroundColor,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48, // account for padding
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Create Account",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),

                      const SizedBox(height: 30),

                      TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          hintText: "First Name",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: "Last Name",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      IntlPhoneField(
                        initialCountryCode: "BD",
                        decoration: const InputDecoration(
                          hintText: "Mobile Number",
                          border: OutlineInputBorder(),
                        ),

                        onChanged: (phone) {
                          phoneNumber = phone.completeNumber;
                        },
                      ),

                      const SizedBox(height: 18),

                      TextField(
                        controller: passwordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          hintText: "Password",
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : registerUser,
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Create Account"),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Login"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
