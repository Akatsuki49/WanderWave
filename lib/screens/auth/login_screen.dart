import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';
import 'login_email_screen.dart';
import 'firebase_auth_methods.dart';
import '/widgets/auth_icon_button.dart';
import '/widgets/or_divider_widget.dart';
import 'package:flutter/gestures.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void onGoogleSignIn() async {
    context.read<FirebaseAuthMethods>().signInWithGoogle(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Welcome to",
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 10),
            const Text(
              "bh.ai",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Your personal AI assistant",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 60),
            AuthIconButton(
              labelText: 'Sign in with Google',
              isSvg: true,
              icon: SvgPicture.asset(
                'f/Users/shubh/development/WealHack/frontend/emosense/assets/google_icon.svg',
                height: 40,
              ),
              onPress: onGoogleSignIn,
            ),
            const SizedBox(height: 15),
            const OrDivider(),
            AuthIconButton(
              labelText: 'Sign in with Email',
              isSvg: false,
              icon: Icons.email,
              onPress: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return const EmailPasswordLogin();
                  },
                ));
              },
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "Sign up now",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 33, 10, 164),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return EmailPasswordSignup();
                          },
                        ));
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
