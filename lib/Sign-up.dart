import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:untitled17/ApiService.dart';
import 'package:untitled17/user_model.dart' as app_user;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final apiService = ApiService();

  bool isLoading = false;

  // 🔥 Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn();

      // إذا المستخدم لغى العملية
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance
          .signInWithCredential(credential);
    } catch (e) {
      print("Google Sign-In Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Error")),
      );
      return null;
    }
  }

  // 🔥 تسجيل عادي (API)
  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    app_user.User user = app_user.User(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      passwordConfirmation: confirmPasswordController.text,
    );


    try {
      final response = await apiService.register(user);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration:
                const InputDecoration(labelText: "Password"),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Confirm Password"),
              ),

              const SizedBox(height: 20),

              // زر التسجيل
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: register,
                child: const Text("Register"),
              ),

              const SizedBox(height: 10),

              // 🔥 زر Google
              ElevatedButton(
                onPressed: () async {
                  final user = await signInWithGoogle();

                  if (user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Welcome ${user.user?.email}"),
                      ),
                    );
                  }
                },
                child: const Text("Sign in with Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}