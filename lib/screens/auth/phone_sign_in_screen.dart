import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderwave/screens/profile_screen.dart';
import 'package:wanderwave/services/firebase_auth_methods.dart';
import 'package:wanderwave/widgets/auth_textfield.dart';

class PhoneSignInScreen extends StatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  State<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  final TextEditingController phoneController = TextEditingController();

  void loginUser() async {
    context.read<FirebaseAuthMethods>().phoneSignIn(
          context: context,
          phoneNumber: phoneController.text,
          onSignInSuccess: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  return const ProfileScreen();
                },
              ),
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Login with Phone",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 35),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: AuthTextField(
              controller: phoneController,
              hintText: 'Enter your phone number',
              textInputType: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 35),
          ElevatedButton(
            onPressed: loginUser,
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: const BorderSide(color: Colors.black),
                ),
              ),
              backgroundColor: MaterialStateProperty.all(Colors.black),
              textStyle: MaterialStateProperty.all(
                const TextStyle(color: Colors.white),
              ),
              minimumSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width / 3.5, 50),
              ),
            ),
            child: const Text(
              "Login",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
