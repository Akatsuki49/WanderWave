import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderwave/services/firebase_auth_methods.dart';
import 'package:wanderwave/widgets/auth_icon_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;

    void onSignOut() {
      context.read<FirebaseAuthMethods>().signOut(context);
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Profile Screen',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 50),
            if (user.email != null) ...[
              const SizedBox(height: 20),
              Text(user.email!),
            ],
            if (user.displayName != null) ...[
              const SizedBox(height: 20),
              Text(user.displayName!),
            ],
            if (user.phoneNumber != null) ...[
              const SizedBox(height: 20),
              Text(user.phoneNumber!),
            ],
            const SizedBox(height: 20),
            AuthIconButton(
              labelText: 'Sign Out',
              isSvg: false,
              onPress: onSignOut,
              icon: Icons.sign_language,
            ),
          ],
        ),
      ),
    );
  }
}
